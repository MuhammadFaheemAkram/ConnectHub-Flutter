import 'package:connect_hub/core/common/result.dart';
import 'package:connect_hub/domain/repository/post_repository.dart';
import 'package:injectable/injectable.dart';

/// Bookmarks or un-bookmarks a post (optimistic, rolled back on failure).
@injectable
class BookmarkPostUseCase {
  const BookmarkPostUseCase(this._posts);

  final PostRepository _posts;

  Future<Result<void>> call(String postId, {required bool bookmarked}) =>
      _posts.setBookmarked(postId, bookmarked: bookmarked);
}
