import 'package:clock/clock.dart';
import 'package:connect_hub/core/common/app_exception.dart';
import 'package:connect_hub/core/common/demo_account.dart';
import 'package:connect_hub/core/common/id_generator.dart';
import 'package:connect_hub/core/network/dto/auth_response_dto.dart';
import 'package:connect_hub/core/network/dto/post_dto.dart';
import 'package:connect_hub/core/network/dto/post_page_dto.dart';
import 'package:connect_hub/core/network/dto/user_dto.dart';
import 'package:connect_hub/core/network/fake_server/seed_loader.dart';
import 'package:injectable/injectable.dart';

/// An in-memory stand-in for ConnectHub's backend.
///
/// It plays the role a REST server would: it owns the data and its rules
/// (accounts, tokens, posts, likes, bookmarks; later comments and chats). The
/// rest of the app reaches it **only** through the `…ApiService` interfaces,
/// so a real HTTP client could replace the fake services without changing
/// any caller.
///
/// It lives in memory and seeds itself from the bundled JSON on first use.
/// Every launch therefore starts from the same seed: accounts created by sign
/// up, likes and bookmarks last until the app restarts. That's deliberate,
/// because the backend is not the point of this project; how the app talks to
/// it is.
///
/// Transport concerns (latency, simulated failures, attaching the token) live
/// in the fake API layer, not here.
@lazySingleton
class FakeServer {
  FakeServer(this._seeds, this._ids, this._clock);

  final SeedLoader _seeds;
  final IdGenerator _ids;
  final Clock _clock;

  Future<void>? _seeding;

  /// Accounts by normalized (trimmed, lower-case) email.
  final _accounts = <String, _Account>{};

  /// Public profiles by user id. Emails live in [_accounts] only, so a post's
  /// author never carries an email address.
  final _users = <String, UserDto>{};

  /// Posts by id.
  final _posts = <String, _ServerPost>{};

  /// Every comment. Phase 3 only counts them; Phase 4 serves them.
  final _comments = <_ServerComment>[];

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

  // ---------------------------------------------------------------------------
  // Seeding

  Future<void> _ready() => _seeding ??= _seed();

  Future<void> _seed() async {
    final demo = await _seeds.loadAuthUser();
    final posts = await _seeds.loadPosts();
    final comments = await _seeds.loadComments();

    // The seed's dates are fixed (July 2026). Shift them all by the same
    // amount, so the newest record is a few minutes old whenever the app
    // launches and the feed always looks fresh. The gaps between records
    // stay as they are in the seed.
    final newest = [
      for (final post in posts) post.createdAt,
      for (final comment in comments) comment.createdAt,
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
  }

  // ---------------------------------------------------------------------------
  // Helpers

  _ServerPost _post(String postId) =>
      _posts[postId] ?? (throw const NotFoundException());

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

  /// The signed-in user's own record is the only one that includes an email.
  AuthResponseDto _authResponse(String email) {
    final account = _accounts[email]!;
    final user = _users[account.userId]!;
    return AuthResponseDto(
      token: 'fake.${account.userId}.${_ids.hex(16)}',
      user: UserDto(
        id: user.id,
        name: user.name,
        email: email,
        avatarUrl: user.avatarUrl,
        bio: user.bio,
        followersCount: user.followersCount,
        followingCount: user.followingCount,
      ),
    );
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
