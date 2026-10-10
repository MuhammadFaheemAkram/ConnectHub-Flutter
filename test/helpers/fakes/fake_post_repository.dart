import 'package:connect_hub/core/common/result.dart';
import 'package:connect_hub/domain/repository/post_repository.dart';

/// A scriptable [PostRepository]: set the results, read back the calls.
class FakePostRepository implements PostRepository {
  Result<void> likeResult = const Ok(null);
  Result<void> bookmarkResult = const Ok(null);

  final likeCalls = <({String postId, bool liked})>[];
  final bookmarkCalls = <({String postId, bool bookmarked})>[];

  @override
  Future<Result<void>> setLiked(String postId, {required bool liked}) async {
    likeCalls.add((postId: postId, liked: liked));
    return likeResult;
  }

  @override
  Future<Result<void>> setBookmarked(
    String postId, {
    required bool bookmarked,
  }) async {
    bookmarkCalls.add((postId: postId, bookmarked: bookmarked));
    return bookmarkResult;
  }
}
