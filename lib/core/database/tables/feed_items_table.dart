import 'package:connect_hub/core/database/tables/posts_table.dart';
import 'package:drift/drift.dart';

/// Which cached posts make up the feed: the window the server has paged in so
/// far.
///
/// Membership is a table of its own instead of "every cached post", so
/// refreshing the feed replaces exactly this list, and posts cached by other
/// screens never appear in the feed. The order comes from the posts
/// themselves (newest first), the same order the server pages in.
@DataClassName('FeedItemRow')
class FeedItems extends Table {
  TextColumn get postId =>
      text().references(Posts, #id, onDelete: KeyAction.cascade)();

  @override
  Set<Column<Object>> get primaryKey => {postId};
}
