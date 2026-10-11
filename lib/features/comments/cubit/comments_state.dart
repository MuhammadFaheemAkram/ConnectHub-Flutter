import 'package:connect_hub/core/common/ui_message.dart';
import 'package:connect_hub/domain/model/comment.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'comments_state.freezed.dart';

/// Where the list stands. "Empty" is [loaded] with no comments.
enum CommentsStatus {
  /// Nothing cached yet, and the server hasn't answered.
  loading,

  /// Showing what's cached (possibly nothing).
  loaded,

  /// Nothing cached, and fetching failed.
  failure,
}

/// One class rather than a union: the comment input stays on screen in
/// every state, so its fields ([isSending], [sentCount]) must survive any
/// status change. (The spec's `ChatDetailState` has the same shape.)
@freezed
abstract class CommentsState with _$CommentsState {
  const factory CommentsState({
    @Default(CommentsStatus.loading) CommentsStatus status,

    /// Oldest first.
    @Default(<Comment>[]) List<Comment> comments,
    @Default('') String errorMessage,
    @Default(false) bool isSending,

    /// Goes up by one each time a comment is sent. A one-time effect: the
    /// View clears the input and scrolls to the new comment.
    @Default(0) int sentCount,

    /// A one-time SnackBar.
    UiMessage? message,
  }) = _CommentsState;
}
