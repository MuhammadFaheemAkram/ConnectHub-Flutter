import 'package:connect_hub/core/common/result.dart';
import 'package:connect_hub/domain/model/search_hits.dart';
import 'package:connect_hub/domain/repository/search_repository.dart';
import 'package:injectable/injectable.dart';

/// Searches people and posts. Returns what matched as ids; the results are
/// then watched from the cache ([WatchSearchResultsUseCase]).
@injectable
class SearchUseCase {
  const SearchUseCase(this._search);

  final SearchRepository _search;

  Future<Result<SearchHits>> call(String query) => _search.search(query.trim());
}
