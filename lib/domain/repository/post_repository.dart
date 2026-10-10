import 'package:connect_hub/core/common/result.dart';

/// Actions on a single post. Phase 4 adds reading one post and creating
/// posts.
///
/// Both actions are optimistic: the cached post changes at once, every screen
/// showing it updates through its own drift stream, and if the server
/// refuses, the change is rolled back and the result is an `Err`.
abstract interface class PostRepository {
  Future<Result<void>> setLiked(String postId, {required bool liked});

  Future<Result<void>> setBookmarked(String postId, {required bool bookmarked});
}
