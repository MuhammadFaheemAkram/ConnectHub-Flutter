import 'package:connect_hub/core/common/ui_message.dart';
import 'package:connect_hub/domain/model/comment.dart';
import 'package:connect_hub/domain/model/post.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'post_detail_state.freezed.dart';

@freezed
sealed class PostDetailState with _$PostDetailState {
  /// The post isn't cached, and the server hasn't answered yet.
  const factory PostDetailState.loading() = PostDetailLoading;

  /// The post isn't cached, and fetching it failed.
  const factory PostDetailState.error(String message) = PostDetailError;

  /// The server doesn't have this post (any more).
  const factory PostDetailState.notFound() = PostDetailNotFound;

  const factory PostDetailState.loaded({
    required Post post,

    /// The latest few comments, the oldest of them first.
    @Default(<Comment>[]) List<Comment> recentComments,
    @Default(false) bool isSending,

    /// Goes up by one each time a comment is sent. A one-time effect: the
    /// View clears the input when it changes.
    @Default(0) int sentCount,

    /// A one-time SnackBar.
    UiMessage? message,
  }) = PostDetailLoaded;
}
