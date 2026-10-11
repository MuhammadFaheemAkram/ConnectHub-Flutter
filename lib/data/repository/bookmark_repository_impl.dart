import 'package:connect_hub/core/common/result.dart';
import 'package:connect_hub/core/database/daos/bookmarks_dao.dart';
import 'package:connect_hub/core/network/api/feed_api_service.dart';
import 'package:connect_hub/data/mapper/post_mappers.dart';
import 'package:connect_hub/data/repository/api_guard.dart';
import 'package:connect_hub/domain/model/post.dart';
import 'package:connect_hub/domain/repository/bookmark_repository.dart';
import 'package:injectable/injectable.dart';

/// Bookmarks are the server's; the cache is what makes them work offline.
///
/// This repository only lists them: it mirrors the server's list into drift,
/// and the screen reads drift. Adding and removing a bookmark goes through
/// `PostRepository.setBookmarked`, the optimistic write every screen uses,
/// so a change made anywhere shows in the list at once.
@LazySingleton(as: BookmarkRepository)
class BookmarkRepositoryImpl implements BookmarkRepository {
  BookmarkRepositoryImpl(this._api, this._bookmarks, this._guard);

  final FeedApiService _api;
  final BookmarksDao _bookmarks;
  final ApiGuard _guard;

  @override
  Stream<List<Post>> watchBookmarks() => _bookmarks.watchBookmarks().map(
    (entries) => [for (final entry in entries) entry.toDomain()],
  );

  @override
  Future<Result<void>> refreshBookmarks() async {
    final result = await _guard.run(_api.getBookmarks);
    switch (result) {
      case Ok(value: final posts):
        await _bookmarks.replaceBookmarks([
          for (final post in posts) post.toCached(),
        ]);
        return const Ok(null);
      case Err(:final exception):
        return Err(exception);
    }
  }
}
