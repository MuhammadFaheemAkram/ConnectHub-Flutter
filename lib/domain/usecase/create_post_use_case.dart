import 'package:connect_hub/core/common/result.dart';
import 'package:connect_hub/domain/repository/post_repository.dart';
import 'package:injectable/injectable.dart';

/// Publishes a post. Values are trimmed before they are sent, and an empty
/// image URL means "no image".
@injectable
class CreatePostUseCase {
  const CreatePostUseCase(this._posts);

  final PostRepository _posts;

  Future<Result<void>> call({required String content, String imageUrl = ''}) {
    final url = imageUrl.trim();
    return _posts.createPost(
      content: content.trim(),
      imageUrl: url.isEmpty ? null : url,
    );
  }
}
