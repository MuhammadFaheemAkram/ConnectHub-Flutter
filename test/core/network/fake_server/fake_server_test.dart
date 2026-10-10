import 'package:clock/clock.dart';
import 'package:connect_hub/core/common/app_exception.dart';
import 'package:connect_hub/core/common/demo_account.dart';
import 'package:connect_hub/core/network/asset_json_loader.dart';
import 'package:connect_hub/core/network/dto/post_dto.dart';
import 'package:connect_hub/core/network/fake_server/fake_server.dart';
import 'package:connect_hub/core/network/fake_server/seed_loader.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/backend.dart';

void main() {
  // The real bundled seed JSON, read through the test asset bundle.
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakeServer server;

  setUp(() => server = newFakeServer());

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

      // The newest seed record is comment c13 (July 24, 10:30). p1 was
      // posted 2h15m before it, and p2 1h35m before p1.
      final newest = testNow.subtract(FakeServer.newestSeedAge);
      expect(
        createdAt('p1'),
        newest.subtract(const Duration(hours: 2, minutes: 15)),
      );
      expect(
        createdAt('p1').difference(createdAt('p2')),
        const Duration(hours: 1, minutes: 35),
      );
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
}
