import 'package:connect_hub/core/database/app_database.dart';
import 'package:connect_hub/core/database/daos/posts_dao.dart';
import 'package:connect_hub/core/database/tables/bookmarks_table.dart';
import 'package:connect_hub/core/database/tables/feed_items_table.dart';
import 'package:connect_hub/core/database/tables/posts_table.dart';
import 'package:connect_hub/core/database/tables/users_table.dart';
import 'package:drift/drift.dart';

part 'feed_dao.g.dart';

/// The feed window: which cached posts are in the feed, and the feed itself
/// as a live query.
@DriftAccessor(tables: [FeedItems, Posts, Users, Bookmarks])
class FeedDao extends DatabaseAccessor<AppDatabase> with _$FeedDaoMixin {
  FeedDao(super.attachedDatabase);

  /// The feed, newest first (ties by id, like the server), emitted again
  /// whenever any of the four tables changes.
  ///
  /// It JOINs `users` for each author, so a renamed author is renamed on
  /// every post at once, and LEFT JOINs `bookmarks`, which a post may or may
  /// not have.
  Stream<List<CachedPost>> watchFeed() {
    final query =
        select(feedItems).join([
          innerJoin(posts, posts.id.equalsExp(feedItems.postId)),
          innerJoin(users, users.id.equalsExp(posts.authorId)),
          leftOuterJoin(bookmarks, bookmarks.postId.equalsExp(posts.id)),
        ])..orderBy([
          OrderingTerm.desc(posts.createdAt),
          OrderingTerm.desc(posts.id),
        ]);
    final postsDao = attachedDatabase.postsDao;
    return query.watch().map(
      (rows) => [for (final row in rows) postsDao.readPost(row)],
    );
  }

  /// Replaces the window with [page] (a refresh).
  ///
  /// One transaction: drift notifies watchers once, after it commits, so
  /// nobody ever sees the window empty or half-replaced in between.
  Future<void> replaceFeed(List<CachedPost> page) {
    return transaction(() async {
      await delete(feedItems).go();
      await _add(page);
    });
  }

  /// Adds [entries] to the window: the next page (load more), or a post just
  /// created. Where each one shows comes from its date, so a new post lands
  /// on top and a next page at the bottom. A post already in the window is
  /// updated, never listed twice.
  Future<void> addToFeed(List<CachedPost> entries) {
    return transaction(() => _add(entries));
  }

  Future<void> _add(List<CachedPost> page) async {
    await attachedDatabase.postsDao.upsertPosts(page);
    await batch(
      (batch) => batch.insertAll(feedItems, [
        for (final entry in page) FeedItemRow(postId: entry.post.id),
      ], mode: InsertMode.insertOrIgnore),
    );
  }
}
