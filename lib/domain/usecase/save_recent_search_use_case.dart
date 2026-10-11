import 'package:connect_hub/domain/repository/search_repository.dart';
import 'package:injectable/injectable.dart';

/// Remembers a query as the newest recent search. Called on a keyboard
/// submit or a result tap only, never per keystroke (Correctness Rule 11).
@injectable
class SaveRecentSearchUseCase {
  const SaveRecentSearchUseCase(this._search);

  final SearchRepository _search;

  Future<void> call(String query) => _search.saveRecentSearch(query);
}
