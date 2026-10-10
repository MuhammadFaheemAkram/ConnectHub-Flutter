import 'dart:async';

import 'package:connect_hub/core/common/result.dart';
import 'package:connect_hub/domain/model/post.dart';
import 'package:connect_hub/domain/repository/feed_repository.dart';

/// A scriptable [FeedRepository] for the Feed's Cubit tests.
///
/// Like drift, `watchFeed()` emits the current window, then every change,
/// and a change is announced *asynchronously*, after the call that made it
/// has returned (conventions §11.3).
class FakeFeedRepository implements FeedRepository {
  FakeFeedRepository({List<Post> cached = const []}) : _window = cached;

  List<Post> _window;
  final _changes = StreamController<List<Post>>.broadcast();

  /// The window a successful refresh leaves behind (`null`: unchanged).
  List<Post>? refreshedWindow;
  Result<bool> refreshResult = const Ok(true);

  /// The posts a successful load-more appends.
  List<Post> nextPage = const [];
  Result<bool> loadMoreResult = const Ok(true);

  /// While set and not completed, refresh and load-more wait for it.
  Completer<void>? gate;

  int refreshCalls = 0;
  int loadMoreCalls = 0;

  @override
  Stream<List<Post>> watchFeed() => Stream.multi((watcher) {
    final subscription = _changes.stream.listen(watcher.add);
    watcher
      ..onCancel = subscription.cancel
      ..add(_window);
  });

  @override
  Future<Result<bool>> refresh() async {
    refreshCalls++;
    await gate?.future;
    final window = refreshedWindow;
    if (refreshResult is Ok<bool> && window != null) _write(window);
    return refreshResult;
  }

  @override
  Future<Result<bool>> loadMore() async {
    loadMoreCalls++;
    await gate?.future;
    if (loadMoreResult is Ok<bool>) _write([..._window, ...nextPage]);
    return loadMoreResult;
  }

  /// Changes the window as another screen would, e.g. a like.
  void replaceWindow(List<Post> posts) => _write(posts);

  void _write(List<Post> posts) {
    _window = posts;
    _changes.add(posts);
  }

  Future<void> dispose() => _changes.close();
}
