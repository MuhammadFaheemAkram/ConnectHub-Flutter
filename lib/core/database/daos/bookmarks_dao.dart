import 'package:connect_hub/core/database/app_database.dart';
import 'package:connect_hub/core/database/daos/posts_dao.dart';
import 'package:connect_hub/core/database/tables/bookmarks_table.dart';
import 'package:connect_hub/core/database/tables/posts_table.dart';
import 'package:connect_hub/core/database/tables/users_table.dart';
import 'package:drift/drift.dart';

part 'bookmarks_dao.g.dart';

/// The signed-in user's bookmarks, cached so the Bookmarks tab works
/// offline.
@DriftAccessor(tables: [Bookmarks, Posts, Users])
class BookmarksDao extends DatabaseAccessor<AppDatabase>
    with _$BookmarksDaoMixin {
  BookmarksDao(super.attachedDatabase);

  /// The bookmarked posts, the most recently bookmarked first (ties by id),
  /// each with its author, emitted again whenever any of the three tables
  /// changes. A like or a bookmark made on any screen shows here at once.
  Stream<List<CachedPost>> watchBookmarks() {
    final query =
        select(bookmarks).join([
          innerJoin(posts, posts.id.equalsExp(bookmarks.postId)),
          innerJoin(users, users.id.equalsExp(posts.authorId)),
        ])..orderBy([
          OrderingTerm.desc(bookmarks.bookmarkedAt),
          OrderingTerm.desc(posts.id),
        ]);
    final postsDao = attachedDatabase.postsDao;
    return query.watch().map(
      (rows) => [for (final row in rows) postsDao.readPost(row)],
    );
  }

  /// Mirrors the server's bookmarks (Correctness Rule 1): upserts the posts
  /// it returned (with their bookmarks), and removes the bookmarks it no
  /// longer has, in one transaction.
  ///
  /// Only the *bookmark* rows go. The posts themselves stay cached: they may
  /// still be in the feed or on a profile.
  Future<void> replaceBookmarks(List<CachedPost> entries) {
    return transaction(() async {
      await attachedDatabase.postsDao.upsertPosts(entries);
      await (delete(bookmarks)..where(
            (bookmark) => bookmark.postId.isNotIn([
              for (final entry in entries) entry.post.id,
            ]),
          ))
          .go();
    });
  }
}
