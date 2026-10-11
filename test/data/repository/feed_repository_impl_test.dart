import 'dart:async';

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

  const page1 = ['p1', 'p2', 'p3', 'p16', 'p4', 'p5'];
  const page2 = ['p6', 'p7', 'p17', 'p8', 'p9', 'p10'];
  const page3 = ['p11', 'p12', 'p13', 'p14', 'p15'];

  Matcher isOk(bool hasMore) =>
      isA<Ok<bool>>().having((ok) => ok.value, 'hasMore', hasMore);

  test('refresh fills the window with the newest page', () async {
    expect(await backend.feed.refresh(), isOk(true));

    expect(await backend.feedIds(), page1);
  });

  test('load more appends each following page, without duplicates, until '
      'the end', () async {
    await backend.feed.refresh();

    expect(await backend.feed.loadMore(), isOk(true));
    expect(await backend.feedIds(), [...page1, ...page2]);

    expect(await backend.feed.loadMore(), isOk(false));
    expect(await backend.feedIds(), [...page1, ...page2, ...page3]);
  });

  test('at the end, load more answers "no more" without a request', () async {
    await backend.feed.refresh();
    await backend.feed.loadMore();
    await backend.feed.loadMore();
    final requests = backend.api.requests.length;

    expect(await backend.feed.loadMore(), isOk(false));
    expect(backend.api.requests, hasLength(requests));
  });

  test('refresh replaces the whole window with the newest page', () async {
    await backend.feed.refresh();
    await backend.feed.loadMore();

    await backend.feed.refresh();

    expect(await backend.feedIds(), page1);
  });

  test('a failed refresh keeps the cached window and says why', () async {
    await backend.feed.refresh();
    backend.network.failRequests = true;

    final result = await backend.feed.refresh();

    expect(
      result,
      isA<Err<bool>>().having(
        (err) => err.exception,
        'exception',
        isA<NetworkException>(),
      ),
    );
    expect(await backend.feedIds(), page1);
  });

  test('after a failed refresh, load more starts from the top, and still '
      'never lists a post twice', () async {
    await backend.feed.refresh();
    await backend.feed.loadMore();
    backend.network.failRequests = true;
    await backend.feed.refresh();
    backend.network.failRequests = false;

    expect(await backend.feed.loadMore(), isOk(true));

    expect(backend.api.requests.last, 'feed:top');
    expect(await backend.feedIds(), [...page1, ...page2]);
  });

  test('posts cached by other screens stay out of the feed', () async {
    await backend.feed.refresh();

    await backend.database.postsDao.upsertPosts([cachedPost('p99')]);

    expect(await backend.feedIds(), page1);
  });

  test(
    'regression: a refresh keeps bookmarks (upserts, never REPLACE)',
    () async {
      await backend.feed.refresh();
      await backend.posts.setBookmarked('p2', bookmarked: true);

      await backend.feed.refresh();

      final p2 = (await backend.feed.watchFeed().first).singleWhere(
        (post) => post.id == 'p2',
      );
      expect(p2.isBookmarked, isTrue);
    },
  );

  test(
    'refresh and load more take turns, so the window never has a gap',
    () async {
      await backend.feed.refresh();
      backend.api.gate = Completer<void>();

      // Load more starts first and is held in flight. The refresh waits
      // for it instead of racing it.
      final loadingMore = backend.feed.loadMore();
      final refreshing = backend.feed.refresh();
      await pumpEventQueue();
      expect(backend.api.requests, ['feed:top', isNot('feed:top')]);

      backend.api.gate!.complete();
      await Future.wait([loadingMore, refreshing]);

      expect(await backend.feedIds(), page1);
      // And paging continues right after page 1.
      await backend.feed.loadMore();
      expect(await backend.feedIds(), [...page1, ...page2]);
    },
  );
}
