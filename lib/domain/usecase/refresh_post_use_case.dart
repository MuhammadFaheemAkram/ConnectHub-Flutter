import 'package:connect_hub/core/common/result.dart';
import 'package:connect_hub/domain/repository/post_repository.dart';
import 'package:injectable/injectable.dart';

/// Fetches one post into the cache.
@injectable
class RefreshPostUseCase {
  const RefreshPostUseCase(this._posts);

  final PostRepository _posts;

  Future<Result<void>> call(String postId) => _posts.refreshPost(postId);
}
