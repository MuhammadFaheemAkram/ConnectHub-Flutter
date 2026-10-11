import 'package:connect_hub/core/database/app_database.dart';
import 'package:connect_hub/core/database/tables/comments_table.dart';
import 'package:connect_hub/core/database/tables/posts_table.dart';
import 'package:connect_hub/core/database/tables/users_table.dart';
import 'package:drift/drift.dart';

part 'comments_dao.g.dart';

/// A cached comment with its author.
typedef CachedComment = ({CommentRow comment, UserRow author});

/// Cached comments, and the post's `commentCount` that moves with them.
///
/// A comment row needs its post (a foreign key). Every write first checks
/// that the post is still cached and does nothing otherwise, so a write that
/// races a logout (which wipes the cache) can't fail or bring data back.
@DriftAccessor(tables: [Comments, Users, Posts])
class CommentsDao extends DatabaseAccessor<AppDatabase>
    with _$CommentsDaoMixin {
  CommentsDao(super.attachedDatabase);

  /// The comments on [postId], oldest first (ties by id), each JOINed with
  /// its author, emitted again whenever they change.
  Stream<List<CachedComment>> watchComments(String postId) {
    final query =
        select(comments)
            .join([innerJoin(users, users.id.equalsExp(comments.authorId))])
          ..where(comments.postId.equals(postId))
          ..orderBy([
            OrderingTerm.asc(comments.createdAt),
            OrderingTerm.asc(comments.id),
          ]);
    return query.watch().map(
      (rows) => [
        for (final row in rows)
          (comment: row.readTable(comments), author: row.readTable(users)),
      ],
    );
  }

  /// Mirrors the server's comments on [postId] (Correctness Rule 1): upserts
  /// what it returned, deletes what it no longer has, and sets the post's
  /// count to match, all in one transaction.
  Future<void> replaceComments(String postId, List<CachedComment> entries) {
    return transaction(() async {
      if (!await _isPostCached(postId)) return;
      await batch((batch) {
        batch
          ..insertAllOnConflictUpdate(users, [
            for (final entry in entries) entry.author,
          ])
          ..insertAllOnConflictUpdate(comments, [
            for (final entry in entries) entry.comment,
          ])
          ..deleteWhere(
            comments,
            (comment) =>
                comment.postId.equals(postId) &
                comment.id.isNotIn([
                  for (final entry in entries) entry.comment.id,
                ]),
          );
      });
      await _setCount(postId, entries.length);
    });
  }

  /// Caches a comment the server has just accepted, and counts it.
  Future<void> addComment(CachedComment entry) => _insert(entry);

  /// Removes a comment at once (an optimistic delete) and uncounts it.
  ///
  /// Returns what was removed, so a failed request can put it back, or
  /// `null` if it wasn't cached.
  Future<CachedComment?> removeComment(String commentId) {
    return transaction(() async {
      final query = select(comments).join([
        innerJoin(users, users.id.equalsExp(comments.authorId)),
      ])..where(comments.id.equals(commentId));
      final row = await query.getSingleOrNull();
      if (row == null) return null;
      final removed = (
        comment: row.readTable(comments),
        author: row.readTable(users),
      );
      await (delete(
        comments,
      )..where((comment) => comment.id.equals(commentId))).go();
      await _moveCount(removed.comment.postId, -1);
      return removed;
    });
  }

  /// Puts back a comment whose delete failed, and counts it again.
  Future<void> restoreComment(CachedComment entry) => _insert(entry);

  Future<void> _insert(CachedComment entry) {
    return transaction(() async {
      final postId = entry.comment.postId;
      if (!await _isPostCached(postId)) return;
      await into(users).insertOnConflictUpdate(entry.author);
      await into(comments).insertOnConflictUpdate(entry.comment);
      await _moveCount(postId, 1);
    });
  }

  Future<bool> _isPostCached(String postId) async {
    final query = select(posts)..where((post) => post.id.equals(postId));
    return await query.getSingleOrNull() != null;
  }

  Future<void> _setCount(String postId, int count) {
    final query = update(posts)..where((post) => post.id.equals(postId));
    return query.write(PostsCompanion(commentCount: Value(count)));
  }

  /// Moves the post's count by [delta], never below zero.
  Future<void> _moveCount(String postId, int delta) {
    return customUpdate(
      'UPDATE posts SET comment_count = MAX(comment_count + ?, 0) '
      'WHERE id = ?',
      variables: [Variable.withInt(delta), Variable.withString(postId)],
      updates: {posts},
      updateKind: UpdateKind.update,
    );
  }
}
