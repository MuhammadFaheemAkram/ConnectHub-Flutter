import 'package:connect_hub/core/common/result.dart';
import 'package:connect_hub/domain/repository/comment_repository.dart';
import 'package:injectable/injectable.dart';

/// Deletes one of the signed-in user's comments (optimistic, rolled back on
/// failure).
@injectable
class DeleteCommentUseCase {
  const DeleteCommentUseCase(this._comments);

  final CommentRepository _comments;

  Future<Result<void>> call(String commentId) =>
      _comments.deleteComment(commentId);
}
