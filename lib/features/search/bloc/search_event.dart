import 'package:connect_hub/domain/model/post.dart';
import 'package:connect_hub/domain/model/search_scope.dart';

/// What can happen on the Search screen. Search is event-driven (a Bloc), so
/// every input is an explicit, testable event.
sealed class SearchEvent {
  const SearchEvent();
}

/// The screen opened: start following the recent searches.
final class SearchSubscriptionRequested extends SearchEvent {
  const SearchSubscriptionRequested();
}

/// The query changed: the user typed (debounced), or a query was submitted
/// or retried ([immediate], no debounce).
final class SearchQueryChanged extends SearchEvent {
  const SearchQueryChanged(this.query, {this.immediate = false});

  final String query;
  final bool immediate;
}

/// A query was submitted: the keyboard's search button, or a recent search
/// tapped. It runs at once and becomes the newest recent search.
final class SearchSubmitted extends SearchEvent {
  const SearchSubmitted(this.query);

  final String query;
}

/// "Try again" after a failed search: runs the query on screen again.
final class SearchRetried extends SearchEvent {
  const SearchRetried();
}

/// "Clear cache" (Settings) deleted the cached results: search again.
final class SearchCacheCleared extends SearchEvent {
  const SearchCacheCleared();
}

/// A chip: All, People or Posts.
final class SearchScopeChanged extends SearchEvent {
  const SearchScopeChanged(this.scope);

  final SearchScope scope;
}

/// A result was opened (a person, a post, its author or its comments): the
/// query that found it becomes the newest recent search.
final class SearchResultOpened extends SearchEvent {
  const SearchResultOpened();
}

/// "Clear" under the recent searches.
final class SearchRecentSearchesCleared extends SearchEvent {
  const SearchRecentSearchesCleared();
}

final class SearchLikeToggled extends SearchEvent {
  const SearchLikeToggled(this.post);

  final Post post;
}

final class SearchBookmarkToggled extends SearchEvent {
  const SearchBookmarkToggled(this.post);

  final Post post;
}
