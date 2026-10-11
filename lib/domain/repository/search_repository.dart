import 'package:connect_hub/core/common/result.dart';
import 'package:connect_hub/domain/model/search_hits.dart';
import 'package:connect_hub/domain/model/search_results.dart';

/// Searching people and posts, and the list of recent searches.
///
/// A search is two steps, so its results can stay live:
/// 1. [search] asks the server, caches what it found, and returns the ids;
/// 2. [watchResults] reads those ids from the cache, so a like or a
///    bookmark made on any screen shows in the results at once.
abstract interface class SearchRepository {
  Future<Result<SearchHits>> search(String query);

  /// The cached people and posts for [hits], in the server's order: now,
  /// then after every change. One that leaves the cache drops out.
  Stream<SearchResults> watchResults(SearchHits hits);

  /// The recent searches, newest first (at most 10).
  Stream<List<String>> watchRecentSearches();

  /// Remembers [query] as the newest recent search (Correctness Rule 11:
  /// trimmed, one entry per query ignoring case, at most 10).
  Future<void> saveRecentSearch(String query);

  Future<void> clearRecentSearches();
}
