import 'package:connect_hub/core/common/ui_message.dart';
import 'package:connect_hub/domain/model/post.dart';
import 'package:connect_hub/domain/model/search_results.dart';
import 'package:connect_hub/domain/model/search_scope.dart';
import 'package:connect_hub/domain/model/user.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'search_state.freezed.dart';

/// Where the search stands.
enum SearchStatus {
  /// Nothing to search: the recent searches show instead.
  idle,

  /// The server hasn't answered yet. The previous results, if any, stay on
  /// screen meanwhile.
  loading,

  /// The results are in, and stay live.
  success,

  /// The search failed.
  failure,
}

/// One class rather than a union: the scope and the recent searches outlive
/// every status (the chips stay put while a search runs), much like
/// `CommentsState`.
@freezed
abstract class SearchState with _$SearchState {
  const SearchState._();

  const factory SearchState({
    @Default(SearchStatus.idle) SearchStatus status,

    /// The query being searched or shown, trimmed.
    @Default('') String query,
    @Default(SearchScope.all) SearchScope scope,

    /// Everything the server found, whatever the scope.
    @Default(SearchResults()) SearchResults results,

    /// Newest first.
    @Default(<String>[]) List<String> recentSearches,
    @Default('') String errorMessage,

    /// A one-time SnackBar.
    UiMessage? message,
  }) = _SearchState;

  /// The people the current scope shows.
  List<User> get people =>
      scope == SearchScope.posts ? const [] : results.users;

  /// The posts the current scope shows.
  List<Post> get posts =>
      scope == SearchScope.people ? const [] : results.posts;

  /// A finished search with nothing to show in the current scope.
  bool get hasNoMatches =>
      status == SearchStatus.success && people.isEmpty && posts.isEmpty;
}
