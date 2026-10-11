import 'dart:async';

import 'package:connect_hub/core/common/app_exception.dart';
import 'package:connect_hub/core/common/first_value.dart';
import 'package:connect_hub/core/common/result.dart';
import 'package:connect_hub/core/common/ui_message.dart';
import 'package:connect_hub/domain/model/comment.dart';
import 'package:connect_hub/domain/usecase/add_comment_use_case.dart';
import 'package:connect_hub/domain/usecase/delete_comment_use_case.dart';
import 'package:connect_hub/domain/usecase/refresh_comments_use_case.dart';
import 'package:connect_hub/domain/usecase/watch_comments_use_case.dart';
import 'package:connect_hub/features/comments/cubit/comments_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

/// Drives the Comments screen: a post's comments, oldest first, with an
/// input to add one and a delete for the user's own.
///
/// It renders the cached comments and refreshes them in the background, like
/// the Feed. The post id arrives through DI (`@factoryParam`).
@injectable
class CommentsCubit extends Cubit<CommentsState> {
  CommentsCubit(
    @factoryParam this.postId,
    this._watchComments,
    this._refreshComments,
    this._addComment,
    this._deleteComment,
  ) : super(const CommentsState()) {
    _subscription = _watchComments(postId).listen(_onComments);
  }

  final String postId;
  final WatchCommentsUseCase _watchComments;
  final RefreshCommentsUseCase _refreshComments;
  final AddCommentUseCase _addComment;
  final DeleteCommentUseCase _deleteComment;

  late final StreamSubscription<List<Comment>> _subscription;

  static const refreshFailedMessage =
      "Couldn't refresh. Showing the saved comments.";
  static const sendFailedMessage =
      "Couldn't send your comment. Please try again.";
  static const deleteFailedMessage =
      "Couldn't delete your comment. Please try again.";
  static const notFoundMessage = 'This post is no longer available.';

  /// The cached comments as drift last reported them; `null` until it
  /// answers.
  List<Comment>? _comments;
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

  /// Pull to refresh: the comments stay on screen while it runs.
  Future<void> refresh() => _runRefresh();

  /// Sends a comment. On success [CommentsState.sentCount] goes up (the View
  /// clears the input and scrolls to the comment); on failure a SnackBar says
  /// so and the text stays.
  Future<void> send(String text) async {
    if (_isSending || text.trim().isEmpty) return;
    _isSending = true;
    _emitState();
    final result = await _addComment(postId, text);
    if (isClosed) return;
    switch (result) {
      case Ok():
        // The new comment is listed before the View scrolls to it (drift
        // would report it a moment later).
        _comments = await _watchComments(postId).firstValue;
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

  /// Deletes one of the user's comments. The repository removes it at once
  /// and puts it back if the server refuses; the screen only says so.
  Future<void> delete(Comment comment) async {
    final result = await _deleteComment(comment.id);
    if (result is Err<void> && !isClosed) {
      _message = _nextMessage(deleteFailedMessage);
      _emitState();
    }
  }

  Future<void> _runRefresh() async {
    final result = await _refreshComments(postId);
    if (isClosed) return;
    switch (result) {
      case Ok():
        // As in the Feed: read what is cached now, then record the outcome.
        _comments = await _watchComments(postId).firstValue;
        if (isClosed) return;
        _refresh = _Refresh.succeeded;
      case Err(exception: NotFoundException()):
        _refresh = _Refresh.failed;
        _refreshError = notFoundMessage;
      case Err(:final exception):
        // A fast failure can beat drift's first read: check what is cached
        // now (as in the Feed).
        _comments = await _watchComments(postId).firstValue;
        if (isClosed) return;
        _refresh = _Refresh.failed;
        _refreshError = exception.message;
        if (_comments!.isNotEmpty) {
          _message = _nextMessage(refreshFailedMessage);
        }
    }
    _emitState();
  }

  void _onComments(List<Comment> comments) {
    _comments = comments;
    _emitState();
  }

  UiMessage _nextMessage(String text) =>
      UiMessage(id: ++_messageCount, text: text);

  void _emitState() {
    if (isClosed) return;
    final comments = _comments;
    final status = switch (comments) {
      null => CommentsStatus.loading,
      [] => switch (_refresh) {
        _Refresh.pending => CommentsStatus.loading,
        _Refresh.succeeded => CommentsStatus.loaded,
        _Refresh.failed => CommentsStatus.failure,
      },
      _ => CommentsStatus.loaded,
    };
    final next = CommentsState(
      status: status,
      comments: comments ?? const [],
      errorMessage: status == CommentsStatus.failure ? _refreshError : '',
      isSending: _isSending,
      sentCount: _sentCount,
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
