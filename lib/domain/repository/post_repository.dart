import 'package:connect_hub/core/common/result.dart';
import 'package:connect_hub/domain/model/post.dart';

/// One post: reading it, creating one, liking and bookmarking.
///
/// Likes and bookmarks are optimistic: the cached post changes at once,
/// every screen showing it updates through its own drift stream, and if the
/// server refuses, the change is rolled back and the result is an `Err`.
abstract interface class PostRepository {
  /// The cached post: now, then after every change; `null` while it isn't
  /// cached (or no longer exists).
  Stream<Post?> watchPost(String postId);

  /// Fetches the post into the cache. If the server no longer has it, the
  /// cached copy is removed too, and the result is `NotFoundException`.
  Future<Result<void>> refreshPost(String postId);

  /// Publishes a post by the signed-in user. Once the server has it, it is
  /// cached at the top of the feed.
  Future<Result<void>> createPost({required String content, String? imageUrl});

  Future<Result<void>> setLiked(String postId, {required bool liked});

  Future<Result<void>> setBookmarked(String postId, {required bool bookmarked});
}
