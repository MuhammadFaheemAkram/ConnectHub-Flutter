import 'dart:async';

import 'package:connect_hub/core/common/app_exception.dart';
import 'package:connect_hub/core/common/first_value.dart';
import 'package:connect_hub/core/common/result.dart';
import 'package:connect_hub/core/common/ui_message.dart';
import 'package:connect_hub/domain/model/comment.dart';
import 'package:connect_hub/domain/model/post.dart';
import 'package:connect_hub/domain/usecase/add_comment_use_case.dart';
import 'package:connect_hub/domain/usecase/bookmark_post_use_case.dart';
import 'package:connect_hub/domain/usecase/like_post_use_case.dart';
import 'package:connect_hub/domain/usecase/refresh_comments_use_case.dart';
import 'package:connect_hub/domain/usecase/refresh_post_use_case.dart';
import 'package:connect_hub/domain/usecase/watch_comments_use_case.dart';
import 'package:connect_hub/domain/usecase/watch_post_use_case.dart';
import 'package:connect_hub/features/post_detail/cubit/post_detail_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

/// Drives Post Detail: one post, its latest comments, and a comment input.
///
/// Like the Feed, it renders the cache and refreshes it in the background. A
/// cached post therefore shows at once, and an error can only appear once the
/// server has answered: never as a flash before the first load
/// (Correctness Rule 12).
///
/// The post id is a runtime parameter, passed through DI with
/// `@factoryParam` (`getIt<PostDetailCubit>(param1: postId)`).
@injectable
class PostDetailCubit extends Cubit<PostDetailState> {
  PostDetailCubit(
    @factoryParam this.postId,
    this._watchPost,
    this._refreshPost,
    this._watchComments,
    this._refreshComments,
    this._addComment,
    this._likePost,
    this._bookmarkPost,
  ) : super(const PostDetailState.loading()) {
    _postSubscription = _watchPost(postId).listen(_onPost);
    _commentsSubscription = _watchComments(postId).listen(_onComments);
  }

  final String postId;
  final WatchPostUseCase _watchPost;
  final RefreshPostUseCase _refreshPost;
  final WatchCommentsUseCase _watchComments;
  final RefreshCommentsUseCase _refreshComments;
  final AddCommentUseCase _addComment;
  final LikePostUseCase _likePost;
  final BookmarkPostUseCase _bookmarkPost;

  late final StreamSubscription<Post?> _postSubscription;
  late final StreamSubscription<List<Comment>> _commentsSubscription;

  /// How many of the latest comments the screen previews.
  static const recentCount = 3;

  static const refreshFailedMessage =
      "Couldn't refresh. Showing the saved post.";
  static const commentsFailedMessage = "Couldn't load the latest comments.";
  static const sendFailedMessage =
      "Couldn't send your comment. Please try again.";
  static const likeFailedMessage =
      "Couldn't update the like. Please try again.";
  static const bookmarkFailedMessage =
      "Couldn't update the bookmark. Please try again.";

  /// The cached post as drift last reported it; [_postRead] tells "not
  /// cached" (`null`) apart from "drift hasn't answered yet".
  Post? _post;
  bool _postRead = false;
  List<Comment> _recent = const [];

  _Refresh _refresh = _Refresh.pending;
  String _refreshError = '';
  bool _isSending = false;
  int _sentCount = 0;
  UiMessage? _message;
  int _messageCount = 0;

  /// The first load, and "Try again" after it failed.
  Future<void> load() async {
    _refresh = _Refresh.pending;
    _emitState();
    await _runRefresh();
  }

  /// Pull to refresh: the post stays on screen while it runs.
  Future<void> refresh() => _runRefresh();

  /// Sends a comment. On success [PostDetailLoaded.sentCount] goes up (the
  /// View clears the input); on failure a SnackBar says so and the text
  /// stays.
  Future<void> sendComment(String text) async {
    if (state is! PostDetailLoaded || _isSending || text.trim().isEmpty) {
      return;
    }
    _isSending = true;
    _emitState();
    final result = await _addComment(postId, text);
    if (isClosed) return;
    switch (result) {
      case Ok():
        // Read the comments once more, so the new one is listed by the time
        // the input clears (drift reports the write a moment later).
        _onCommentsRead(await _watchComments(postId).firstValue);
        if (isClosed) return;
        _sentCount++;
      case Err():
        _message = _nextMessage(sendFailedMessage);
    }
    // Only now, with the comment listed: the button never re-enables while
    // the sent text is still in the field.
    _isSending = false;
    _emitState();
  }

  Future<void> toggleLike(Post post) async {
    final result = await _likePost(post.id, liked: !post.isLiked);
    if (result is Err<void>) _show(likeFailedMessage);
  }

  Future<void> toggleBookmark(Post post) async {
    final result = await _bookmarkPost(post.id, bookmarked: !post.isBookmarked);
    if (result is Err<void>) _show(bookmarkFailedMessage);
  }

  Future<void> _runRefresh() async {
    // The post and its comments load side by side.
    final (post, comments) = await (
      _refreshPost(postId),
      _refreshComments(postId),
    ).wait;
    if (isClosed) return;
    switch (post) {
      case Ok():
        _refresh = _Refresh.succeeded;
        // As in the Feed: decide on the post as cached *now*, not on the
        // stream's last value, which can predate the refresh.
        _post = await _watchPost(postId).firstValue;
        _postRead = true;
        if (isClosed) return;
        if (comments is Err<void>) {
          _message = _nextMessage(commentsFailedMessage);
        }
      case Err(exception: NotFoundException()):
        // The repository has removed the cached copy too.
        _refresh = _Refresh.notFound;
        _post = null;
        _postRead = true;
      case Err(:final exception):
        _refresh = _Refresh.failed;
        _refreshError = exception.message;
        // A fast failure can beat drift's first read: check what is cached
        // now (as in the Feed).
        _post = await _watchPost(postId).firstValue;
        _postRead = true;
        if (isClosed) return;
        if (_post != null) _message = _nextMessage(refreshFailedMessage);
    }
    _emitState();
  }

  void _onPost(Post? post) {
    _post = post;
    _postRead = true;
    _emitState();
  }

  void _onComments(List<Comment> comments) {
    _onCommentsRead(comments);
    _emitState();
  }

  void _onCommentsRead(List<Comment> comments) {
    _recent = comments.length > recentCount
        ? comments.sublist(comments.length - recentCount)
        : comments;
  }

  void _show(String text) {
    _message = _nextMessage(text);
    _emitState();
  }

  UiMessage _nextMessage(String text) =>
      UiMessage(id: ++_messageCount, text: text);

  void _emitState() {
    if (isClosed) return;
    final post = _post;
    final next = post != null
        ? PostDetailState.loaded(
            post: post,
            recentComments: _recent,
            isSending: _isSending,
            sentCount: _sentCount,
            message: _message,
          )
        : !_postRead
        ? const PostDetailState.loading()
        : switch (_refresh) {
            _Refresh.pending ||
            _Refresh.succeeded => const PostDetailState.loading(),
            _Refresh.notFound => const PostDetailState.notFound(),
            _Refresh.failed => PostDetailState.error(_refreshError),
          };
    if (next != state) emit(next);
  }

  @override
  Future<void> close() async {
    await _postSubscription.cancel();
    await _commentsSubscription.cancel();
    return super.close();
  }
}

/// What the latest refresh found.
enum _Refresh { pending, succeeded, notFound, failed }
