import 'package:connect_hub/core/database/app_database.dart';
import 'package:connect_hub/core/database/tables/bookmarks_table.dart';
import 'package:connect_hub/core/database/tables/posts_table.dart';
import 'package:connect_hub/core/database/tables/users_table.dart';
import 'package:drift/drift.dart';

part 'posts_dao.g.dart';

/// A cached post with its author and, if the signed-in user bookmarked it,
/// when: the three tables a post is spread across, as one value. Post
/// queries return it, and writes take it.
typedef CachedPost = ({PostRow post, UserRow author, DateTime? bookmarkedAt});

/// The signed-in user's like on one post.
typedef LikeState = ({bool isLiked, int likeCount});

/// Writes to cached posts, whichever screen loaded them, and the signed-in
/// user's likes and bookmarks on them.
@DriftAccessor(tables: [Users, Posts, Bookmarks])
class PostsDao extends DatabaseAccessor<AppDatabase> with _$PostsDaoMixin {
  PostsDao(super.attachedDatabase);

  /// Saves posts as the server returned them: the posts, their authors, and
  /// the viewer's bookmark on each, in one batch (one transaction).
  ///
  /// Every write is an upsert (`INSERT … ON CONFLICT DO UPDATE`), never
  /// `insertOrReplace`. REPLACE deletes the existing row before inserting the
  /// new one, and that delete cascades to everything referencing the post:
  /// its place in the feed, its bookmark, and later its comments.
  Future<void> upsertPosts(List<CachedPost> entries) {
    return batch((batch) {
      batch
        ..insertAllOnConflictUpdate(users, [
          for (final entry in entries) entry.author,
        ])
        ..insertAllOnConflictUpdate(posts, [
          for (final entry in entries) entry.post,
        ])
        // The server's answer is the truth for these posts' bookmarks, so
        // logging in again restores them, and stale ones disappear.
        ..insertAllOnConflictUpdate(bookmarks, [
          for (final entry in entries)
            if (entry.bookmarkedAt case final bookmarkedAt?)
              BookmarkRow(postId: entry.post.id, bookmarkedAt: bookmarkedAt),
        ])
        ..deleteWhere(
          bookmarks,
          (bookmark) => bookmark.postId.isIn([
            for (final entry in entries)
              if (entry.bookmarkedAt == null) entry.post.id,
          ]),
        );
    });
  }

  /// Applies a like at once, before the server confirms it (an optimistic
  /// update), and moves the count by one.
  ///
  /// Returns the state from before, so a failed request can restore it, or
  /// `null` if the post isn't cached.
  Future<LikeState?> applyLike(String postId, {required bool liked}) {
    return transaction(() async {
      final row = await _find(postId);
      if (row == null) return null;
      if (row.isLiked != liked) {
        await writeLike(postId, (
          isLiked: liked,
          likeCount: row.likeCount + (liked ? 1 : -1),
        ));
      }
      return (isLiked: row.isLiked, likeCount: row.likeCount);
    });
  }

  /// Writes a like: the server's answer, or a rollback. It only updates, so a
  /// post that left the cache meanwhile (e.g. at logout) isn't brought back.
  Future<void> writeLike(String postId, LikeState like) {
    final query = update(posts)..where((post) => post.id.equals(postId));
    return query.write(
      PostsCompanion(
        isLiked: Value(like.isLiked),
        likeCount: Value(like.likeCount),
      ),
    );
  }

  /// Applies a bookmark change at once: bookmarked [at] that time, or
  /// removed when [at] is `null`.
  ///
  /// Returns when the post was bookmarked before (`null`: it wasn't), so a
  /// failed request can restore it.
  Future<DateTime?> applyBookmark(String postId, {required DateTime? at}) {
    return transaction(() async {
      final query = select(bookmarks)
        ..where((bookmark) => bookmark.postId.equals(postId));
      final before = await query.getSingleOrNull();
      await writeBookmark(postId, at: at);
      return before?.bookmarkedAt;
    });
  }

  /// Writes a bookmark: bookmarked [at] that time, or removed when [at] is
  /// `null`. A post that isn't cached is skipped, because a bookmark row
  /// needs its post.
  Future<void> writeBookmark(String postId, {required DateTime? at}) {
    return transaction(() async {
      if (at == null) {
        await (delete(
          bookmarks,
        )..where((bookmark) => bookmark.postId.equals(postId))).go();
      } else if (await _find(postId) != null) {
        await into(
          bookmarks,
        ).insertOnConflictUpdate(BookmarkRow(postId: postId, bookmarkedAt: at));
      }
    });
  }

  Future<PostRow?> _find(String postId) {
    final query = select(posts)..where((post) => post.id.equals(postId));
    return query.getSingleOrNull();
  }
}
