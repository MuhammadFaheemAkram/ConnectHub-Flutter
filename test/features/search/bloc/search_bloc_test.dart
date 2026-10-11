import 'dart:async';

import 'package:connect_hub/core/common/app_exception.dart';
import 'package:connect_hub/core/common/result.dart';
import 'package:connect_hub/domain/model/search_results.dart';
import 'package:connect_hub/domain/model/search_scope.dart';
import 'package:connect_hub/domain/model/user.dart';
import 'package:connect_hub/domain/usecase/bookmark_post_use_case.dart';
import 'package:connect_hub/domain/usecase/clear_recent_searches_use_case.dart';
import 'package:connect_hub/domain/usecase/like_post_use_case.dart';
import 'package:connect_hub/domain/usecase/save_recent_search_use_case.dart';
import 'package:connect_hub/domain/usecase/search_use_case.dart';
import 'package:connect_hub/domain/usecase/watch_recent_searches_use_case.dart';
import 'package:connect_hub/domain/usecase/watch_search_results_use_case.dart';
import 'package:connect_hub/features/search/bloc/search_bloc.dart';
import 'package:connect_hub/features/search/bloc/search_event.dart';
import 'package:connect_hub/features/search/bloc/search_state.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fakes/fake_post_repository.dart';
import '../../../helpers/fakes/fake_search_repository.dart';
import '../../../helpers/fixtures.dart';

void main() {
  late FakeSearchRepository search;
  late FakePostRepository posts;

  const katherine = User(id: 'u_katherine', name: 'Katherine Johnson');
  final p1 = samplePost('p1');
  final p6 = samplePost('p6');
  final adaResults = SearchResults(users: const [ada], posts: [p1, p6]);

  // Real-time tests use a short debounce, and wait a few debounces for it
  // (as MovieExplorer does).
  const shortDebounce = Duration(milliseconds: 10);
  Future<void> settle() =>
      Future<void>.delayed(const Duration(milliseconds: 50));

  setUp(() {
    search = FakeSearchRepository()
      ..answers['ada'] = adaResults
      ..answers['moon'] = const SearchResults(users: [katherine]);
    posts = FakePostRepository();
  });

  tearDown(() async {
    await search.dispose();
    await posts.dispose();
  });

  SearchBloc buildBloc({Duration debounce = shortDebounce}) => SearchBloc(
    SearchUseCase(search),
    WatchSearchResultsUseCase(search),
    WatchRecentSearchesUseCase(search),
    SaveRecentSearchUseCase(search),
    ClearRecentSearchesUseCase(search),
    LikePostUseCase(posts),
    BookmarkPostUseCase(posts),
    debounce: debounce,
  );

  /// A fresh Bloc, closed when the test ends.
  SearchBloc started() {
    final bloc = buildBloc();
    addTearDown(bloc.close);
    return bloc;
  }

  /// Types [query] and lets the debounce run out.
  Future<void> type(SearchBloc bloc, String query) async {
    bloc.add(SearchQueryChanged(query));
    await settle();
  }

  group('debounce, in fake time (the real 300 ms)', () {
    // Only this test runs in fake time. The transformer is built on
    // `switchMap` (here and in `restartable()`), which awaits the cancel()
    // of the stream it switches away from. Without an async onCancel, Dart
    // returns one shared, already-completed root-zone future, and awaiting
    // it resumes on the real event loop, which a synchronous `fakeAsync`
    // body never reaches. Everything that switches is tested in real time
    // below, with a short debounce (conventions §11.29).
    test('a query waits out 300 ms, leaving the screen as it was, then '
        'runs', () {
      fakeAsync((time) {
        final bloc = buildBloc(debounce: const Duration(milliseconds: 300));
        final states = <SearchState>[];
        final subscription = bloc.stream.listen(states.add);

        bloc.add(const SearchQueryChanged('ada'));
        time.elapse(const Duration(milliseconds: 299));
        expect(search.searchCalls, isEmpty);
        expect(states, isEmpty);

        time.elapse(const Duration(milliseconds: 1));
        expect(search.searchCalls, ['ada']);
        expect(states.map((state) => state.status), [
          SearchStatus.loading,
          SearchStatus.success,
        ]);
        expect(bloc.state.results, adaResults);

        unawaited(subscription.cancel());
        unawaited(bloc.close());
        time.flushMicrotasks();
      });
    });
  });

  group('typing', () {
    test('only the last query typed within the debounce runs', () async {
      final bloc = started()
        ..add(const SearchQueryChanged('a'))
        ..add(const SearchQueryChanged('ad'))
        ..add(const SearchQueryChanged('ada '));
      await settle();

      expect(search.searchCalls, ['ada']);
      expect(bloc.state.query, 'ada');
      expect(bloc.state.results, adaResults);
    });

    test(
      'a blank query goes idle at once, and drops the pending search',
      () async {
        final bloc = started();
        await type(bloc, 'ada');

        bloc
          ..add(const SearchQueryChanged('moon'))
          ..add(const SearchQueryChanged('  '));
        await pumpEventQueue();
        expect(bloc.state.status, SearchStatus.idle);
        expect(bloc.state.results.isEmpty, isTrue);

        await settle();
        expect(search.searchCalls, ['ada']);

        // The old results stopped being live with them: a change to them
        // can't bring them back.
        search.replacePost(p1.copyWith(isLiked: true));
        await pumpEventQueue();
        expect(bloc.state.status, SearchStatus.idle);
      },
    );

    test('a newer query cancels the one in flight (restartable): its late '
        'answer never shows', () async {
      final bloc = started();
      search.gates['ad'] = Completer<void>();
      await type(bloc, 'ad');
      expect(bloc.state.status, SearchStatus.loading);

      await type(bloc, 'ada');
      search.gates['ad']!.complete();
      await settle();

      expect(search.searchCalls, ['ad', 'ada']);
      expect(bloc.state.query, 'ada');
      expect(bloc.state.results, adaResults);
    });

    test('the query on screen coming back needs no new request, and stays '
        'live', () async {
      final bloc = started();
      await type(bloc, 'ada');

      bloc
        ..add(const SearchQueryChanged('ad'))
        ..add(const SearchQueryChanged('ada'));
      await settle();
      expect(search.searchCalls, ['ada']);

      search.replacePost(p1.copyWith(isLiked: true, likeCount: 11));
      await pumpEventQueue();
      expect(bloc.state.results.posts.first.isLiked, isTrue);
    });
  });

  group('results', () {
    test('are live: a like made on another screen updates them', () async {
      final bloc = started();
      await type(bloc, 'ada');

      search.replacePost(p6.copyWith(isLiked: true, likeCount: 11));
      await pumpEventQueue();

      final liked = bloc.state.results.posts.last;
      expect(liked.isLiked, isTrue);
      expect(liked.likeCount, 11);
    });

    test('a scope filters what is shown, without a new request', () async {
      final bloc = started();
      await type(bloc, 'ada');

      bloc.add(const SearchScopeChanged(SearchScope.people));
      await pumpEventQueue();
      expect(bloc.state.people, [ada]);
      expect(bloc.state.posts, isEmpty);

      bloc.add(const SearchScopeChanged(SearchScope.posts));
      await pumpEventQueue();
      expect(bloc.state.people, isEmpty);
      expect(bloc.state.posts, [p1, p6]);
      expect(search.searchCalls, ['ada']);
    });

    test('nothing in the chosen scope counts as no matches', () async {
      final bloc = started();
      await type(bloc, 'moon');
      expect(bloc.state.hasNoMatches, isFalse);

      bloc.add(const SearchScopeChanged(SearchScope.posts));
      await pumpEventQueue();
      expect(bloc.state.hasNoMatches, isTrue);
    });

    test('a failure shows the error, and Try again runs the query '
        'again', () async {
      final bloc = started();
      search.failure = const Err(NetworkException());
      await type(bloc, 'ada');
      expect(bloc.state.status, SearchStatus.failure);
      expect(bloc.state.errorMessage, const NetworkException().message);

      search.failure = null;
      bloc.add(const SearchRetried());
      await pumpEventQueue();

      expect(search.searchCalls, ['ada', 'ada']);
      expect(bloc.state.status, SearchStatus.success);
      expect(bloc.state.results, adaResults);
    });

    test('a like that fails says so (the repository has rolled it '
        'back)', () async {
      final bloc = started();
      posts.likeResult = const Err(NetworkException());
      await type(bloc, 'ada');

      bloc.add(SearchLikeToggled(p1));
      await pumpEventQueue();

      expect(posts.likeCalls, [(postId: 'p1', liked: true)]);
      expect(bloc.state.message?.text, SearchBloc.likeFailedMessage);
    });
  });

  group('recent searches (Correctness Rule 11)', () {
    test('typing never saves one', () async {
      final bloc = started();
      await type(bloc, 'a');
      await type(bloc, 'ada');

      expect(search.saved, isEmpty);
    });

    test('a submit saves the trimmed query and runs it at once', () async {
      final bloc = started()..add(const SearchSubmitted('  ada '));
      await pumpEventQueue();

      expect(search.saved, ['ada']);
      expect(search.searchCalls, ['ada']);
      expect(bloc.state.status, SearchStatus.success);
    });

    test('opening a result saves the query that found it', () async {
      final bloc = started();
      await type(bloc, 'ada');

      bloc.add(const SearchResultOpened());
      await pumpEventQueue();

      expect(search.saved, ['ada']);
    });

    test('the idle screen lists them, newest first, and Clear removes '
        'them', () async {
      search = FakeSearchRepository(recentSearches: ['grace', 'ada']);
      final bloc = started()..add(const SearchSubscriptionRequested());
      await pumpEventQueue();
      expect(bloc.state.status, SearchStatus.idle);
      expect(bloc.state.recentSearches, ['grace', 'ada']);

      bloc.add(const SearchRecentSearchesCleared());
      await pumpEventQueue();
      expect(search.clearCalls, 1);
      expect(bloc.state.recentSearches, isEmpty);
    });
  });
}
