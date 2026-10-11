import 'package:connect_hub/core/common/result.dart';
import 'package:connect_hub/core/common/ui_message.dart';
import 'package:connect_hub/domain/model/search_hits.dart';
import 'package:connect_hub/domain/model/search_results.dart';
import 'package:connect_hub/domain/usecase/bookmark_post_use_case.dart';
import 'package:connect_hub/domain/usecase/clear_recent_searches_use_case.dart';
import 'package:connect_hub/domain/usecase/like_post_use_case.dart';
import 'package:connect_hub/domain/usecase/save_recent_search_use_case.dart';
import 'package:connect_hub/domain/usecase/search_use_case.dart';
import 'package:connect_hub/domain/usecase/watch_recent_searches_use_case.dart';
import 'package:connect_hub/domain/usecase/watch_search_results_use_case.dart';
import 'package:connect_hub/features/search/bloc/search_event.dart';
import 'package:connect_hub/features/search/bloc/search_state.dart';
import 'package:connect_hub/features/search/bloc/search_transformers.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

/// Drives the Search screen.
///
/// It is a **Bloc**, not a Cubit, because typing is a *stream* of events that
/// needs shaping: debounced, with stale searches cancelled. Event transformers
/// express that declaratively (see [debounceRestartable]), which a Cubit's
/// plain methods can't do without hand-written timers.
///
/// A search is a request, then a subscription: the handler asks the server,
/// then stays on `emit.forEach` over the cached results, so a like made on
/// any screen updates them. The next query's restart ends that subscription.
@injectable
class SearchBloc extends Bloc<SearchEvent, SearchState> {
  SearchBloc(
    this._search,
    this._watchResults,
    this._watchRecentSearches,
    this._saveRecentSearch,
    this._clearRecentSearches,
    this._likePost,
    this._bookmarkPost, {
    @ignoreParam Duration debounce = const Duration(milliseconds: 300),
  }) : super(const SearchState()) {
    on<SearchSubscriptionRequested>(_onSubscriptionRequested);
    on<SearchQueryChanged>(
      _onQueryChanged,
      transformer: debounceRestartable(debounce),
    );
    on<SearchSubmitted>(_onSubmitted);
    on<SearchRetried>(_onRetried);
    on<SearchScopeChanged>(_onScopeChanged);
    on<SearchResultOpened>(_onResultOpened);
    on<SearchRecentSearchesCleared>(_onRecentSearchesCleared);
    on<SearchLikeToggled>(_onLikeToggled);
    on<SearchBookmarkToggled>(_onBookmarkToggled);
  }

  final SearchUseCase _search;
  final WatchSearchResultsUseCase _watchResults;
  final WatchRecentSearchesUseCase _watchRecentSearches;
  final SaveRecentSearchUseCase _saveRecentSearch;
  final ClearRecentSearchesUseCase _clearRecentSearches;
  final LikePostUseCase _likePost;
  final BookmarkPostUseCase _bookmarkPost;

  static const likeFailedMessage =
      "Couldn't update the like. Please try again.";
  static const bookmarkFailedMessage =
      "Couldn't update the bookmark. Please try again.";

  /// What the search on screen matched, so the same query coming back needs
  /// no new request.
  SearchHits? _shownHits;
  int _messageCount = 0;

  Future<void> _onSubscriptionRequested(
    SearchSubscriptionRequested event,
    Emitter<SearchState> emit,
  ) {
    return emit.forEach(
      _watchRecentSearches(),
      onData: (recent) => state.copyWith(recentSearches: recent),
    );
  }

  Future<void> _onQueryChanged(
    SearchQueryChanged event,
    Emitter<SearchState> emit,
  ) async {
    final query = event.query.trim();
    if (query.isEmpty) {
      _shownHits = null;
      emit(
        state.copyWith(
          status: SearchStatus.idle,
          query: '',
          results: const SearchResults(),
        ),
      );
      return;
    }
    // The query on screen came back (e.g. "ada" → "ad" → "ada" within the
    // debounce): no new request. Restarting has ended its live results,
    // though, so follow them again.
    final shown = _shownHits;
    if (shown != null &&
        query == state.query &&
        state.status == SearchStatus.success) {
      return _follow(shown, emit);
    }

    _shownHits = null;
    emit(state.copyWith(status: SearchStatus.loading, query: query));
    final result = await _search(query);
    // A newer query restarted this handler meanwhile: everything from here
    // on belongs to it.
    if (emit.isDone) return;
    switch (result) {
      case Ok(value: final hits):
        _shownHits = hits;
        await _follow(hits, emit);
      case Err(:final exception):
        emit(
          state.copyWith(
            status: SearchStatus.failure,
            errorMessage: exception.message,
            results: const SearchResults(),
          ),
        );
    }
  }

  /// Shows the cached results for [hits], and every change to them, until a
  /// newer query restarts the handler.
  Future<void> _follow(SearchHits hits, Emitter<SearchState> emit) {
    return emit.forEach(
      _watchResults(hits),
      onData: (results) =>
          state.copyWith(status: SearchStatus.success, results: results),
    );
  }

  /// Runs the query at once (through the same restartable pipeline, so it
  /// replaces any search in flight) and remembers it.
  Future<void> _onSubmitted(
    SearchSubmitted event,
    Emitter<SearchState> emit,
  ) async {
    final query = event.query.trim();
    if (query.isEmpty) return;
    add(SearchQueryChanged(query, immediate: true));
    await _saveRecentSearch(query);
  }

  void _onRetried(SearchRetried event, Emitter<SearchState> emit) {
    if (state.query.isEmpty) return;
    add(SearchQueryChanged(state.query, immediate: true));
  }

  /// The server answers with people and posts alike, so a scope only filters
  /// what is already there.
  void _onScopeChanged(SearchScopeChanged event, Emitter<SearchState> emit) {
    emit(state.copyWith(scope: event.scope));
  }

  Future<void> _onResultOpened(
    SearchResultOpened event,
    Emitter<SearchState> emit,
  ) async {
    if (state.query.isNotEmpty) await _saveRecentSearch(state.query);
  }

  Future<void> _onRecentSearchesCleared(
    SearchRecentSearchesCleared event,
    Emitter<SearchState> emit,
  ) => _clearRecentSearches();

  /// The repository updates the cache at once and rolls back on failure;
  /// the live results follow either way, so only a failure needs saying.
  Future<void> _onLikeToggled(
    SearchLikeToggled event,
    Emitter<SearchState> emit,
  ) async {
    final post = event.post;
    final result = await _likePost(post.id, liked: !post.isLiked);
    if (result is Err<void>) _show(likeFailedMessage, emit);
  }

  Future<void> _onBookmarkToggled(
    SearchBookmarkToggled event,
    Emitter<SearchState> emit,
  ) async {
    final post = event.post;
    final result = await _bookmarkPost(post.id, bookmarked: !post.isBookmarked);
    if (result is Err<void>) _show(bookmarkFailedMessage, emit);
  }

  void _show(String text, Emitter<SearchState> emit) {
    emit(
      state.copyWith(
        message: UiMessage(id: ++_messageCount, text: text),
      ),
    );
  }
}
