import 'package:connect_hub/domain/repository/search_repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class ClearRecentSearchesUseCase {
  const ClearRecentSearchesUseCase(this._search);

  final SearchRepository _search;

  Future<void> call() => _search.clearRecentSearches();
}
