import 'package:connect_hub/core/database/app_database.dart';
import 'package:connect_hub/core/database/tables/bookmarks_table.dart';
import 'package:connect_hub/core/database/tables/comments_table.dart';
import 'package:connect_hub/core/database/tables/feed_items_table.dart';
import 'package:connect_hub/core/database/tables/posts_table.dart';
import 'package:connect_hub/core/database/tables/users_table.dart';
import 'package:drift/drift.dart';

part 'cache_dao.g.dart';

/// Whole-cache operations.
@DriftAccessor(tables: [Comments, FeedItems, Bookmarks, Posts, Users])
class CacheDao extends DatabaseAccessor<AppDatabase> with _$CacheDaoMixin {
  CacheDao(super.attachedDatabase);

  /// Deletes everything cached. Used when the session ends (logout or
  /// expiry): the cache belongs to the signed-in user, and the next one must
  /// never see it (Correctness Rule 2).
  ///
  /// Children before parents, because posts and comments reference their
  /// authors without a cascade. A table added in a later schema version must
  /// be added here too (a test checks every table ends up empty).
  Future<void> clearAll() {
    return transaction(() async {
      await delete(comments).go();
      await delete(feedItems).go();
      await delete(bookmarks).go();
      await delete(posts).go();
      await delete(users).go();
    });
  }
}
