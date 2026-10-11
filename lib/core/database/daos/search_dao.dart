import 'package:connect_hub/core/database/app_database.dart';
import 'package:connect_hub/core/database/daos/posts_dao.dart';
import 'package:connect_hub/core/database/tables/bookmarks_table.dart';
import 'package:connect_hub/core/database/tables/posts_table.dart';
import 'package:connect_hub/core/database/tables/recent_searches_table.dart';
import 'package:connect_hub/core/database/tables/users_table.dart';
import 'package:drift/drift.dart';

part 'search_dao.g.dart';

/// What Search keeps: the people and posts a search found, read back by id,
/// and the list of recent searches.
@DriftAccessor(tables: [Users, Posts, Bookmarks, RecentSearches])
class SearchDao extends DatabaseAccessor<AppDatabase> with _$SearchDaoMixin {
  SearchDao(super.attachedDatabase);

  /// How many recent searches are kept (Correctness Rule 11).
  static const maxRecentSearches = 10;

  /// Caches a search's people and posts, in one transaction.
  ///
  /// Cached posts don't join the feed: the feed is its own list
  /// (`feed_items`), so a search never changes what the Feed shows.
  Future<void> cacheResults({
    required List<UserRow> people,
    required List<CachedPost> posts,
  }) {
    return transaction(() async {
      await batch((batch) => batch.insertAllOnConflictUpdate(users, people));
      await attachedDatabase.postsDao.upsertPosts(posts);
    });
  }

  /// The cached profiles among [ids], in no particular order, emitted again
  /// whenever one changes.
  Stream<List<UserRow>> watchUsers(List<String> ids) =>
      (select(users)..where((user) => user.id.isIn(ids))).watch();

  /// The cached posts among [ids], in no particular order, each with its
  /// author and the viewer's bookmark, emitted again whenever one changes (a
  /// like on any screen, say).
  Stream<List<CachedPost>> watchPosts(List<String> ids) {
    final query = select(posts).join([
      innerJoin(users, users.id.equalsExp(posts.authorId)),
      leftOuterJoin(bookmarks, bookmarks.postId.equalsExp(posts.id)),
    ])..where(posts.id.isIn(ids));
    final postsDao = attachedDatabase.postsDao;
    return query.watch().map(
      (rows) => [for (final row in rows) postsDao.readPost(row)],
    );
  }

  /// The recent searches, newest first.
  Stream<List<RecentSearchRow>> watchRecentSearches() {
    final query = select(recentSearches)
      ..orderBy([
        (search) => OrderingTerm.desc(search.searchedAt),
        (search) => OrderingTerm.asc(search.normalizedQuery),
      ])
      ..limit(maxRecentSearches);
    return query.watch();
  }

  /// Saves [query] as searched [at] that time (Correctness Rule 11):
  /// - trimmed, and ignored when blank;
  /// - one entry per query, ignoring case: searching it again moves it to
  ///   the top, spelled as it was typed this time;
  /// - only the [maxRecentSearches] newest are kept.
  Future<void> saveRecentSearch(String query, {required DateTime at}) {
    final text = query.trim();
    if (text.isEmpty) return Future.value();
    return transaction(() async {
      await into(recentSearches).insertOnConflictUpdate(
        RecentSearchRow(
          normalizedQuery: text.toLowerCase(),
          displayText: text,
          searchedAt: at,
        ),
      );
      final newest = selectOnly(recentSearches)
        ..addColumns([recentSearches.normalizedQuery])
        ..orderBy([
          OrderingTerm.desc(recentSearches.searchedAt),
          OrderingTerm.asc(recentSearches.normalizedQuery),
        ])
        ..limit(maxRecentSearches);
      await (delete(
        recentSearches,
      )..where((search) => search.normalizedQuery.isNotInQuery(newest))).go();
    });
  }

  Future<void> clearRecentSearches() => delete(recentSearches).go();
}
