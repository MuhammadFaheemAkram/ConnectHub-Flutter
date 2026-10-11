import 'package:connect_hub/core/common/result.dart';
import 'package:connect_hub/domain/repository/bookmark_repository.dart';
import 'package:injectable/injectable.dart';

/// Fetches the server's bookmarks into the cache.
@injectable
class RefreshBookmarksUseCase {
  const RefreshBookmarksUseCase(this._bookmarks);

  final BookmarkRepository _bookmarks;

  Future<Result<void>> call() => _bookmarks.refreshBookmarks();
}
