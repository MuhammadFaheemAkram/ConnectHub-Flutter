import 'dart:async';

import 'package:connect_hub/core/common/result.dart';
import 'package:connect_hub/core/common/ui_message.dart';
import 'package:connect_hub/domain/model/post.dart';
import 'package:connect_hub/domain/usecase/bookmark_post_use_case.dart';
import 'package:connect_hub/domain/usecase/like_post_use_case.dart';
import 'package:connect_hub/domain/usecase/load_more_feed_use_case.dart';
import 'package:connect_hub/domain/usecase/refresh_feed_use_case.dart';
import 'package:connect_hub/domain/usecase/watch_feed_use_case.dart';
import 'package:connect_hub/features/feed/cubit/feed_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

/// Drives the Feed: it renders the window cached in drift, and asks for that
/// window to be refreshed, extended, liked and bookmarked.
///
/// A Cubit, not a Bloc: these are plain intents, with no need for event
/// transformers. (Refresh and load-more already take turns, in the
/// repository.)
///
/// The state combines two inputs: the cached posts (a stream) and what the
/// latest refresh found. An empty cache means "still loading", "the server
/// has no posts" or "couldn't load" depending on the second one.
@injectable
class FeedCubit extends Cubit<FeedState> {
  FeedCubit(
    this._watchFeed,
    this._refreshFeed,
    this._loadMoreFeed,
    this._likePost,
    this._bookmarkPost,
  ) : super(const FeedState.loading()) {
    // Cached posts show the moment drift reads them, before the server
    // answers: offline-first.
    _subscription = _watchFeed().listen(_onPosts);
  }

  final WatchFeedUseCase _watchFeed;
  final RefreshFeedUseCase _refreshFeed;
  final LoadMoreFeedUseCase _loadMoreFeed;
  final LikePostUseCase _likePost;
  final BookmarkPostUseCase _bookmarkPost;

  late final StreamSubscription<List<Post>> _subscription;

  static const refreshFailedMessage = "Couldn't refresh. Showing saved posts.";
  static const likeFailedMessage =
      "Couldn't update the like. Please try again.";
  static const bookmarkFailedMessage =
      "Couldn't update the bookmark. Please try again.";

  /// The cached window as drift last reported it; `null` until it answers.
  List<Post>? _posts;

  _Refresh _refresh = _Refresh.pending;
  String _refreshError = '';
  bool _hasMore = true;
  LoadMoreStatus _loadMore = LoadMoreStatus.idle;
  UiMessage? _message;
  int _messageCount = 0;

  /// The first load, and "Try again" after it failed. With nothing cached,
  /// the full-screen spinner shows until the server answers.
  Future<void> load() async {
    _refresh = _Refresh.pending;
    _emitState();
    await _runRefresh();
  }

  /// Pull to refresh. Whatever is on screen stays while it runs.
  Future<void> refresh() => _runRefresh();

  /// Loads the next page. The View calls it near the end of the list and
  /// from the footer's Retry. Calls while a page is loading, or after the
  /// last page, are ignored.
  Future<void> loadMore() async {
    if (state is! FeedLoaded ||
        !_hasMore ||
        _loadMore == LoadMoreStatus.loading) {
      return;
    }
    _loadMore = LoadMoreStatus.loading;
    _emitState();
    final result = await _loadMoreFeed();
    if (isClosed) return;
    switch (result) {
      case Ok(value: final hasMore):
        _hasMore = hasMore;
        _loadMore = LoadMoreStatus.idle;
      case Err():
        _loadMore = LoadMoreStatus.failed;
    }
    _emitState();
  }

  /// The repository updates the cache at once and rolls back on failure;
  /// the screen only has to say that it failed.
  Future<void> toggleLike(Post post) async {
    final result = await _likePost(post.id, liked: !post.isLiked);
    if (result is Err<void>) _show(likeFailedMessage);
  }

  Future<void> toggleBookmark(Post post) async {
    final result = await _bookmarkPost(post.id, bookmarked: !post.isBookmarked);
    if (result is Err<void>) _show(bookmarkFailedMessage);
  }

  Future<void> _runRefresh() async {
    final result = await _refreshFeed();
    if (isClosed) return;
    switch (result) {
      case Ok(value: final hasMore):
        _refresh = _Refresh.succeeded;
        _hasMore = hasMore;
        _loadMore = LoadMoreStatus.idle;
        // drift announces the new window asynchronously (conventions §11.3),
        // so `_posts` can still be the window from before the refresh. Read
        // the current one: an empty window that is about to fill up must
        // never flash "No posts yet".
        _posts = await _watchFeed().first;
        if (isClosed) return;
      case Err(:final exception):
        _refresh = _Refresh.failed;
        _refreshError = exception.message;
        // With posts on screen, they stay, and a SnackBar says why they may
        // be stale (Correctness Rule 6: no silent errors).
        if (_posts?.isNotEmpty ?? false) {
          _message = _nextMessage(refreshFailedMessage);
        }
    }
    _emitState();
  }

  void _onPosts(List<Post> posts) {
    _posts = posts;
    _emitState();
  }

  void _show(String text) {
    _message = _nextMessage(text);
    _emitState();
  }

  UiMessage _nextMessage(String text) =>
      UiMessage(id: ++_messageCount, text: text);

  void _emitState() {
    if (isClosed) return;
    final next = switch (_posts) {
      null => const FeedState.loading(),
      [] => switch (_refresh) {
        _Refresh.pending => const FeedState.loading(),
        _Refresh.failed => FeedState.error(_refreshError),
        _Refresh.succeeded => const FeedState.empty(),
      },
      final posts => FeedState.loaded(
        posts: posts,
        hasMore: _hasMore,
        loadMore: _loadMore,
        message: _message,
      ),
    };
    // Bloc only skips a repeated state after its first emit (§11.12).
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
