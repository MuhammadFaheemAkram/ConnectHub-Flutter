import 'package:connect_hub/core/database/tables/posts_table.dart';
import 'package:drift/drift.dart';

/// The signed-in user's bookmarks: a cached copy of the server's list, so the
/// Bookmarks tab works offline (Phase 5).
///
/// `ON DELETE CASCADE`: a bookmark goes when its post leaves the cache. That
/// is exactly why posts are written with upserts and never `REPLACE`, which
/// deletes the old row before inserting the new one and so would silently
/// delete the bookmark too (the Android edition's bug).
@DataClassName('BookmarkRow')
class Bookmarks extends Table {
  TextColumn get postId =>
      text().references(Posts, #id, onDelete: KeyAction.cascade)();

  /// UTC. The Bookmarks tab lists the most recent first.
  DateTimeColumn get bookmarkedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {postId};
}
