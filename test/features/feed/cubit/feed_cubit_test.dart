import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:connect_hub/core/common/app_exception.dart';
import 'package:connect_hub/core/common/result.dart';
import 'package:connect_hub/core/common/ui_message.dart';
import 'package:connect_hub/domain/usecase/bookmark_post_use_case.dart';
import 'package:connect_hub/domain/usecase/like_post_use_case.dart';
import 'package:connect_hub/domain/usecase/load_more_feed_use_case.dart';
import 'package:connect_hub/domain/usecase/refresh_feed_use_case.dart';
import 'package:connect_hub/domain/usecase/watch_cache_cleared_use_case.dart';
import 'package:connect_hub/domain/usecase/watch_feed_use_case.dart';
import 'package:connect_hub/features/feed/cubit/feed_cubit.dart';
import 'package:connect_hub/features/feed/cubit/feed_state.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fakes/fake_cache_repository.dart';
import '../../../helpers/fakes/fake_feed_repository.dart';
import '../../../helpers/fakes/fake_post_repository.dart';
import '../../../helpers/fixtures.dart';

void main() {
  late FakeFeedRepository feed;
  late FakePostRepository posts;
  late FakeCacheRepository cache;

  setUp(() {
    feed = FakeFeedRepository();
    posts = FakePostRepository();
    cache = FakeCacheRepository();
  });

  tearDown(() async {
    await feed.dispose();
    await cache.dispose();
  });

  FeedCubit buildCubit() => FeedCubit(
    WatchFeedUseCase(feed),
    RefreshFeedUseCase(feed),
    LoadMoreFeedUseCase(feed),
    LikePostUseCase(posts),
    BookmarkPostUseCase(posts),
    WatchCacheClearedUseCase(cache),
  );

  final p1 = samplePost('p1');
  final p2 = samplePost('p2');
  final networkError = const NetworkException().message;

  UiMessage message(int id, String text) => UiMessage(id: id, text: text);

  group('first load', () {
    blocTest<FeedCubit, FeedState>(
      'with nothing cached: stays loading until the first page is cached, '
      'and never flashes "empty" while it is on its way',
      setUp: () => feed.refreshedWindow = [p1, p2],
      build: buildCubit,
      act: (cubit) => cubit.load(),
      expect: () => [
        FeedState.loaded(posts: [p1, p2]),
      ],
    );

    blocTest<FeedCubit, FeedState>(
      'cached posts show before the server answers (offline-first)',
      setUp: () =>
          feed = FakeFeedRepository(cached: [p1])..gate = Completer<void>(),
      build: buildCubit,
      act: (cubit) => unawaited(cubit.load()),
      expect: () => [
        FeedState.loaded(posts: [p1]),
      ],
    );

    blocTest<FeedCubit, FeedState>(
      'a server with no posts: empty',
      setUp: () => feed.refreshResult = const Ok(false),
      build: buildCubit,
      act: (cubit) => cubit.load(),
      expect: () => [const FeedState.empty()],
    );

    blocTest<FeedCubit, FeedState>(
      'nothing cached and the refresh fails: the error; Try again loads',
      setUp: () => feed.refreshResult = const Err(NetworkException()),
      build: buildCubit,
      act: (cubit) async {
        await cubit.load();
        feed
          ..refreshResult = const Ok(true)
          ..refreshedWindow = [p1];
        await cubit.load();
      },
      expect: () => [
        FeedState.error(networkError),
        const FeedState.loading(),
        FeedState.loaded(posts: [p1]),
      ],
    );

    blocTest<FeedCubit, FeedState>(
      'cached posts stay when the refresh fails, and a message says so',
      setUp: () =>
          feed = FakeFeedRepository(cached: [p1])
            ..refreshResult = const Err(NetworkException()),
      build: buildCubit,
      act: (cubit) => cubit.load(),
      expect: () => [
        FeedState.loaded(posts: [p1]),
        FeedState.loaded(
          posts: [p1],
          message: message(1, FeedCubit.refreshFailedMessage),
        ),
      ],
    );
  });

  group('pull to refresh', () {
    blocTest<FeedCubit, FeedState>(
      'replaces the posts with the newest page',
      setUp: () =>
          feed = FakeFeedRepository(cached: [p1])..refreshedWindow = [p2],
      build: buildCubit,
      act: (cubit) => cubit.refresh(),
      expect: () => [
        FeedState.loaded(posts: [p1]),
        FeedState.loaded(posts: [p2]),
      ],
    );

    blocTest<FeedCubit, FeedState>(
      'a repeated failure is reported again (a new message id)',
      setUp: () =>
          feed = FakeFeedRepository(cached: [p1])
            ..refreshResult = const Err(NetworkException()),
      build: buildCubit,
      act: (cubit) async {
        await cubit.refresh();
        await cubit.refresh();
      },
      skip: 1,
      expect: () => [
        FeedState.loaded(
          posts: [p1],
          message: message(1, FeedCubit.refreshFailedMessage),
        ),
        FeedState.loaded(
          posts: [p1],
          message: message(2, FeedCubit.refreshFailedMessage),
        ),
      ],
    );
  });

  group('load more', () {
    /// Waits for the cached posts to be on screen first.
    Future<void> whenLoaded(FeedCubit cubit, Future<void> Function() then) =>
        pumpEventQueue().then((_) => then());

    blocTest<FeedCubit, FeedState>(
      'shows the footer spinner, then the next page',
      setUp: () => feed = FakeFeedRepository(cached: [p1])..nextPage = [p2],
      build: buildCubit,
      act: (cubit) => whenLoaded(cubit, cubit.loadMore),
      expect: () => [
        FeedState.loaded(posts: [p1]),
        FeedState.loaded(posts: [p1], loadMore: LoadMoreStatus.loading),
        FeedState.loaded(posts: [p1]),
        FeedState.loaded(posts: [p1, p2]),
      ],
    );

    blocTest<FeedCubit, FeedState>(
      'after the last page, the footer says the user is all caught up',
      setUp: () => feed = FakeFeedRepository(cached: [p1])
        ..nextPage = [p2]
        ..loadMoreResult = const Ok(false),
      build: buildCubit,
      act: (cubit) => whenLoaded(cubit, cubit.loadMore),
      verify: (cubit) => expect(
        cubit.state,
        FeedState.loaded(posts: [p1, p2], hasMore: false),
      ),
    );

    blocTest<FeedCubit, FeedState>(
      'a failure shows Retry, and retrying loads the page',
      setUp: () => feed = FakeFeedRepository(cached: [p1])
        ..nextPage = [p2]
        ..loadMoreResult = const Err(NetworkException()),
      build: buildCubit,
      act: (cubit) => whenLoaded(cubit, () async {
        await cubit.loadMore();
        feed.loadMoreResult = const Ok(true);
        await cubit.loadMore();
      }),
      expect: () => [
        FeedState.loaded(posts: [p1]),
        FeedState.loaded(posts: [p1], loadMore: LoadMoreStatus.loading),
        FeedState.loaded(posts: [p1], loadMore: LoadMoreStatus.failed),
        FeedState.loaded(posts: [p1], loadMore: LoadMoreStatus.loading),
        FeedState.loaded(posts: [p1]),
        FeedState.loaded(posts: [p1, p2]),
      ],
    );

    blocTest<FeedCubit, FeedState>(
      'is ignored while a page is loading, after the last page, and before '
      'anything is on screen',
      setUp: () =>
          feed = FakeFeedRepository(cached: [p1])
            ..loadMoreResult = const Ok(false),
      build: buildCubit,
      act: (cubit) async {
        await cubit.loadMore(); // nothing on screen yet
        await pumpEventQueue();
        await Future.wait([cubit.loadMore(), cubit.loadMore()]);
        await cubit.loadMore(); // after the last page
      },
      verify: (_) => expect(feed.loadMoreCalls, 1),
    );
  });

  group('likes and bookmarks', () {
    blocTest<FeedCubit, FeedState>(
      'ask for the opposite of what the post shows',
      build: buildCubit,
      act: (cubit) async {
        await cubit.toggleLike(samplePost('p1'));
        await cubit.toggleBookmark(samplePost('p2', isBookmarked: true));
      },
      verify: (_) {
        expect(posts.likeCalls, [(postId: 'p1', liked: true)]);
        expect(posts.bookmarkCalls, [(postId: 'p2', bookmarked: false)]);
      },
    );

    blocTest<FeedCubit, FeedState>(
      'a failure says so (the repository has already rolled it back)',
      setUp: () {
        feed = FakeFeedRepository(cached: [p1]);
        posts
          ..likeResult = const Err(NetworkException())
          ..bookmarkResult = const Err(NetworkException());
      },
      build: buildCubit,
      act: (cubit) async {
        await pumpEventQueue();
        await cubit.toggleLike(p1);
        await cubit.toggleBookmark(p1);
      },
      expect: () => [
        FeedState.loaded(posts: [p1]),
        FeedState.loaded(
          posts: [p1],
          message: message(1, FeedCubit.likeFailedMessage),
        ),
        FeedState.loaded(
          posts: [p1],
          message: message(2, FeedCubit.bookmarkFailedMessage),
        ),
      ],
    );

    blocTest<FeedCubit, FeedState>(
      'a change from anywhere (a like on another screen) shows at once',
      setUp: () => feed = FakeFeedRepository(cached: [p1]),
      build: buildCubit,
      act: (cubit) async {
        await pumpEventQueue();
        feed.replaceWindow([p1.copyWith(isLiked: true, likeCount: 11)]);
      },
      expect: () => [
        FeedState.loaded(posts: [p1]),
        FeedState.loaded(posts: [p1.copyWith(isLiked: true, likeCount: 11)]),
      ],
    );
  });

  blocTest<FeedCubit, FeedState>(
    'after "Clear cache", the feed loads again: a spinner, never "No posts '
    'yet"',
    setUp: () =>
        feed = FakeFeedRepository(cached: [p1])..refreshedWindow = [p1],
    build: buildCubit,
    act: (cubit) async {
      await cubit.load();
      // The cache is wiped, and the screens hear it before drift reports
      // the emptied window. The refresh that follows takes a moment.
      feed.gate = Completer<void>();
      await cache.clearCache();
      feed.replaceWindow(const []);
      await pumpEventQueue();
      feed.gate!.complete();
      await pumpEventQueue();
    },
    expect: () => [
      FeedState.loaded(posts: [p1]),
      const FeedState.loading(),
      FeedState.loaded(posts: [p1]),
    ],
    verify: (_) => expect(feed.refreshCalls, 2),
  );
}
