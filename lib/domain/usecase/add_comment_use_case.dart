import 'package:connect_hub/core/common/result.dart';
import 'package:connect_hub/domain/repository/comment_repository.dart';
import 'package:injectable/injectable.dart';

/// Sends a comment, trimmed.
@injectable
class AddCommentUseCase {
  const AddCommentUseCase(this._comments);

  final CommentRepository _comments;

  Future<Result<void>> call(String postId, String text) =>
      _comments.addComment(postId, text.trim());
}
