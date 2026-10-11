import 'package:connect_hub/core/common/result.dart';
import 'package:connect_hub/domain/repository/comment_repository.dart';
import 'package:injectable/injectable.dart';

/// Makes a post's cached comments match the server's.
@injectable
class RefreshCommentsUseCase {
  const RefreshCommentsUseCase(this._comments);

  final CommentRepository _comments;

  Future<Result<void>> call(String postId) => _comments.refreshComments(postId);
}
