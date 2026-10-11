import 'package:connect_hub/core/database/app_database.dart';
import 'package:connect_hub/core/database/daos/search_dao.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/backend.dart';
import '../../helpers/database_rows.dart';

void main() {
  late AppDatabase database;
  late SearchDao dao;

  setUp(() {
    database = newTestDatabase();
    dao = database.searchDao;
  });

  tearDown(() => database.close());

  group('recent searches', () {
    /// Saves each query a minute after the one before.
    Future<void> saveInTurn(List<String> queries) async {
      for (final (i, query) in queries.indexed) {
        await dao.saveRecentSearch(
          query,
          at: testNow.add(Duration(minutes: i)),
        );
      }
    }

    Future<List<String>> recent() async => [
      for (final row in await dao.watchRecentSearches().first) row.displayText,
    ];

    test('come newest first, trimmed; a blank query is never saved', () async {
      await saveInTurn(['  ada ', 'grace', '   ']);

      expect(await recent(), ['grace', 'ada']);
    });

    test('are one entry per query ignoring case: searching it again moves '
        'it to the top, spelled the latest way', () async {
      await saveInTurn(['Ada', 'grace', 'ADA ']);

      expect(await recent(), ['ADA', 'grace']);
    });

    test('keep only the ${SearchDao.maxRecentSearches} newest', () async {
      await saveInTurn([for (var i = 1; i <= 12; i++) 'query $i']);

      expect(await recent(), [for (var i = 12; i >= 3; i--) 'query $i']);
      expect(
        await database.select(database.recentSearches).get(),
        hasLength(SearchDao.maxRecentSearches),
      );
    });

    test('clearRecentSearches removes them all', () async {
      await saveInTurn(['ada', 'grace']);

      await dao.clearRecentSearches();

      expect(await recent(), isEmpty);
    });
  });

  group('results', () {
    test('cacheResults caches people and posts, but never adds a post to '
        'the feed', () async {
      await dao.cacheResults(
        people: [userRow('u_alan')],
        posts: [cachedPost('p1')],
      );

      expect(await database.select(database.users).get(), hasLength(2));
      expect(await database.select(database.posts).get(), hasLength(1));
      expect(await database.feedDao.watchFeed().first, isEmpty);
    });

    test(
      'watchUsers and watchPosts read back exactly the ids asked for',
      () async {
        await dao.cacheResults(
          people: [userRow('u_alan'), userRow('u_grace')],
          posts: [
            cachedPost('p1', bookmarkedAt: testNow),
            cachedPost('p2'),
          ],
        );

        final people = await dao.watchUsers(['u_grace', 'u_nobody']).first;
        expect(people.map((row) => row.id), ['u_grace']);
        final posts = await dao.watchPosts(['p1']).first;
        expect(posts.single.author.id, 'u_ada');
        expect(posts.single.bookmarkedAt, testNow);
        expect(await dao.watchPosts(const []).first, isEmpty);
      },
    );
  });
}
