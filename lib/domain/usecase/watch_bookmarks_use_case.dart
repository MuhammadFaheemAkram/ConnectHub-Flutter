import 'package:connect_hub/domain/model/post.dart';
import 'package:connect_hub/domain/repository/bookmark_repository.dart';
import 'package:injectable/injectable.dart';

/// The cached bookmarks as a stream, the most recently bookmarked first.
@injectable
class WatchBookmarksUseCase {
  const WatchBookmarksUseCase(this._bookmarks);

  final BookmarkRepository _bookmarks;

  Stream<List<Post>> call() => _bookmarks.watchBookmarks();
}
