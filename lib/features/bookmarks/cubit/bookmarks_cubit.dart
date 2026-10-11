import 'dart:async';

import 'package:connect_hub/core/common/first_value.dart';
import 'package:connect_hub/core/common/result.dart';
import 'package:connect_hub/core/common/ui_message.dart';
import 'package:connect_hub/domain/model/post.dart';
import 'package:connect_hub/domain/usecase/bookmark_post_use_case.dart';
import 'package:connect_hub/domain/usecase/like_post_use_case.dart';
import 'package:connect_hub/domain/usecase/refresh_bookmarks_use_case.dart';
import 'package:connect_hub/domain/usecase/watch_bookmarks_use_case.dart';
import 'package:connect_hub/features/bookmarks/cubit/bookmarks_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

/// Drives the Bookmarks tab: the bookmarks cached in drift, so they show
/// offline, refreshed from the server when the tab opens and on pull.
///
/// Removing one is the same optimistic write as everywhere else
/// (`BookmarkPostUseCase`): it leaves the list at once, a SnackBar offers
/// Undo, and a failure puts it back.
@injectable
class BookmarksCubit extends Cubit<BookmarksState> {
  BookmarksCubit(
    this._watchBookmarks,
    this._refreshBookmarks,
    this._bookmarkPost,
    this._likePost,
  ) : super(const BookmarksState()) {
    _subscription = _watchBookmarks().listen(_onPosts);
  }

  final WatchBookmarksUseCase _watchBookmarks;
  final RefreshBookmarksUseCase _refreshBookmarks;
  final BookmarkPostUseCase _bookmarkPost;
  final LikePostUseCase _likePost;

  late final StreamSubscription<List<Post>> _subscription;

  static const removedMessage = 'Removed from bookmarks';
  static const refreshFailedMessage =
      "Couldn't refresh. Showing saved bookmarks.";
  static const likeFailedMessage =
      "Couldn't update the like. Please try again.";
  static const bookmarkFailedMessage =
      "Couldn't update the bookmark. Please try again.";

  /// The cached bookmarks as drift last reported them; `null` until it
  /// answers.
  List<Post>? _posts;
  _Refresh _refresh = _Refresh.pending;
  String _refreshError = '';
  UiMessage? _message;
  int _messageCount = 0;

  /// What the latest "Removed from bookmarks" would undo: the post, and its
  /// removal, which may still be in flight.
  ({String postId, Future<Result<void>> removal})? _undoable;

  /// The first load, and "Try again" after it failed.
  Future<void> load() async {
    _refresh = _Refresh.pending;
    _emitState();
    await _runRefresh();
  }

  /// Pull to refresh: the list stays on screen while it runs.
  Future<void> refresh() => _runRefresh();

  /// Removes the bookmark, and offers to undo it.
  Future<void> remove(Post post) async {
    final removal = _bookmarkPost(post.id, bookmarked: false);
    _undoable = (postId: post.id, removal: removal);
    _show(removedMessage, action: UiMessageAction.undo);
    final result = await removal;
    if (result is Err<void>) {
      // The repository has put it back already: nothing left to undo.
      if (_undoable?.removal == removal) _undoable = null;
      _show(bookmarkFailedMessage);
    }
  }

  /// The SnackBar's Undo: bookmarks the post again. It comes back at the
  /// top, because a bookmark's time is the server's, and this one is new.
  Future<void> undoRemove() async {
    final undoable = _undoable;
    if (undoable == null) return;
    _undoable = null;
    // One request per post at a time: a bookmark sent while the removal is
    // still in flight would be dropped. Let the removal finish first.
    if (await undoable.removal is Err<void>) return;
    final result = await _bookmarkPost(undoable.postId, bookmarked: true);
    if (result is Err<void>) _show(bookmarkFailedMessage);
  }

  Future<void> toggleLike(Post post) async {
    final result = await _likePost(post.id, liked: !post.isLiked);
    if (result is Err<void>) _show(likeFailedMessage);
  }

  Future<void> _runRefresh() async {
    final result = await _refreshBookmarks();
    if (isClosed) return;
    switch (result) {
      case Ok():
        _refresh = _Refresh.succeeded;
        // As in the Feed: decide on the list as cached *now*, not on the
        // stream's last value, which can predate the refresh.
        _posts = await _watchBookmarks().firstValue;
        if (isClosed) return;
      case Err(:final exception):
        _refresh = _Refresh.failed;
        _refreshError = exception.message;
        // A fast failure can beat drift's first read, so check what is
        // cached now too: saved bookmarks stay, and the screen says why they
        // may be stale (Correctness Rule 6).
        _posts = await _watchBookmarks().firstValue;
        if (isClosed) return;
        if (_posts!.isNotEmpty) _message = _nextMessage(refreshFailedMessage);
    }
    _emitState();
  }

  void _onPosts(List<Post> posts) {
    _posts = posts;
    _emitState();
  }

  void _show(String text, {UiMessageAction? action}) {
    _message = _nextMessage(text, action: action);
    _emitState();
  }

  UiMessage _nextMessage(String text, {UiMessageAction? action}) =>
      UiMessage(id: ++_messageCount, text: text, action: action);

  void _emitState() {
    if (isClosed) return;
    final posts = _posts;
    final status = switch (posts) {
      null => BookmarksStatus.loading,
      [] => switch (_refresh) {
        _Refresh.pending => BookmarksStatus.loading,
        _Refresh.succeeded => BookmarksStatus.loaded,
        _Refresh.failed => BookmarksStatus.failure,
      },
      _ => BookmarksStatus.loaded,
    };
    final next = BookmarksState(
      status: status,
      posts: posts ?? const [],
      errorMessage: status == BookmarksStatus.failure ? _refreshError : '',
      message: _message,
    );
    if (next != state) emit(next);
  }

  @override
  Future<void> close() async {
    await _subscription.cancel();
    return super.close();
  }
}

/// What the latest refresh found.
enum _Refresh { pending, succeeded, failed }
