import 'package:connect_hub/core/common/result.dart';
import 'package:connect_hub/core/database/daos/feed_dao.dart';
import 'package:connect_hub/core/network/api/feed_api_service.dart';
import 'package:connect_hub/core/network/dto/post_page_dto.dart';
import 'package:connect_hub/data/mapper/post_mappers.dart';
import 'package:connect_hub/data/repository/api_guard.dart';
import 'package:connect_hub/domain/model/post.dart';
import 'package:connect_hub/domain/repository/feed_repository.dart';
import 'package:injectable/injectable.dart';
import 'package:synchronized/synchronized.dart';

/// The offline-first feed: the screen reads the window cached in drift, and
/// the API only ever refreshes that window.
///
/// The window grows by cursor: each page ends with an opaque cursor, and the
/// next request asks for the posts after it. Unlike offset paging ("skip 6"),
/// a post created in the meantime can't shift the pages and show a post
/// twice (Correctness Rule 5).
@LazySingleton(as: FeedRepository)
class FeedRepositoryImpl implements FeedRepository {
  FeedRepositoryImpl(this._api, this._feed, this._guard);

  final FeedApiService _api;
  final FeedDao _feed;
  final ApiGuard _guard;

  /// Refresh and load-more both rewrite the window, so they take turns.
  ///
  /// Dart runs one piece of code at a time, but every `await` lets other code
  /// in. Without the lock, a load-more that started before a refresh could
  /// finish after it and append page 3 to the brand-new page 1.
  final _windowLock = Lock();

  /// Where the next page starts: the cursor that came with the last page, or
  /// `null` to start from the top.
  ///
  /// Paging state lives in memory, not in drift: a cursor only means
  /// something to the server that issued it, and the fake server starts
  /// afresh on every launch.
  String? _nextCursor;

  /// Whether the window already reaches the oldest post.
  bool _reachedEnd = false;

  @override
  Stream<List<Post>> watchFeed() => _feed.watchFeed().map(
    (posts) => [for (final post in posts) post.toDomain()],
  );

  @override
  Future<Result<bool>> refresh() => _windowLock.synchronized(() async {
    // A refresh starts a new window, and a cursor only continues the window
    // it came with. If this request fails, the cached window stays and
    // load-more starts from the top, which is safe: posts already in the
    // window are updated, never listed twice.
    _nextCursor = null;
    _reachedEnd = false;
    final result = await _guard.run(() => _api.getFeed());
    if (result case Ok(value: final page)) {
      await _feed.replaceFeed([for (final post in page.posts) post.toCached()]);
      _continueAfter(page);
    }
    return _hasMore(result);
  });

  @override
  Future<Result<bool>> loadMore() => _windowLock.synchronized(() async {
    if (_reachedEnd) return const Ok(false);
    final result = await _guard.run(() => _api.getFeed(cursor: _nextCursor));
    if (result case Ok(value: final page)) {
      await _feed.appendToFeed([
        for (final post in page.posts) post.toCached(),
      ]);
      _continueAfter(page);
    }
    return _hasMore(result);
  });

  void _continueAfter(PostPageDto page) {
    _nextCursor = page.nextCursor;
    _reachedEnd = page.nextCursor == null;
  }

  Result<bool> _hasMore(Result<PostPageDto> result) => switch (result) {
    Ok(value: final page) => Ok(page.nextCursor != null),
    Err(:final exception) => Err(exception),
  };
}
