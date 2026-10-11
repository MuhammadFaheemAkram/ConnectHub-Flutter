import 'package:connect_hub/domain/model/search_hits.dart';
import 'package:connect_hub/domain/model/search_results.dart';
import 'package:connect_hub/domain/repository/search_repository.dart';
import 'package:injectable/injectable.dart';

/// A search's people and posts, kept live by the cache.
@injectable
class WatchSearchResultsUseCase {
  const WatchSearchResultsUseCase(this._search);

  final SearchRepository _search;

  Stream<SearchResults> call(SearchHits hits) => _search.watchResults(hits);
}
