import 'dart:async';

import 'package:connect_hub/core/common/app_exception.dart';
import 'package:connect_hub/core/common/first_value.dart';
import 'package:connect_hub/core/common/result.dart';
import 'package:connect_hub/core/common/ui_message.dart';
import 'package:connect_hub/domain/model/post.dart';
import 'package:connect_hub/domain/model/user.dart';
import 'package:connect_hub/domain/usecase/bookmark_post_use_case.dart';
import 'package:connect_hub/domain/usecase/like_post_use_case.dart';
import 'package:connect_hub/domain/usecase/refresh_user_posts_use_case.dart';
import 'package:connect_hub/domain/usecase/refresh_user_use_case.dart';
import 'package:connect_hub/domain/usecase/watch_user_posts_use_case.dart';
import 'package:connect_hub/domain/usecase/watch_user_use_case.dart';
import 'package:connect_hub/features/profile/cubit/profile_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:stream_transform/stream_transform.dart';

/// Drives a profile: the header and the user's posts, from the cache, then
/// refreshed from the server.
///
/// The same Cubit serves my profile and everyone else's; only the View's
/// buttons differ. The page passes the id (`@factoryParam`): for the Profile
/// tab that is the signed-in user's, from the session.
///
/// A cached profile shows at once. With nothing cached, the screen waits for
/// the server, and then shows the profile, an error, or "not available":
/// never an endless spinner (Correctness Rule 12).
@injectable
class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit(
    @factoryParam this.userId,
    this._watchUser,
    this._refreshUser,
    this._watchUserPosts,
    this._refreshUserPosts,
    this._likePost,
    this._bookmarkPost,
  ) : super(const ProfileState.loading()) {
    _subscription = _cache().listen(_onCache);
  }

  final String userId;
  final WatchUserUseCase _watchUser;
  final RefreshUserUseCase _refreshUser;
  final WatchUserPostsUseCase _watchUserPosts;
  final RefreshUserPostsUseCase _refreshUserPosts;
  final LikePostUseCase _likePost;
  final BookmarkPostUseCase _bookmarkPost;

  late final StreamSubscription<_Cached> _subscription;

  static const refreshFailedMessage =
      "Couldn't refresh. Showing the saved profile.";
  static const postsFailedMessage = "Couldn't load the latest posts.";
  static const likeFailedMessage =
      "Couldn't update the like. Please try again.";
  static const bookmarkFailedMessage =
      "Couldn't update the bookmark. Please try again.";

  /// The cached profile and posts as drift last reported them; [_cacheRead]
  /// tells "not cached" (`null`) apart from "drift hasn't answered yet".
  User? _user;
  List<Post> _posts = const [];
  bool _cacheRead = false;

  /// Whether the posts have been fetched once (successfully or not), so an
  /// empty list means "no posts" rather than "not loaded yet".
  bool _postsFetched = false;

  _Refresh _refresh = _Refresh.pending;
  String _refreshError = '';
  UiMessage? _message;
  int _messageCount = 0;

  /// The first load, and "Try again" after it failed.
  Future<void> load() async {
    _refresh = _Refresh.pending;
    _emitState();
    await _runRefresh();
  }

  /// Pull to refresh: the profile stays on screen while it runs.
  Future<void> refresh() => _runRefresh();

  Future<void> toggleLike(Post post) async {
    final result = await _likePost(post.id, liked: !post.isLiked);
    if (result is Err<void>) _show(likeFailedMessage);
  }

  Future<void> toggleBookmark(Post post) async {
    final result = await _bookmarkPost(post.id, bookmarked: !post.isBookmarked);
    if (result is Err<void>) _show(bookmarkFailedMessage);
  }

  Future<void> _runRefresh() async {
    // The profile and its posts load side by side.
    final (user, posts) = await (
      _refreshUser(userId),
      _refreshUserPosts(userId),
    ).wait;
    if (isClosed) return;
    switch (user) {
      case Ok():
        _refresh = _Refresh.succeeded;
        // Decide on what is cached *now*: drift reports the refresh's writes
        // a moment later (conventions §11.3).
        _read(await _cache().firstValue);
        if (isClosed) return;
        if (posts is Err<void>) _message = _nextMessage(postsFailedMessage);
      case Err(exception: NotFoundException()):
        _refresh = _Refresh.notFound;
      case Err(:final exception):
        _refresh = _Refresh.failed;
        _refreshError = exception.message;
        // A fast failure can beat drift's first read: check what is cached
        // now, so a saved profile stays and the screen says why.
        _read(await _cache().firstValue);
        if (isClosed) return;
        if (_user != null) _message = _nextMessage(refreshFailedMessage);
    }
    // Only now, with the fetched posts read: an empty list earlier would
    // have flashed "No posts yet".
    _postsFetched = true;
    _emitState();
  }

  /// The profile and its posts as one value. drift reports the two queries
  /// separately; combined, the header never shows with the posts not yet
  /// read.
  Stream<_Cached> _cache() => _watchUser(userId).combineLatest(
    _watchUserPosts(userId),
    (user, posts) => (user: user, posts: posts),
  );

  void _onCache(_Cached cached) {
    _read(cached);
    _emitState();
  }

  void _read(_Cached cached) {
    _user = cached.user;
    _posts = cached.posts;
    _cacheRead = true;
  }

  void _show(String text) {
    _message = _nextMessage(text);
    _emitState();
  }

  UiMessage _nextMessage(String text) =>
      UiMessage(id: ++_messageCount, text: text);

  void _emitState() {
    if (isClosed) return;
    final user = _user;
    final ProfileState next;
    if (_refresh == _Refresh.notFound) {
      // The server's answer wins over anything still cached.
      next = const ProfileState.notFound();
    } else if (user != null) {
      next = ProfileState.loaded(
        user: user,
        posts: _posts,
        isLoadingPosts: !_postsFetched && _posts.isEmpty,
        message: _message,
      );
    } else if (_cacheRead && _refresh == _Refresh.failed) {
      next = ProfileState.error(_refreshError);
    } else {
      next = const ProfileState.loading();
    }
    if (next != state) emit(next);
  }

  @override
  Future<void> close() async {
    await _subscription.cancel();
    return super.close();
  }
}

typedef _Cached = ({User? user, List<Post> posts});

/// What the latest refresh of the profile found.
enum _Refresh { pending, succeeded, notFound, failed }
