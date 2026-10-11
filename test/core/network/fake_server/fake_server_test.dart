import 'package:async/async.dart';
import 'package:clock/clock.dart';
import 'package:connect_hub/core/common/app_exception.dart';
import 'package:connect_hub/core/common/demo_account.dart';
import 'package:connect_hub/core/network/asset_json_loader.dart';
import 'package:connect_hub/core/network/dto/chat_event_dto.dart';
import 'package:connect_hub/core/network/dto/create_post_request_dto.dart';
import 'package:connect_hub/core/network/dto/post_dto.dart';
import 'package:connect_hub/core/network/dto/update_profile_request_dto.dart';
import 'package:connect_hub/core/network/fake_server/fake_server.dart';
import 'package:connect_hub/core/network/fake_server/seed_loader.dart';
import 'package:connect_hub/domain/model/app_notification.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/backend.dart';
import '../../../helpers/stream_helpers.dart';

void main() {
  // The real bundled seed JSON, read through the test asset bundle.
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakeServer server;

  setUp(() => server = newFakeServer());
  tearDown(() => server.dispose());

  /// Every post, page by page, as [viewer] sees them.
  Future<List<PostDto>> allPosts({String viewer = 'u_demo'}) async {
    final posts = <PostDto>[];
    String? cursor;
    do {
      final page = await server.getFeed(viewer, cursor: cursor, limit: 6);
      posts.addAll(page.posts);
      cursor = page.nextCursor;
    } while (cursor != null);
    return posts;
  }

  Future<PostDto> post(String id, {String viewer = 'u_demo'}) async =>
      (await allPosts(viewer: viewer)).singleWhere((post) => post.id == id);

  group('seed', () {
    test("the demo user's seed email is the demo account's", () async {
      final demo = await SeedLoader(AssetJsonLoader(rootBundle)).loadAuthUser();

      expect(demo.email, DemoAccount.email);
      expect(demo.id, 'u_demo');
      expect(demo.name, 'Demo User');
    });

    test('the 15 iOS posts plus the demo user\'s 2 are all served', () async {
      final posts = await allPosts();

      expect(posts, hasLength(17));
      expect(
        posts.where((post) => post.author.id == 'u_demo').map((p) => p.id),
        ['p16', 'p17'],
      );
    });

    test('dates are rebased so the newest seed record is five minutes old, '
        'and the gaps between records are kept', () async {
      final posts = await allPosts();
      DateTime createdAt(String id) =>
          posts.singleWhere((post) => post.id == id).createdAt;

      // The newest seed record, across every file, is notification n1
      // (July 24, 11:10). p1 was posted 2h55m before it, and p2 1h35m
      // before p1.
      final newest = testNow.subtract(FakeServer.newestSeedAge);
      expect(
        createdAt('p1'),
        newest.subtract(const Duration(hours: 2, minutes: 55)),
      );
      expect(
        createdAt('p1').difference(createdAt('p2')),
        const Duration(hours: 1, minutes: 35),
      );
      final notifications = await server.getNotifications('u_demo');
      expect(notifications.first.id, 'n1');
      expect(notifications.first.createdAt, newest);
    });

    test('comment counts are derived from the comments, not the seed\'s '
        'numbers', () async {
      final posts = {for (final post in await allPosts()) post.id: post};

      // The iOS seed claims 18 comments on p1, 64 on p2 and 129 on p5.
      expect(posts['p1']!.commentCount, 3);
      expect(posts['p2']!.commentCount, 3);
      expect(posts['p5']!.commentCount, 2);
      expect(posts['p16']!.commentCount, 1);
      expect(posts['p4']!.commentCount, 0);
    });

    test('authors are public profiles: they never carry an email', () async {
      final posts = await allPosts();

      expect(posts.map((post) => post.author.email), everyElement(isNull));
      expect((await post('p16')).author.name, 'Demo User');
    });
  });

  group('feed pages', () {
    test('come newest first, in pages of 6 / 6 / 5 with no overlap', () async {
      final first = await server.getFeed('u_demo', limit: 6);
      final second = await server.getFeed(
        'u_demo',
        cursor: first.nextCursor,
        limit: 6,
      );
      final third = await server.getFeed(
        'u_demo',
        cursor: second.nextCursor,
        limit: 6,
      );

      List<String> ids(List<PostDto> posts) => [for (final p in posts) p.id];
      expect(ids(first.posts), ['p1', 'p2', 'p3', 'p16', 'p4', 'p5']);
      expect(ids(second.posts), ['p6', 'p7', 'p17', 'p8', 'p9', 'p10']);
      expect(ids(third.posts), ['p11', 'p12', 'p13', 'p14', 'p15']);
      expect(first.nextCursor, isNotNull);
      expect(second.nextCursor, isNotNull);
      expect(third.nextCursor, isNull);
    });

    test(
      'a page that ends exactly at the last post has no next cursor',
      () async {
        final everything = await server.getFeed('u_demo', limit: 17);

        expect(everything.posts, hasLength(17));
        expect(everything.nextCursor, isNull);
      },
    );

    test('a cursor it never issued is rejected', () {
      expect(
        server.getFeed('u_demo', cursor: 'page-2', limit: 6),
        throwsFormatException,
      );
    });
  });

  group('likes', () {
    test('liking adds one like, and liking again changes nothing', () async {
      final liked = await server.setLiked('u_demo', 'p1', liked: true);
      final again = await server.setLiked('u_demo', 'p1', liked: true);

      expect(liked.isLiked, isTrue);
      expect(liked.likeCount, 143);
      expect(again.likeCount, 143);
    });

    test('unliking removes the like', () async {
      await server.setLiked('u_demo', 'p1', liked: true);

      final unliked = await server.setLiked('u_demo', 'p1', liked: false);

      expect(unliked.isLiked, isFalse);
      expect(unliked.likeCount, 142);
    });

    test(
      "are per user: others see the count, not the viewer's heart",
      () async {
        await server.setLiked('u_demo', 'p1', liked: true);

        final seenByOther = await post('p1', viewer: 'u_other');

        expect(seenByOther.likeCount, 143);
        expect(seenByOther.isLiked, isFalse);
        expect((await post('p1')).isLiked, isTrue);
      },
    );

    test('an unknown post is not found', () {
      expect(
        server.setLiked('u_demo', 'p999', liked: true),
        throwsA(isA<NotFoundException>()),
      );
    });
  });

  group('bookmarks', () {
    test('are per user and remember when they were made', () async {
      final bookmarked = await server.setBookmarked(
        'u_demo',
        'p3',
        bookmarked: true,
      );

      expect(bookmarked.bookmarkedAt, testNow);
      expect((await post('p3', viewer: 'u_other')).bookmarkedAt, isNull);
    });

    test(
      'bookmarking again keeps the original time; removing clears it',
      () async {
        var now = testNow;
        server = newFakeServer(clock: Clock(() => now));
        await server.setBookmarked('u_demo', 'p3', bookmarked: true);

        now = now.add(const Duration(hours: 1));
        final repeated = await server.setBookmarked(
          'u_demo',
          'p3',
          bookmarked: true,
        );
        expect(repeated.bookmarkedAt, testNow);

        final removed = await server.setBookmarked(
          'u_demo',
          'p3',
          bookmarked: false,
        );
        expect(removed.bookmarkedAt, isNull);
      },
    );

    test("the list is the viewer's own, the most recently bookmarked "
        'first', () async {
      var now = testNow;
      server = newFakeServer(clock: Clock(() => now));
      expect(await server.getBookmarks('u_demo'), isEmpty);

      for (final id in ['p7', 'p2', 'p12']) {
        await server.setBookmarked('u_demo', id, bookmarked: true);
        now = now.add(const Duration(minutes: 1));
      }
      await server.setBookmarked('u_other', 'p5', bookmarked: true);

      final bookmarks = await server.getBookmarks('u_demo');
      expect(bookmarks.map((post) => post.id), ['p12', 'p2', 'p7']);
      expect(bookmarks.every((post) => post.bookmarkedAt != null), isTrue);
    });
  });

  group('users', () {
    test('a profile is public: no email', () async {
      final ada = await server.getUser('u_ada');

      expect(ada.name, 'Ada Lovelace');
      expect(ada.bio, 'Enchantress of numbers.');
      expect(ada.followersCount, 4820);
      expect(ada.email, isNull);
    });

    test("a user's posts: all of them, newest first", () async {
      final posts = await server.getUserPosts('u_demo', 'u_ada');

      expect(posts.map((post) => post.id), ['p1', 'p6', 'p11']);
    });

    test("a user's posts come as the viewer sees them", () async {
      await server.setLiked('u_demo', 'p6', liked: true);

      final posts = await server.getUserPosts('u_demo', 'u_ada');

      expect(posts.singleWhere((post) => post.id == 'p6').isLiked, isTrue);
    });

    test('an unknown user, and so their posts, are not found', () {
      expect(server.getUser('u_nobody'), throwsA(isA<NotFoundException>()));
      expect(
        server.getUserPosts('u_demo', 'u_nobody'),
        throwsA(isA<NotFoundException>()),
      );
    });
  });

  group('update profile', () {
    const request = UpdateProfileRequestDto(
      name: '  Demo Person ',
      bio: ' Testing time-based logic. ',
      avatarUrl: ' https://example.com/me.png ',
    );

    test('saves trimmed values and answers with my own record', () async {
      final me = await server.updateMe('u_demo', request);

      expect(me.name, 'Demo Person');
      expect(me.bio, 'Testing time-based logic.');
      expect(me.avatarUrl, 'https://example.com/me.png');
      expect(me.email, DemoAccount.email);
      // Counts aren't the user's to edit.
      expect(me.followersCount, 128);
    });

    test('renames me on every post and comment I ever wrote', () async {
      await server.updateMe('u_demo', request);

      final p16 = await server.getPost('u_demo', 'p16');
      expect(p16.author.name, 'Demo Person');
      expect(p16.author.avatarUrl, 'https://example.com/me.png');
      final comment = await server.addComment('u_demo', 'p1', 'Hi');
      expect(comment.author.name, 'Demo Person');
      expect((await server.getUser('u_demo')).name, 'Demo Person');
    });

    test('an empty avatar URL removes the picture', () async {
      final me = await server.updateMe(
        'u_demo',
        const UpdateProfileRequestDto(
          name: 'Demo User',
          bio: '',
          avatarUrl: '',
        ),
      );

      expect(me.avatarUrl, isNull);
      expect(me.bio, isEmpty);
    });

    test('a request that breaks the rules is rejected (a 400)', () {
      for (final invalid in [
        const UpdateProfileRequestDto(name: ' D ', bio: ''),
        UpdateProfileRequestDto(name: 'Demo', bio: 'a' * 161),
        const UpdateProfileRequestDto(
          name: 'Demo',
          bio: '',
          avatarUrl: 'not a url',
        ),
      ]) {
        expect(
          server.updateMe('u_demo', invalid),
          throwsA(isA<FormatException>()),
        );
      }
    });
  });

  group('search', () {
    /// Searches as the demo user and checks the ids found, in order.
    Future<void> expectFound(
      String query, {
      List<String> people = const [],
      List<String> posts = const [],
    }) async {
      final response = await server.search('u_demo', query);
      expect(
        [for (final user in response.users) user.id],
        people,
        reason: 'people matching "$query"',
      );
      expect(
        [for (final post in response.posts) post.id],
        posts,
        reason: 'posts matching "$query"',
      );
    }

    test(
      'finds people by name and posts by their author, ignoring case',
      () async {
        await expectFound('ada', people: ['u_ada'], posts: ['p1', 'p6', 'p11']);
        await expectFound(
          '  ADA ',
          people: ['u_ada'],
          posts: ['p1', 'p6', 'p11'],
        );
      },
    );

    test('finds people by bio, and posts by content', () async {
      await expectFound('moon', people: ['u_katherine']);
      await expectFound('cache', posts: ['p15']);
    });

    test(
      'lists the most followed people first, and posts newest first',
      () async {
        final response = await server.search('u_demo', 'in');

        expect(response.users.map((user) => user.id), [
          'u_linus',
          'u_alan',
          'u_katherine',
        ]);
        expect(response.posts.take(4).map((post) => post.id), [
          'p1',
          'p2',
          'p3',
          'p16',
        ]);
      },
    );

    test('leaves the viewer out of the people, not out of the posts', () async {
      await expectFound('demo', posts: ['p16', 'p17', 'p8']);
    });

    test('a blank query, or one nothing matches, finds nothing', () async {
      await expectFound('   ');
      await expectFound('zzz');
    });
  });
  group('one post', () {
    test('comes as the viewer sees it', () async {
      await server.setLiked('u_demo', 'p3', liked: true);

      final post = await server.getPost('u_demo', 'p3');

      expect(post.id, 'p3');
      expect(post.isLiked, isTrue);
      expect(post.commentCount, 2);
    });

    test('an unknown one is not found', () {
      expect(
        server.getPost('u_demo', 'p999'),
        throwsA(isA<NotFoundException>()),
      );
    });
  });

  group('create post', () {
    test(
      'publishes it as the viewer, trimmed, at the top of the first page',
      () async {
        final created = await server.createPost(
          'u_demo',
          const CreatePostRequestDto(
            content: '  Hello, ConnectHub!  ',
            imageUrl: ' https://picsum.photos/600/400 ',
          ),
        );

        expect(created.author.id, 'u_demo');
        expect(created.content, 'Hello, ConnectHub!');
        expect(created.imageUrl, 'https://picsum.photos/600/400');
        expect(created.createdAt, testNow);
        expect(created.likeCount, 0);
        expect(created.commentCount, 0);
        final firstPage = await server.getFeed('u_demo', limit: 6);
        expect(firstPage.posts.first.id, created.id);
      },
    );

    test('an empty image URL means no image', () async {
      final created = await server.createPost(
        'u_demo',
        const CreatePostRequestDto(content: 'No picture', imageUrl: ''),
      );

      expect(created.imageUrl, isNull);
    });

    test('a request that breaks the rules is rejected (a 400)', () {
      for (final request in [
        const CreatePostRequestDto(content: '   '),
        CreatePostRequestDto(content: 'a' * 281),
        const CreatePostRequestDto(content: 'Hi', imageUrl: 'not a url'),
      ]) {
        expect(
          server.createPost('u_demo', request),
          throwsFormatException,
          reason: request.content,
        );
      }
    });
  });

  group('comments', () {
    test('come oldest first, each with its author', () async {
      final comments = await server.getComments('p1');

      expect([for (final c in comments) c.id], ['c1', 'c2', 'c3']);
      expect(comments.first.author.name, 'Grace Hopper');
    });

    test('an unknown post has no comments to list', () {
      expect(server.getComments('p999'), throwsA(isA<NotFoundException>()));
    });

    test(
      'adding one stores it trimmed, as the viewer, and counts it',
      () async {
        final comment = await server.addComment(
          'u_demo',
          'p4',
          '  Great point!  ',
        );

        expect(comment.text, 'Great point!');
        expect(comment.author.id, 'u_demo');
        expect(comment.createdAt, testNow);
        expect((await server.getPost('u_demo', 'p4')).commentCount, 1);
        expect((await server.getComments('p4')).single.id, comment.id);
      },
    );

    test('a blank or too long comment is rejected (a 400)', () {
      expect(server.addComment('u_demo', 'p4', '  '), throwsFormatException);
      expect(
        server.addComment('u_demo', 'p4', 'a' * 281),
        throwsFormatException,
      );
    });

    test('only its author may delete it: anyone else gets a 404', () async {
      final mine = await server.addComment('u_demo', 'p4', 'Mine');

      expect(
        server.deleteComment('u_other', mine.id),
        throwsA(isA<NotFoundException>()),
      );
      // c1 is Grace Hopper's.
      expect(
        server.deleteComment('u_demo', 'c1'),
        throwsA(isA<NotFoundException>()),
      );

      await server.deleteComment('u_demo', mine.id);
      expect((await server.getPost('u_demo', 'p4')).commentCount, 0);
    });
  });

  group('login', () {
    test('the demo account signs in and gets a token for its user', () async {
      final response = await server.login(
        email: DemoAccount.email,
        password: DemoAccount.password,
      );

      expect(response.user.id, 'u_demo');
      expect(response.user.email, DemoAccount.email);
      expect(response.token, startsWith('fake.u_demo.'));
    });

    test('the email is matched ignoring case and surrounding spaces', () async {
      final response = await server.login(
        email: '  DEMO@ConnectHub.App ',
        password: DemoAccount.password,
      );

      expect(response.user.id, 'u_demo');
    });

    test('a wrong password and an unknown email fail the same way', () {
      expect(
        server.login(email: DemoAccount.email, password: 'wrong-password'),
        throwsA(isA<InvalidCredentialsException>()),
      );
      expect(
        server.login(email: 'nobody@example.com', password: 'whatever'),
        throwsA(isA<InvalidCredentialsException>()),
      );
    });
  });

  group('sign up', () {
    test('creates an account that can then sign in', () async {
      final created = await server.signUp(
        name: '  Ada Lovelace ',
        email: 'Ada@Example.com',
        password: 'engines',
      );

      expect(created.user.name, 'Ada Lovelace');
      expect(created.user.email, 'ada@example.com');
      expect(created.user.bio, 'New to ConnectHub 👋');
      expect(created.user.avatarUrl, isNull);
      expect(created.user.followersCount, 0);
      expect(created.user.followingCount, 0);

      final signedIn = await server.login(
        email: 'ada@example.com',
        password: 'engines',
      );
      expect(signedIn.user.id, created.user.id);
    });

    test('rejects an email that already has an account, in any case', () {
      expect(
        server.signUp(
          name: 'Impostor',
          email: 'Demo@ConnectHub.app',
          password: 'secret1',
        ),
        throwsA(isA<EmailTakenException>()),
      );
    });
  });

  group('tokens', () {
    test('a token it issued resolves to its user', () async {
      final response = await server.login(
        email: DemoAccount.email,
        password: DemoAccount.password,
      );

      expect(await server.authenticate(response.token), 'u_demo');
    });

    test('a missing or malformed token is rejected', () {
      for (final token in [
        null,
        '',
        'garbage',
        'jwt.u_demo.x',
        'fake.u_demo',
      ]) {
        expect(
          server.authenticate(token),
          throwsA(isA<UnauthorizedException>()),
          reason: 'token: $token',
        );
      }
    });

    test('a revoked token is rejected', () async {
      final response = await server.login(
        email: DemoAccount.email,
        password: DemoAccount.password,
      );

      server.revoke(response.token);

      expect(
        server.authenticate(response.token),
        throwsA(isA<UnauthorizedException>()),
      );
    });

    test(
      'the demo session survives a restart, a signed-up one does not',
      () async {
        final demo = await server.login(
          email: DemoAccount.email,
          password: DemoAccount.password,
        );
        final created = await server.signUp(
          name: 'Ada',
          email: 'ada@example.com',
          password: 'engines',
        );

        // A new server instance is what the next app launch sees.
        final restarted = newFakeServer();

        expect(await restarted.authenticate(demo.token), 'u_demo');
        expect(
          restarted.authenticate(created.token),
          throwsA(isA<UnauthorizedException>()),
        );
      },
    );
  });

  group('chat', () {
    test("the demo user's conversations, the most recent activity first, "
        'with their seeded unread counts', () async {
      final conversations = await server.getConversations('u_demo');

      expect(conversations.map((c) => c.id), ['c1', 'c2', 'c3']);
      expect(conversations.map((c) => c.unreadCount), [2, 0, 1]);
      expect(conversations.first.participant.name, 'Grace Hopper');
      expect(
        conversations.first.lastMessage,
        'Approved with 12 comments, as tradition demands.',
      );
    });

    test('a new account has no conversations', () async {
      final account = await server.signUp(
        name: 'Ada',
        email: 'ada@example.com',
        password: 'engines',
      );

      expect(await server.getConversations(account.user.id), isEmpty);
    });

    test("a conversation's messages run oldest first; the seed's \"me\" is "
        'the demo user', () async {
      final messages = await server.getMessages('u_demo', 'c1');

      expect(messages.map((m) => m.id), ['m1', 'm2', 'm3', 'm4']);
      expect(messages.map((m) => m.senderId), [
        'u_grace',
        'u_demo',
        'u_grace',
        'u_grace',
      ]);
    });

    test(
      "someone else's conversation, like an unknown one, answers 404",
      () async {
        expect(
          server.getMessages('u_ada', 'c1'),
          throwsA(isA<NotFoundException>()),
        );
        expect(
          server.getMessages('u_demo', 'c404'),
          throwsA(isA<NotFoundException>()),
        );
      },
    );

    test("a message keeps the client's id, and sending that id again "
        'stores nothing new (an idempotent retry)', () async {
      final first = await server.sendMessage(
        'u_demo',
        'c2',
        clientId: 'm_client',
        text: '  Hello  ',
      );
      final again = await server.sendMessage(
        'u_demo',
        'c2',
        clientId: 'm_client',
        text: 'Hello',
      );

      expect(first.id, 'm_client');
      expect(first.text, 'Hello');
      expect(again.createdAt, first.createdAt);
      final ids = (await server.getMessages('u_demo', 'c2')).map((m) => m.id);
      expect(ids.where((id) => id == 'm_client'), hasLength(1));
      expect(ids.last, 'm_client');
    });

    test("a blank message, or an id that is someone else's message, is "
        'refused', () async {
      expect(
        server.sendMessage('u_demo', 'c2', clientId: 'm_a', text: '   '),
        throwsA(isA<FormatException>()),
      );
      // m1 is Grace's.
      expect(
        server.sendMessage('u_demo', 'c1', clientId: 'm1', text: 'Hi'),
        throwsA(isA<FormatException>()),
      );
    });

    test('marking a conversation read zeroes its unread count', () async {
      await server.markConversationRead('u_demo', 'c1');

      final c1 = (await server.getConversations('u_demo'))
          .firstWhere((c) => c.id == 'c1');
      expect(c1.unreadCount, 0);
    });

    group('replies', () {
      // Replies in real time, within a millisecond. (The scheduler's own
      // timing is tested in fake time: `reply_scheduler_test.dart`.)
      setUp(() {
        server.dispose();
        server = newFakeServer(replies: quickReplies());
      });

      test('the other person types, then answers: the reply raises the '
          'unread count and arrives on the realtime channel', () async {
        final events = StreamQueue(server.chatEvents('u_demo'));
        addTearDown(events.cancel);

        await server.sendMessage('u_demo', 'c2', clientId: 'm_a', text: 'Hi');

        expect(await nextEvent(events), isA<TypingStartedEvent>());
        final reply = await nextEvent(events) as MessageReceivedEvent;
        expect(reply.message.text, FakeServer.cannedReplies.first);
        expect(reply.message.senderId, 'u_alan');
        expect(reply.conversation.unreadCount, 1);
        expect(reply.conversation.lastMessage, reply.message.text);
        expect(await nextEvent(events), isA<TypingStoppedEvent>());
        final c2 = (await server.getConversations('u_demo')).first;
        expect(c2.id, 'c2', reason: 'the latest activity comes first');
      });

      test('a question gets the question reply; anything else gets the '
          'canned replies in turn', () async {
        final events = StreamQueue(
          server.chatEvents('u_demo').where((e) => e is MessageReceivedEvent),
        );
        addTearDown(events.cancel);
        final replies = <String>[];

        for (final (id, text) in [
          ('m_a', 'Ready?'),
          ('m_b', 'Ok'),
          ('m_c', 'Sure'),
        ]) {
          await server.sendMessage('u_demo', 'c2', clientId: id, text: text);
          final reply = await nextEvent(events) as MessageReceivedEvent;
          replies.add(reply.message.text);
        }

        expect(replies, [
          FakeServer.questionReply,
          FakeServer.cannedReplies[0],
          FakeServer.cannedReplies[1],
        ]);
      });

      test('a retried message gets no second reply', () async {
        final stopped = StreamQueue(
          server.chatEvents('u_demo').where((e) => e is TypingStoppedEvent),
        );
        addTearDown(stopped.cancel);

        await server.sendMessage('u_demo', 'c2', clientId: 'm_a', text: 'Hi');
        await server.sendMessage('u_demo', 'c2', clientId: 'm_a', text: 'Hi');
        // Typing stops after the last reply on its way.
        await nextEvent(stopped);

        // The seed's 3, mine, and one reply.
        expect(await server.getMessages('u_demo', 'c2'), hasLength(5));
      });

      test("the channel carries only the viewer's own conversations", () async {
        final someoneElses = <ChatEventDto>[];
        final subscription = server
            .chatEvents('u_ada')
            .listen(someoneElses.add);
        addTearDown(subscription.cancel);
        final stopped = StreamQueue(
          server.chatEvents('u_demo').where((e) => e is TypingStoppedEvent),
        );
        addTearDown(stopped.cancel);

        await server.sendMessage('u_demo', 'c2', clientId: 'm_a', text: 'Hi');
        await nextEvent(stopped);

        expect(someoneElses, isEmpty);
      });
    });
  });

  group('notifications', () {
    test('newest first, with their read state and links', () async {
      final notifications = await server.getNotifications('u_demo');

      expect(notifications.map((n) => n.id), [
        'n1',
        'n2',
        'n3',
        'n4',
        'n5',
        'n6',
        'n7',
        'n8',
      ]);
      expect(notifications.where((n) => !n.isRead).map((n) => n.id), [
        'n1',
        'n2',
        'n3',
      ]);
      expect(notifications[0].postId, 'p16');
      expect(notifications[2].userId, 'u_katherine');
      expect(notifications[5].postId, isNull);
      expect(notifications[5].userId, isNull);
      expect(notifications.first.kind.name, NotificationKind.like.name);
    });

    test(
      'the read state belongs to the server: marking one read sticks',
      () async {
        await server.markNotificationRead('u_demo', 'n1');
        // Idempotent.
        await server.markNotificationRead('u_demo', 'n1');

        final n1 = (await server.getNotifications('u_demo')).first;
        expect(n1.isRead, isTrue);
      },
    );

    test(
      "someone else's notification, like an unknown one, answers 404",
      () async {
        expect(
          server.markNotificationRead('u_ada', 'n1'),
          throwsA(isA<NotFoundException>()),
        );
        expect(
          server.markNotificationRead('u_demo', 'n404'),
          throwsA(isA<NotFoundException>()),
        );
      },
    );

    test('mark all read', () async {
      await server.markAllNotificationsRead('u_demo');

      final notifications = await server.getNotifications('u_demo');
      expect(notifications.every((n) => n.isRead), isTrue);
    });
  });
}
