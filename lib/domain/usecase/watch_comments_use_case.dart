import 'package:connect_hub/domain/model/comment.dart';
import 'package:connect_hub/domain/repository/comment_repository.dart';
import 'package:injectable/injectable.dart';

/// A post's cached comments as a stream, oldest first.
@injectable
class WatchCommentsUseCase {
  const WatchCommentsUseCase(this._comments);

  final CommentRepository _comments;

  Stream<List<Comment>> call(String postId) => _comments.watchComments(postId);
}
