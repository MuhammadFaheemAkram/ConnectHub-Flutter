import 'package:connect_hub/core/common/result.dart';
import 'package:connect_hub/domain/model/post.dart';

/// The signed-in user's bookmarks: owned by the server, cached in drift so
/// the Bookmarks tab works offline.
///
/// Adding and removing a bookmark is `PostRepository.setBookmarked`, the same
/// optimistic write every screen uses.
abstract interface class BookmarkRepository {
  /// The cached bookmarks, the most recently bookmarked first: the current
  /// list, then every change.
  Stream<List<Post>> watchBookmarks();

  /// Makes the cache match the server's bookmarks.
  Future<Result<void>> refreshBookmarks();
}
