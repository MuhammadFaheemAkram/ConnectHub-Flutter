import 'package:connect_hub/core/common/result.dart';
import 'package:connect_hub/domain/repository/post_repository.dart';
import 'package:injectable/injectable.dart';

/// Likes or unlikes a post (optimistic, rolled back on failure).
@injectable
class LikePostUseCase {
  const LikePostUseCase(this._posts);

  final PostRepository _posts;

  Future<Result<void>> call(String postId, {required bool liked}) =>
      _posts.setLiked(postId, liked: liked);
}
