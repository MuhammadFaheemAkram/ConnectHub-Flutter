import 'package:async/async.dart';
import 'package:clock/clock.dart';
import 'package:connect_hub/core/common/app_exception.dart';
import 'package:connect_hub/core/common/result.dart';
import 'package:connect_hub/domain/model/search_hits.dart';
import 'package:connect_hub/domain/model/search_results.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/backend.dart';
import '../../helpers/data_stack.dart';
import '../../helpers/stream_helpers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late DataStack backend;
  var now = testNow;

  setUp(() {
    now = testNow;
    backend = DataStack(clientClock: Clock(() => now));
  });

  tearDown(() => backend.dispose());

  Future<SearchHits> search(String query) async =>
      switch (await backend.search.search(query)) {
        Ok(:final value) => value,
        Err(:final exception) => throw exception,
      };

  group('search', () {
    test("returns what matched as ids, in the server's order", () async {
      final hits = await search('in');

      expect(hits.userIds, ['u_linus', 'u_alan', 'u_katherine']);
      expect(hits.postIds.take(3), ['p1', 'p2', 'p3']);
    });

    test('caches the results, but never adds a post to the feed', () async {
      await backend.feed.refresh();
      final feedBefore = await backend.feedIds();

      await search('cache');

      expect(await backend.posts.watchPost('p15').first, isNotNull);
      expect(await backend.feedIds(), feedBefore);
    });

    test('a failed search caches nothing and says why', () async {
      backend.network.failRequests = true;

      final result = await backend.search.search('ada');

      expect(
        result,
        isA<Err<SearchHits>>().having(
          (err) => err.exception,
          'exception',
          isA<NetworkException>(),
        ),
      );
      final cachedPosts = backend.database.select(backend.database.posts);
      expect(await cachedPosts.get(), isEmpty);
    });
  });

  group('results', () {
    test("are read back from the cache in the server's order", () async {
      final results = await backend.search
          .watchResults(await search('in'))
          .first;

      expect(results.users.map((user) => user.name), [
        'Linus T.',
        'Alan Turing',
        'Katherine Johnson',
      ]);
      expect(results.posts.first.id, 'p1');
    });

    test('are live: a like made on another screen shows at once', () async {
      final queue = StreamQueue(
        backend.search.watchResults(await search('ada')),
      );
      final before = (await nextEvent(queue)).posts.first;
      expect(before.isLiked, isFalse);

      await backend.posts.setLiked(before.id, liked: true);

      SearchResults latest;
      do {
        latest = await nextEvent(queue);
      } while (!latest.posts.first.isLiked);
      expect(latest.posts.first.likeCount, before.likeCount + 1);
      await queue.cancel();
    });

    test('a post that leaves the cache drops out', () async {
      final hits = await search('ada');

      await backend.database.postsDao.deletePost('p6');

      final results = await backend.search.watchResults(hits).first;
      expect(results.posts.map((post) => post.id), ['p1', 'p11']);
    });
  });

  group('recent searches', () {
    test('are saved when asked, newest first, with the time from the '
        'clock', () async {
      await backend.search.saveRecentSearch('ada');
      now = now.add(const Duration(minutes: 1));
      await backend.search.saveRecentSearch('grace');

      expect(await backend.search.watchRecentSearches().first, [
        'grace',
        'ada',
      ]);
      final rows = await backend.database
          .select(backend.database.recentSearches)
          .get();
      expect(rows.map((row) => row.searchedAt), contains(testNow));
    });

    test('searching alone never saves one (Correctness Rule 11)', () async {
      await search('ada');

      expect(await backend.search.watchRecentSearches().first, isEmpty);
    });

    test('clearRecentSearches removes them all', () async {
      await backend.search.saveRecentSearch('ada');

      await backend.search.clearRecentSearches();

      expect(await backend.search.watchRecentSearches().first, isEmpty);
    });
  });
}
