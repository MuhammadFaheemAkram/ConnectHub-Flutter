import 'dart:async';
import 'dart:collection';

import 'package:clock/clock.dart';
import 'package:connect_hub/core/common/app_exception.dart';
import 'package:connect_hub/core/common/demo_account.dart';
import 'package:connect_hub/core/common/id_generator.dart';
import 'package:connect_hub/core/common/validators.dart';
import 'package:connect_hub/core/network/dto/auth_response_dto.dart';
import 'package:connect_hub/core/network/dto/chat_event_dto.dart';
import 'package:connect_hub/core/network/dto/comment_dto.dart';
import 'package:connect_hub/core/network/dto/conversation_dto.dart';
import 'package:connect_hub/core/network/dto/create_post_request_dto.dart';
import 'package:connect_hub/core/network/dto/message_dto.dart';
import 'package:connect_hub/core/network/dto/notification_dto.dart';
import 'package:connect_hub/core/network/dto/post_dto.dart';
import 'package:connect_hub/core/network/dto/post_page_dto.dart';
import 'package:connect_hub/core/network/dto/search_response_dto.dart';
import 'package:connect_hub/core/network/dto/update_profile_request_dto.dart';
import 'package:connect_hub/core/network/dto/user_dto.dart';
import 'package:connect_hub/core/network/fake_server/reply_scheduler.dart';
import 'package:connect_hub/core/network/fake_server/seed_loader.dart';
import 'package:injectable/injectable.dart';

/// An in-memory stand-in for ConnectHub's backend.
///
/// It plays the role a REST server would: it owns the data and its rules
/// (accounts, tokens, profiles, posts, likes, bookmarks, comments, search,
/// chats and notifications). The
/// rest of the app reaches it **only** through the `…ApiService` interfaces,
/// so a real HTTP client could replace the fake services without changing
/// any caller.
///
/// It lives in memory and seeds itself from the bundled JSON on first use.
/// Every launch therefore starts from the same seed: accounts created by sign
/// up, posts, likes, bookmarks, comments, messages and read states last until
/// the app restarts.
/// That's deliberate, because the backend is not the point of this project;
/// how the app talks to it is.
///
/// Transport concerns (latency, simulated failures, attaching the token) live
/// in the fake API layer, not here.
@lazySingleton
class FakeServer {
  FakeServer(this._seeds, this._ids, this._clock, this._replies);

  final SeedLoader _seeds;
  final IdGenerator _ids;
  final Clock _clock;
  final ReplyScheduler _replies;

  Future<void>? _seeding;

  /// Accounts by normalized (trimmed, lower-case) email.
  final _accounts = <String, _Account>{};

  /// Public profiles by user id. Emails live in [_accounts] only, so a post's
  /// author never carries an email address.
  final _users = <String, UserDto>{};

  /// Posts by id.
  final _posts = <String, _ServerPost>{};

  /// Every comment, in the order they were added.
  final _comments = <_ServerComment>[];

  /// Conversations by id. Each belongs to one user's inbox ([_ServerConversation.ownerId]).
  final _conversations = <String, _ServerConversation>{};

  /// Every chat message, in the order the server received them.
  final _messages = <_ServerMessage>[];
  int _messageSeq = 0;

  /// Every notification, each for one user.
  final _notifications = <_ServerNotification>[];

  /// The realtime channel's events, for every user; [chatEvents] picks one
  /// user's.
  final _chatEvents =
      StreamController<({String ownerId, ChatEventDto event})>.broadcast();

  /// Which canned reply comes next (see [cannedReplies]).
  int _nextCannedReply = 0;

  /// Tokens revoked by "Expire session" (Settings → Developer).
  final _revokedTokens = <String>{};

  /// How old the newest seed record is at launch (see [_seed]).
  static const newestSeedAge = Duration(minutes: 5);

  // ---------------------------------------------------------------------------
  // Auth

  /// Signs in with an email and password.
  ///
  /// Throws [InvalidCredentialsException] for an unknown email *and* for a
  /// wrong password, so the response doesn't reveal which emails exist.
  Future<AuthResponseDto> login({
    required String email,
    required String password,
  }) async {
    await _ready();
    final key = _normalize(email);
    final account = _accounts[key];
    if (account == null || account.password != password) {
      throw const InvalidCredentialsException();
    }
    return _authResponse(key);
  }

  /// Creates an account and signs it in.
  ///
  /// Throws [EmailTakenException] when the email (compared
  /// case-insensitively) already has an account.
  Future<AuthResponseDto> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    await _ready();
    final key = _normalize(email);
    if (_accounts.containsKey(key)) throw const EmailTakenException();

    final user = UserDto(
      id: _ids.next('u'),
      name: name.trim(),
      bio: 'New to ConnectHub 👋',
    );
    _users[user.id] = user;
    _accounts[key] = _Account(userId: user.id, password: password);
    return _authResponse(key);
  }

  /// Resolves a bearer token to its user id, like an auth middleware.
  ///
  /// Tokens are self-describing (`fake.<userId>.<random>`), so the server
  /// needn't remember the ones it issued: any well-formed token for an
  /// existing user is valid unless it was revoked. The demo user is seeded on
  /// every launch, so the demo session survives restarts; an account created
  /// by sign up doesn't, and its token then fails with
  /// [UnauthorizedException].
  Future<String> authenticate(String? token) async {
    await _ready();
    final userId = _userIdIn(token);
    if (userId == null ||
        _revokedTokens.contains(token) ||
        !_users.containsKey(userId)) {
      throw const UnauthorizedException();
    }
    return userId;
  }

  /// Makes [token] invalid from now on (Settings → Developer → Expire
  /// session).
  void revoke(String token) => _revokedTokens.add(token);

  // ---------------------------------------------------------------------------
  // Feed

  /// One page of the feed as [viewerId] sees it: newest first, ties broken by
  /// id, starting after [cursor] (or at the top when it is `null`).
  ///
  /// The cursor marks a *position* ("older than this post"), not an offset.
  /// A post created after page 1 was fetched lands above that position, so
  /// page 2 neither repeats nor skips anything. With offsets, every new post
  /// would shift the following pages by one.
  Future<PostPageDto> getFeed(
    String viewerId, {
    String? cursor,
    required int limit,
  }) async {
    await _ready();
    final after = cursor == null ? null : _Cursor.decode(cursor);
    final older = [
      for (final post in _postsNewestFirst())
        if (after == null || after.isNewerThan(post)) post,
    ];
    final page = older.take(limit).toList();
    return PostPageDto(
      posts: [for (final post in page) _postDto(post, viewerId)],
      nextCursor: older.length > page.length
          ? _Cursor.at(page.last).encode()
          : null,
    );
  }

  /// Likes or unlikes a post for [viewerId] and returns the updated post.
  ///
  /// Idempotent, like an HTTP `PUT`/`DELETE`: liking twice still counts one
  /// like, so a retried request can't inflate the count.
  Future<PostDto> setLiked(
    String viewerId,
    String postId, {
    required bool liked,
  }) async {
    await _ready();
    final post = _post(postId);
    if (liked) {
      post.likedBy.add(viewerId);
    } else {
      post.likedBy.remove(viewerId);
    }
    return _postDto(post, viewerId);
  }

  /// Bookmarks or un-bookmarks a post for [viewerId] and returns the updated
  /// post. Idempotent too: bookmarking again keeps the original time.
  Future<PostDto> setBookmarked(
    String viewerId,
    String postId, {
    required bool bookmarked,
  }) async {
    await _ready();
    final post = _post(postId);
    if (bookmarked) {
      post.bookmarks.putIfAbsent(viewerId, () => _clock.now().toUtc());
    } else {
      post.bookmarks.remove(viewerId);
    }
    return _postDto(post, viewerId);
  }

  /// One post as [viewerId] sees it. Throws [NotFoundException] for an
  /// unknown id.
  Future<PostDto> getPost(String viewerId, String postId) async {
    await _ready();
    return _postDto(_post(postId), viewerId);
  }

  /// Publishes a post by [viewerId] and returns it. It is the newest post,
  /// so it heads the feed's first page.
  ///
  /// The server checks the same rules as the client and stores the trimmed
  /// text. A request that breaks them fails with a [FormatException], which a
  /// real API would answer as 400 Bad Request.
  Future<PostDto> createPost(
    String viewerId,
    CreatePostRequestDto request,
  ) async {
    await _ready();
    final content = request.content.trim();
    final imageUrl = request.imageUrl?.trim() ?? '';
    if (Validators.postContent(content) != null ||
        Validators.imageUrl(imageUrl) != null) {
      throw FormatException('Invalid post', request.content);
    }
    final post = _ServerPost(
      id: _ids.next('p'),
      authorId: viewerId,
      content: content,
      imageUrl: imageUrl.isEmpty ? null : imageUrl,
      createdAt: _clock.now().toUtc(),
      seedLikes: 0,
    );
    _posts[post.id] = post;
    return _postDto(post, viewerId);
  }

  // ---------------------------------------------------------------------------
  // Comments

  /// The comments on [postId], oldest first. Throws [NotFoundException] for
  /// an unknown post.
  Future<List<CommentDto>> getComments(String postId) async {
    await _ready();
    _post(postId);
    final comments =
        _comments.where((comment) => comment.postId == postId).toList()
          ..sort(_ServerComment.oldestFirst);
    return [for (final comment in comments) _commentDto(comment)];
  }

  /// Adds a comment by [viewerId] to [postId] and returns it. The post's
  /// `commentCount` goes up with it, because it is counted, not stored.
  Future<CommentDto> addComment(
    String viewerId,
    String postId,
    String text,
  ) async {
    await _ready();
    final post = _post(postId);
    final body = text.trim();
    if (body.isEmpty ||
        Validators.lengthOf(body) > Validators.commentMaxLength) {
      throw FormatException('Invalid comment', text);
    }
    final comment = _ServerComment(
      id: _ids.next('c'),
      postId: post.id,
      authorId: viewerId,
      text: body,
      createdAt: _clock.now().toUtc(),
    );
    _comments.add(comment);
    return _commentDto(comment);
  }

  /// Deletes one of [viewerId]'s own comments.
  ///
  /// Someone else's comment answers [NotFoundException], exactly like a
  /// missing one. Many APIs (GitHub, for one) answer 404 rather than 403
  /// here, so a stranger can't even confirm that the comment exists.
  Future<void> deleteComment(String viewerId, String commentId) async {
    await _ready();
    final index = _comments.indexWhere(
      (comment) => comment.id == commentId && comment.authorId == viewerId,
    );
    if (index == -1) throw const NotFoundException();
    _comments.removeAt(index);
  }

  // ---------------------------------------------------------------------------
  // Bookmarks

  /// The posts [viewerId] has bookmarked, the most recently bookmarked first
  /// (ties broken by id, like the feed).
  Future<List<PostDto>> getBookmarks(String viewerId) async {
    await _ready();
    DateTime bookmarkedAt(_ServerPost post) => post.bookmarks[viewerId]!;
    final bookmarked =
        [
          for (final post in _posts.values)
            if (post.bookmarks.containsKey(viewerId)) post,
        ]..sort((a, b) {
          final byTime = bookmarkedAt(b).compareTo(bookmarkedAt(a));
          return byTime != 0 ? byTime : b.id.compareTo(a.id);
        });
    return [for (final post in bookmarked) _postDto(post, viewerId)];
  }

  // ---------------------------------------------------------------------------
  // Users

  /// Anyone's public profile. Throws [NotFoundException] for an unknown id.
  Future<UserDto> getUser(String userId) async {
    await _ready();
    return _user(userId);
  }

  /// Every post by [userId], newest first, as [viewerId] sees them. Throws
  /// [NotFoundException] for an unknown user.
  Future<List<PostDto>> getUserPosts(String viewerId, String userId) async {
    await _ready();
    _user(userId);
    return [
      for (final post in _postsNewestFirst())
        if (post.authorId == userId) _postDto(post, viewerId),
    ];
  }

  /// Updates [viewerId]'s own profile and returns it.
  ///
  /// Posts and comments store their author's id, not a copy of the name, so
  /// the new name and picture show on everything the user ever wrote. The
  /// server checks the client's rules again and stores trimmed values; a
  /// request that breaks them fails with a [FormatException] (400).
  Future<UserDto> updateMe(
    String viewerId,
    UpdateProfileRequestDto request,
  ) async {
    await _ready();
    final user = _user(viewerId);
    final name = request.name.trim();
    final bio = request.bio.trim();
    final avatarUrl = request.avatarUrl?.trim() ?? '';
    if (Validators.name(name) != null ||
        Validators.bio(bio) != null ||
        Validators.imageUrl(avatarUrl) != null) {
      throw FormatException('Invalid profile', request.name);
    }
    _users[viewerId] = UserDto(
      id: user.id,
      name: name,
      avatarUrl: avatarUrl.isEmpty ? null : avatarUrl,
      bio: bio,
      followersCount: user.followersCount,
      followingCount: user.followingCount,
    );
    return _ownRecord(viewerId);
  }

  // ---------------------------------------------------------------------------
  // Search

  /// People and posts matching [query], case-insensitively ("contains"):
  /// - people by name or bio, except the viewer, the most followed first;
  /// - posts by content or author name, newest first.
  ///
  /// A blank query matches nothing.
  Future<SearchResponseDto> search(String viewerId, String query) async {
    await _ready();
    final needle = query.trim().toLowerCase();
    if (needle.isEmpty) return const SearchResponseDto(users: [], posts: []);
    bool matches(String text) => text.toLowerCase().contains(needle);

    final people = [
      for (final user in _users.values)
        if (user.id != viewerId && (matches(user.name) || matches(user.bio)))
          user,
    ]..sort(_mostFollowedFirst);
    return SearchResponseDto(
      users: people,
      posts: [
        for (final post in _postsNewestFirst())
          if (matches(post.content) || matches(_users[post.authorId]!.name))
            _postDto(post, viewerId),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Chat

  /// The other person's answer to a question.
  static const questionReply = 'Good question — let me think about that. 🤔';

  /// The answers to everything else, given in turn (the iOS edition's
  /// replies), so a test knows which comes next.
  static const cannedReplies = [
    'Sounds good! 👍',
    'Ha, totally agree.',
    'Let me get back to you on that.',
    'Nice — thanks for the update!',
    'Interesting, tell me more.',
    'On it. 🚀',
    'That makes sense to me.',
    'Great point!',
  ];

  /// [viewerId]'s conversations, the most recent activity first.
  Future<List<ConversationDto>> getConversations(String viewerId) async {
    await _ready();
    final inbox =
        [
          for (final conversation in _conversations.values)
            if (conversation.ownerId == viewerId) conversation,
        ]..sort((a, b) {
          final byTime = _updatedAt(b).compareTo(_updatedAt(a));
          return byTime != 0 ? byTime : a.id.compareTo(b.id);
        });
    return [for (final conversation in inbox) _conversationDto(conversation)];
  }

  /// The messages in one of [viewerId]'s conversations, oldest first.
  /// Anyone else's conversation answers [NotFoundException], like a missing
  /// one.
  Future<List<MessageDto>> getMessages(
    String viewerId,
    String conversationId,
  ) async {
    await _ready();
    final conversation = _conversationOf(viewerId, conversationId);
    return [
      for (final message in _messagesIn(conversation.id)) _messageDto(message),
    ];
  }

  /// Stores [text] as [viewerId]'s message, and schedules the reply.
  ///
  /// [clientId] is the id the client generated for the message. Sending the
  /// same id again (a retry after a lost answer, say) returns the message
  /// already stored, and schedules no second reply: a retry can't duplicate
  /// anything. A blank message, or one over 1000 characters, is refused (a
  /// 400, [FormatException]).
  Future<MessageDto> sendMessage(
    String viewerId,
    String conversationId, {
    required String clientId,
    required String text,
  }) async {
    await _ready();
    final conversation = _conversationOf(viewerId, conversationId);
    if (_messageById(clientId) case final existing?) {
      if (existing.senderId != viewerId) {
        throw FormatException('Message id already taken', clientId);
      }
      return _messageDto(existing);
    }
    final body = text.trim();
    if (body.isEmpty ||
        Validators.lengthOf(body) > Validators.messageMaxLength) {
      throw FormatException('Invalid message', text);
    }
    final message = _ServerMessage(
      id: clientId,
      conversationId: conversation.id,
      senderId: viewerId,
      text: body,
      createdAt: _clock.now().toUtc(),
      seq: _messageSeq++,
    );
    _messages.add(message);
    _scheduleReply(conversation, answering: body);
    return _messageDto(message);
  }

  /// Marks one of [viewerId]'s conversations read.
  Future<void> markConversationRead(
    String viewerId,
    String conversationId,
  ) async {
    await _ready();
    _conversationOf(viewerId, conversationId).unreadCount = 0;
  }

  /// The realtime channel: what happens in [viewerId]'s conversations, as it
  /// happens.
  Stream<ChatEventDto> chatEvents(String viewerId) => _chatEvents.stream
      .where((owned) => owned.ownerId == viewerId)
      .map((owned) => owned.event);

  /// The other person types, then answers (see [ReplyScheduler]). A reply
  /// raises the conversation's unread count; the client decides whether
  /// that stays (a conversation on screen is read at once).
  void _scheduleReply(
    _ServerConversation conversation, {
    required String answering,
  }) {
    final text = answering.contains('?')
        ? questionReply
        : cannedReplies[_nextCannedReply++ % cannedReplies.length];
    void emit(ChatEventDto event) =>
        _chatEvents.add((ownerId: conversation.ownerId, event: event));

    _replies.schedule(
      conversation.id,
      onTypingStarted: () => emit(TypingStartedEvent(conversation.id)),
      onReply: () {
        final reply = _ServerMessage(
          id: _ids.next('m'),
          conversationId: conversation.id,
          senderId: conversation.participantId,
          text: text,
          createdAt: _clock.now().toUtc(),
          seq: _messageSeq++,
        );
        _messages.add(reply);
        conversation.unreadCount++;
        emit(
          MessageReceivedEvent(
            message: _messageDto(reply),
            conversation: _conversationDto(conversation),
          ),
        );
      },
      onTypingStopped: () => emit(TypingStoppedEvent(conversation.id)),
    );
  }

  // ---------------------------------------------------------------------------
  // Notifications

  /// [viewerId]'s notifications, newest first, each with its read state.
  Future<List<NotificationDto>> getNotifications(String viewerId) async {
    await _ready();
    final mine =
        [
          for (final notification in _notifications)
            if (notification.ownerId == viewerId) notification,
        ]..sort((a, b) {
          final byTime = b.createdAt.compareTo(a.createdAt);
          return byTime != 0 ? byTime : a.id.compareTo(b.id);
        });
    return [for (final notification in mine) notification.toDto()];
  }

  /// Marks one of [viewerId]'s notifications read. Idempotent; anyone
  /// else's (or an unknown id) answers [NotFoundException].
  Future<void> markNotificationRead(
    String viewerId,
    String notificationId,
  ) async {
    await _ready();
    final notification = _notifications.firstWhere(
      (notification) =>
          notification.id == notificationId && notification.ownerId == viewerId,
      orElse: () => throw const NotFoundException(),
    );
    notification.isRead = true;
  }

  Future<void> markAllNotificationsRead(String viewerId) async {
    await _ready();
    for (final notification in _notifications) {
      if (notification.ownerId == viewerId) notification.isRead = true;
    }
  }

  /// Stops every reply still to come and closes the realtime channel. The app
  /// never calls it; `getIt.reset()` does, between tests.
  @disposeMethod
  void dispose() {
    _replies.cancelAll();
    unawaited(_chatEvents.close());
  }

  // ---------------------------------------------------------------------------
  // Seeding

  Future<void> _ready() => _seeding ??= _seed();

  Future<void> _seed() async {
    final demo = await _seeds.loadAuthUser();
    final posts = await _seeds.loadPosts();
    final comments = await _seeds.loadComments();
    final conversations = await _seeds.loadConversations();
    final messages = await _seeds.loadMessages();
    final notifications = await _seeds.loadNotifications();

    // The seed's dates are fixed (July 2026). Shift them all by the same
    // amount, so the newest record is a few minutes old whenever the app
    // launches and the feed always looks fresh. The gaps between records
    // stay as they are in the seed.
    final newest = [
      for (final post in posts) post.createdAt,
      for (final comment in comments) comment.createdAt,
      for (final conversation in conversations) conversation.updatedAt,
      for (final message in messages) message.createdAt,
      for (final notification in notifications) notification.createdAt,
    ].reduce((a, b) => a.isAfter(b) ? a : b);
    final launch = _clock.now().toUtc();
    final shift = launch.subtract(newestSeedAge).difference(newest);

    _users[demo.id] = _profile(demo);
    _accounts[_normalize(demo.email ?? DemoAccount.email)] = _Account(
      userId: demo.id,
      password: DemoAccount.password,
    );
    for (final post in posts) {
      _users.putIfAbsent(post.author.id, () => _profile(post.author));
      _posts[post.id] = _ServerPost(
        id: post.id,
        authorId: post.author.id,
        content: post.content,
        imageUrl: post.imageUrl,
        createdAt: post.createdAt.add(shift),
        seedLikes: post.likeCount,
      );
      // The seed's `commentCount` is ignored: the count is derived from the
      // comments themselves (see `_postDto`).
    }
    for (final comment in comments) {
      _users.putIfAbsent(comment.author.id, () => _profile(comment.author));
      _comments.add(
        _ServerComment(
          id: comment.id,
          postId: comment.postId,
          authorId: comment.author.id,
          text: comment.text,
          createdAt: comment.createdAt.add(shift),
        ),
      );
    }
    // The seed's chats and notifications are the demo user's. A conversation's
    // last message and time are derived from its messages, like comment
    // counts; its unread count is the server's own state.
    for (final conversation in conversations) {
      final participant = conversation.participant;
      _users.putIfAbsent(participant.id, () => _profile(participant));
      _conversations[conversation.id] = _ServerConversation(
        id: conversation.id,
        ownerId: demo.id,
        participantId: participant.id,
        unreadCount: conversation.unreadCount,
        startedAt: conversation.updatedAt.add(shift),
      );
    }
    for (final message in messages) {
      _messages.add(
        _ServerMessage(
          id: message.id,
          conversationId: message.conversationId,
          senderId: message.senderId == SeedLoader.demoSenderId
              ? demo.id
              : message.senderId,
          text: message.text,
          createdAt: message.createdAt.add(shift),
          seq: _messageSeq++,
        ),
      );
    }
    for (final notification in notifications) {
      _notifications.add(
        _ServerNotification(
          id: notification.id,
          ownerId: demo.id,
          kind: notification.kind,
          text: notification.text,
          createdAt: notification.createdAt.add(shift),
          isRead: notification.isRead,
          postId: notification.postId,
          userId: notification.userId,
        ),
      );
    }
  }

  // ---------------------------------------------------------------------------
  // Helpers

  _ServerPost _post(String postId) =>
      _posts[postId] ?? (throw const NotFoundException());

  UserDto _user(String userId) =>
      _users[userId] ?? (throw const NotFoundException());

  _ServerConversation _conversationOf(String viewerId, String conversationId) {
    final conversation = _conversations[conversationId];
    if (conversation == null || conversation.ownerId != viewerId) {
      throw const NotFoundException();
    }
    return conversation;
  }

  _ServerMessage? _messageById(String messageId) {
    for (final message in _messages) {
      if (message.id == messageId) return message;
    }
    return null;
  }

  /// A conversation's messages, oldest first; the order received breaks
  /// ties.
  List<_ServerMessage> _messagesIn(String conversationId) => [
    for (final message in _messages)
      if (message.conversationId == conversationId) message,
  ]..sort(_ServerMessage.oldestFirst);

  DateTime _updatedAt(_ServerConversation conversation) =>
      _messagesIn(conversation.id).lastOrNull?.createdAt ??
      conversation.startedAt;

  List<_ServerPost> _postsNewestFirst() =>
      _posts.values.toList()..sort(_ServerPost.newestFirst);

  /// A post as [viewerId] sees it. Counts are computed here, on every
  /// response, so they can never disagree with the data (Correctness Rule 3:
  /// the iOS seed claims 18 comments on p1 and ships 3).
  PostDto _postDto(_ServerPost post, String viewerId) => PostDto(
    id: post.id,
    author: _users[post.authorId]!,
    content: post.content,
    imageUrl: post.imageUrl,
    createdAt: post.createdAt,
    likeCount: post.likeCount,
    commentCount: _comments.where((c) => c.postId == post.id).length,
    isLiked: post.likedBy.contains(viewerId),
    bookmarkedAt: post.bookmarks[viewerId],
  );

  /// A conversation as its owner sees it: the last message and its time are
  /// worked out from the messages, so they can never disagree.
  ConversationDto _conversationDto(_ServerConversation conversation) =>
      ConversationDto(
        id: conversation.id,
        participant: _users[conversation.participantId]!,
        lastMessage: _messagesIn(conversation.id).lastOrNull?.text ?? '',
        unreadCount: conversation.unreadCount,
        updatedAt: _updatedAt(conversation),
      );

  MessageDto _messageDto(_ServerMessage message) => MessageDto(
    id: message.id,
    conversationId: message.conversationId,
    senderId: message.senderId,
    text: message.text,
    createdAt: message.createdAt,
  );

  CommentDto _commentDto(_ServerComment comment) => CommentDto(
    id: comment.id,
    postId: comment.postId,
    author: _users[comment.authorId]!,
    text: comment.text,
    createdAt: comment.createdAt,
  );

  AuthResponseDto _authResponse(String email) {
    final userId = _accounts[email]!.userId;
    return AuthResponseDto(
      token: 'fake.$userId.${_ids.hex(16)}',
      user: _ownRecord(userId),
    );
  }

  /// The signed-in user's own record: the only one that includes an email.
  UserDto _ownRecord(String userId) {
    final user = _users[userId]!;
    return UserDto(
      id: user.id,
      name: user.name,
      email: _emailOf(userId),
      avatarUrl: user.avatarUrl,
      bio: user.bio,
      followersCount: user.followersCount,
      followingCount: user.followingCount,
    );
  }

  String? _emailOf(String userId) {
    for (final MapEntry(key: email, value: account) in _accounts.entries) {
      if (account.userId == userId) return email;
    }
    return null;
  }

  /// Search's order for people: the most followed first, then by name.
  static int _mostFollowedFirst(UserDto a, UserDto b) {
    final byFollowers = b.followersCount.compareTo(a.followersCount);
    return byFollowers != 0 ? byFollowers : a.name.compareTo(b.name);
  }

  /// [user] as anyone may see it: everything but the email.
  static UserDto _profile(UserDto user) => UserDto(
    id: user.id,
    name: user.name,
    avatarUrl: user.avatarUrl,
    bio: user.bio,
    followersCount: user.followersCount,
    followingCount: user.followingCount,
  );

  static String _normalize(String email) => email.trim().toLowerCase();

  static String? _userIdIn(String? token) {
    final parts = token?.split('.');
    if (parts == null || parts.length != 3 || parts.first != 'fake') {
      return null;
    }
    return parts[1];
  }
}

/// Server-side account record: which user an email signs in as, and the
/// password it signs in with.
final class _Account {
  const _Account({required this.userId, required this.password});

  final String userId;
  final String password;
}

/// The server's own record of a post. Likes and bookmarks are kept per user,
/// so every viewer gets their own `isLiked` and `bookmarkedAt`.
final class _ServerPost {
  _ServerPost({
    required this.id,
    required this.authorId,
    required this.content,
    required this.imageUrl,
    required this.createdAt,
    required this.seedLikes,
  });

  final String id;
  final String authorId;
  final String content;
  final String? imageUrl;
  final DateTime createdAt;

  /// Likes from people outside this fake world: the seed's count.
  final int seedLikes;

  /// Ids of the users who like the post.
  final likedBy = <String>{};

  /// When each user bookmarked the post, by user id.
  final bookmarks = <String, DateTime>{};

  int get likeCount => seedLikes + likedBy.length;

  /// Newest first, ties broken by id (descending), the feed's order.
  static int newestFirst(_ServerPost a, _ServerPost b) {
    final byTime = b.createdAt.compareTo(a.createdAt);
    return byTime != 0 ? byTime : b.id.compareTo(a.id);
  }
}

/// A comment as the server stores it: authors by id, so a renamed author
/// shows up renamed everywhere.
final class _ServerComment {
  const _ServerComment({
    required this.id,
    required this.postId,
    required this.authorId,
    required this.text,
    required this.createdAt,
  });

  final String id;
  final String postId;
  final String authorId;
  final String text;
  final DateTime createdAt;

  /// Oldest first, ties broken by id: the order a conversation is read in.
  static int oldestFirst(_ServerComment a, _ServerComment b) {
    final byTime = a.createdAt.compareTo(b.createdAt);
    return byTime != 0 ? byTime : a.id.compareTo(b.id);
  }
}

/// A conversation in one user's inbox ([ownerId]), with [participantId].
final class _ServerConversation {
  _ServerConversation({
    required this.id,
    required this.ownerId,
    required this.participantId,
    required this.unreadCount,
    required this.startedAt,
  });

  final String id;
  final String ownerId;
  final String participantId;

  /// Replies the owner hasn't read. Server-owned: a refresh never resets it.
  int unreadCount;

  /// When the conversation began: its time while it has no messages.
  final DateTime startedAt;
}

final class _ServerMessage {
  const _ServerMessage({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.text,
    required this.createdAt,
    required this.seq,
  });

  final String id;
  final String conversationId;
  final String senderId;
  final String text;
  final DateTime createdAt;

  /// The order the server received it in: breaks ties in time.
  final int seq;

  static int oldestFirst(_ServerMessage a, _ServerMessage b) {
    final byTime = a.createdAt.compareTo(b.createdAt);
    return byTime != 0 ? byTime : a.seq.compareTo(b.seq);
  }
}

/// A notification for [ownerId]. Its read state is the server's.
final class _ServerNotification {
  _ServerNotification({
    required this.id,
    required this.ownerId,
    required this.kind,
    required this.text,
    required this.createdAt,
    required this.isRead,
    required this.postId,
    required this.userId,
  });

  final String id;
  final String ownerId;
  final NotificationKindDto kind;
  final String text;
  final DateTime createdAt;
  bool isRead;
  final String? postId;
  final String? userId;

  NotificationDto toDto() => NotificationDto(
    id: id,
    kind: kind,
    text: text,
    createdAt: createdAt,
    isRead: isRead,
    postId: postId,
    userId: userId,
  );
}

/// A position in the feed: "just after this post". Encoded as
/// `<createdAt>|<id>`, which the client treats as an opaque string.
final class const _Cursor(final DateTime createdAt, final String id) {
  _Cursor.at(_ServerPost post) : this(post.createdAt, post.id);

  /// Throws a [FormatException] for anything this server didn't issue (a
  /// real API would answer 400 Bad Request).
  static _Cursor decode(String cursor) {
    final parts = cursor.split('|');
    if (parts.length != 2) throw FormatException('Invalid cursor', cursor);
    return _Cursor(DateTime.parse(parts.first), parts.last);
  }

  String encode() => '${createdAt.toIso8601String()}|$id';

  /// Whether [post] comes after this position in newest-first order.
  bool isNewerThan(_ServerPost post) =>
      post.createdAt.isBefore(createdAt) ||
      (post.createdAt.isAtSameMomentAs(createdAt) && post.id.compareTo(id) < 0);
}
