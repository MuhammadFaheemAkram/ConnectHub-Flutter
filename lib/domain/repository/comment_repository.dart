import 'package:connect_hub/core/common/result.dart';
import 'package:connect_hub/domain/model/comment.dart';

/// A post's comments, cached in drift and refreshed from the server.
///
/// Adding and deleting also move the post's `commentCount`, so every screen
/// showing the post stays consistent.
abstract interface class CommentRepository {
  /// The cached comments on [postId], oldest first: the current list, then
  /// every change.
  Stream<List<Comment>> watchComments(String postId);

  /// Makes the cache match the server's comments on [postId].
  Future<Result<void>> refreshComments(String postId);

  /// Sends a comment. It is cached once the server has accepted it.
  Future<Result<void>> addComment(String postId, String text);

  /// Deletes one of the signed-in user's comments: at once, and rolled back
  /// if the server refuses.
  Future<Result<void>> deleteComment(String commentId);
}
