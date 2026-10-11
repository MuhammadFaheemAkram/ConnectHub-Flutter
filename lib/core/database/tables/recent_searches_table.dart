import 'package:drift/drift.dart';

/// The user's recent searches (schema v3, Phase 5), newest first.
///
/// The client owns them: the server never sees this list. They are still
/// the signed-in user's data, so logout deletes them with the cache.
///
/// The key is the query normalized (trimmed, lower-case), so "Ada" and
/// " ada" are one entry; searching it again only moves it to the top
/// (Correctness Rule 11).
@DataClassName('RecentSearchRow')
class RecentSearches extends Table {
  /// The trimmed, lower-case query: what makes two spellings one entry.
  TextColumn get normalizedQuery => text()();

  /// The query as last searched (trimmed): what the list shows.
  TextColumn get displayText => text()();

  /// UTC. The list shows the most recent first.
  DateTimeColumn get searchedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {normalizedQuery};
}
