import 'package:connect_hub/core/common/app_exception.dart';
import 'package:connect_hub/core/common/result.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/data_stack.dart';
import '../../helpers/database_rows.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late DataStack backend;

  setUp(() => backend = DataStack());

  tearDown(() => backend.dispose());

  Matcher isErr(Matcher exception) =>
      isA<Err<void>>().having((err) => err.exception, 'exception', exception);

  Future<List<String>> postIdsBy(String userId) async => [
    for (final post in await backend.profiles.watchUserPosts(userId).first)
      post.id,
  ];

  group('a profile', () {
    test('refreshUser caches it', () async {
      expect(await backend.profiles.watchUser('u_ada').first, isNull);

      expect(await backend.profiles.refreshUser('u_ada'), isA<Ok<void>>());

      final ada = await backend.profiles.watchUser('u_ada').first;
      expect(ada?.name, 'Ada Lovelace');
      expect(ada?.followersCount, 4820);
    });

    test('an unknown user is not found, and nothing is cached', () async {
      final result = await backend.profiles.refreshUser('u_nobody');

      expect(result, isErr(isA<NotFoundException>()));
      expect(await backend.profiles.watchUser('u_nobody').first, isNull);
    });
  });

  group("a user's posts", () {
    test('refreshUserPosts caches all of them, newest first, without '
        'touching the feed', () async {
      await backend.feed.refresh();
      final feedBefore = await backend.feedIds();

      await backend.profiles.refreshUserPosts('u_ada');

      expect(await postIdsBy('u_ada'), ['p1', 'p6', 'p11']);
      expect(await backend.feedIds(), feedBefore);
    });

    test('mirror the server: a cached post it no longer has goes', () async {
      await backend.database.postsDao.upsertPosts([cachedPost('p_gone')]);

      await backend.profiles.refreshUserPosts('u_ada');

      expect(await postIdsBy('u_ada'), isNot(contains('p_gone')));
    });

    test("an unknown user's cached posts go too", () async {
      await backend.database.postsDao.upsertPosts([
        cachedPost('p_x', authorId: 'u_nobody'),
      ]);

      final result = await backend.profiles.refreshUserPosts('u_nobody');

      expect(result, isErr(isA<NotFoundException>()));
      expect(await postIdsBy('u_nobody'), isEmpty);
    });
  });

  group('update profile', () {
    test('saves through the server, and every post and comment I wrote '
        'shows the new name at once (they JOIN my row)', () async {
      await backend.feed.refresh();
      await backend.comments.addComment('p1', 'Hi');

      final result = await backend.profiles.updateProfile(
        name: 'Demo Person',
        bio: 'Testing time-based logic.',
        avatarUrl: 'https://example.com/me.png',
      );

      expect(result, isA<Ok<void>>());
      final feed = await backend.feed.watchFeed().first;
      final p16 = feed.singleWhere((post) => post.id == 'p16');
      expect(p16.author.name, 'Demo Person');
      expect(p16.author.avatarUrl, 'https://example.com/me.png');
      final comments = await backend.comments.watchComments('p1').first;
      expect(comments.last.author.name, 'Demo Person');
      expect((await backend.server.getUser('u_demo')).name, 'Demo Person');
    });

    test('a profile the server refuses changes nothing', () async {
      await backend.profiles.refreshUser('u_demo');

      final result = await backend.profiles.updateProfile(name: 'D', bio: '');

      expect(result, isErr(isA<UnknownException>()));
      final me = await backend.profiles.watchUser('u_demo').first;
      expect(me?.name, 'Demo User');
    });

    test('a failure says why, and changes nothing', () async {
      await backend.profiles.refreshUser('u_demo');
      backend.network.failRequests = true;

      final result = await backend.profiles.updateProfile(
        name: 'Demo Person',
        bio: '',
      );

      expect(result, isErr(isA<NetworkException>()));
      final me = await backend.profiles.watchUser('u_demo').first;
      expect(me?.name, 'Demo User');
    });
  });
}
