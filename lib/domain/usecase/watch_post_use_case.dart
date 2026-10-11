import 'package:connect_hub/domain/model/post.dart';
import 'package:connect_hub/domain/repository/post_repository.dart';
import 'package:injectable/injectable.dart';

/// One cached post as a stream: now, then every change; `null` while it
/// isn't cached.
@injectable
class WatchPostUseCase {
  const WatchPostUseCase(this._posts);

  final PostRepository _posts;

  Stream<Post?> call(String postId) => _posts.watchPost(postId);
}
