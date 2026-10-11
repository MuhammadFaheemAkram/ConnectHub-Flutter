import 'dart:async';

import 'package:connect_hub/core/common/result.dart';
import 'package:connect_hub/domain/model/post.dart';
import 'package:connect_hub/domain/repository/bookmark_repository.dart';

/// A scriptable [BookmarkRepository]. Like drift, `watchBookmarks()` emits
/// the current list, then every change, announced asynchronously.
class FakeBookmarkRepository implements BookmarkRepository {
  FakeBookmarkRepository({List<Post> cached = const []}) : _bookmarks = cached;

  List<Post> _bookmarks;
  final _changes = StreamController<List<Post>>.broadcast();

  /// What `refreshBookmarks` answers; a success caches [refreshedBookmarks]
  /// (if set).
  Result<void> refreshResult = const Ok(null);
  List<Post>? refreshedBookmarks;

  /// While set and not completed, `refreshBookmarks` waits for it.
  Completer<void>? refreshGate;
  int refreshCalls = 0;

  @override
  Stream<List<Post>> watchBookmarks() => Stream.multi((watcher) {
    final subscription = _changes.stream.listen(watcher.add);
    watcher
      ..onCancel = subscription.cancel
      ..add(_bookmarks);
  });

  @override
  Future<Result<void>> refreshBookmarks() async {
    refreshCalls++;
    await refreshGate?.future;
    final bookmarks = refreshedBookmarks;
    if (refreshResult is Ok<void> && bookmarks != null) {
      replaceBookmarks(bookmarks);
    }
    return refreshResult;
  }

  /// Changes the list, as a bookmark made or removed anywhere would.
  void replaceBookmarks(List<Post> bookmarks) {
    _bookmarks = bookmarks;
    _changes.add(bookmarks);
  }

  Future<void> dispose() => _changes.close();
}
