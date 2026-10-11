import 'package:connect_hub/domain/repository/search_repository.dart';
import 'package:injectable/injectable.dart';

/// The recent searches as a stream, newest first.
@injectable
class WatchRecentSearchesUseCase {
  const WatchRecentSearchesUseCase(this._search);

  final SearchRepository _search;

  Stream<List<String>> call() => _search.watchRecentSearches();
}
