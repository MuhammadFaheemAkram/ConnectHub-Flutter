import 'package:bloc_test/bloc_test.dart';
import 'package:connect_hub/core/design_system/design_system.dart';
import 'package:connect_hub/domain/model/search_results.dart';
import 'package:connect_hub/domain/model/search_scope.dart';
import 'package:connect_hub/features/search/bloc/search_bloc.dart';
import 'package:connect_hub/features/search/bloc/search_event.dart';
import 'package:connect_hub/features/search/bloc/search_state.dart';
import 'package:connect_hub/features/search/search_view.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/fixtures.dart';
import '../../helpers/pump_app.dart';

class _MockSearchBloc extends MockBloc<SearchEvent, SearchState>
    implements SearchBloc {}

void main() {
  late _MockSearchBloc bloc;
  late List<String> openedPosts;
  late List<String> openedProfiles;

  final p1 = samplePost('p1');
  final results = SearchResults(users: const [ada], posts: [p1]);

  setUpAll(() => registerFallbackValue(const SearchRetried()));

  setUp(() {
    bloc = _MockSearchBloc();
    openedPosts = [];
    openedProfiles = [];
  });

  Future<void> pumpView(WidgetTester tester, SearchState state) async {
    when(() => bloc.state).thenReturn(state);
    tester.usePhoneSurface();
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: BlocProvider<SearchBloc>.value(
          value: bloc,
          child: SearchView(
            onOpenPost: openedPosts.add,
            onOpenComments: openedPosts.add,
            onOpenProfile: openedProfiles.add,
          ),
        ),
      ),
    );
  }

  /// Every event the view has sent, in order.
  List<SearchEvent> sent() =>
      verify(() => bloc.add(captureAny())).captured.cast<SearchEvent>();

  SearchState found(SearchResults results, {String query = 'ada'}) =>
      SearchState(status: SearchStatus.success, query: query, results: results);

  testWidgets('nothing typed and no recent searches: the prompt', (
    tester,
  ) async {
    await pumpView(tester, const SearchState());

    expect(find.text('Search ConnectHub'), findsOneWidget);
    expect(
      find.text('Find people and posts by name or keyword.'),
      findsOneWidget,
    );
  });

  testWidgets('recent searches: a tap searches again; Clear clears them', (
    tester,
  ) async {
    await pumpView(tester, const SearchState(recentSearches: ['grace', 'ada']));
    expect(find.text('Recent searches'), findsOneWidget);

    await tester.tap(find.text('ada'));
    await tester.tap(find.text('Clear'));

    final events = sent();
    expect(events.whereType<SearchSubmitted>().single.query, 'ada');
    expect(events.last, isA<SearchRecentSearchesCleared>());
    // The tapped search is written into the field.
    expect(find.widgetWithText(AppSearchField, 'ada'), findsOneWidget);
  });

  testWidgets("typing sends every change; the keyboard's search button "
      'submits', (tester) async {
    await pumpView(tester, const SearchState());

    await tester.enterText(find.byType(TextField), 'ada');
    await tester.testTextInput.receiveAction(TextInputAction.search);

    final events = sent();
    expect(events.whereType<SearchQueryChanged>().single.query, 'ada');
    expect(events.whereType<SearchSubmitted>().single.query, 'ada');
  });

  testWidgets('results list people, then posts; opening one remembers the '
      'query first', (tester) async {
    await pumpView(tester, found(results));

    expect(find.text('People'), findsWidgets);
    expect(find.text('Posts'), findsWidgets);
    await tester.tap(find.widgetWithText(ListTile, 'Ada Lovelace'));
    await tester.tap(find.text('Post p1'));

    expect(sent().whereType<SearchResultOpened>(), hasLength(2));
    expect(openedProfiles, ['u_ada']);
    expect(openedPosts, ['p1']);
  });

  testWidgets('like and bookmark in the results go to the Bloc', (
    tester,
  ) async {
    await pumpView(tester, found(results));

    await tester.tap(find.byTooltip('Like'));
    await tester.tap(find.byTooltip('Bookmark'));

    final events = sent();
    expect(events.whereType<SearchLikeToggled>().single.post, p1);
    expect(events.whereType<SearchBookmarkToggled>().single.post, p1);
  });

  // One state per test: a BlocBuilder reads a mocked Bloc's state once,
  // then follows its stream, so pumping a second state would show nothing.

  testWidgets('no matches says so', (tester) async {
    await pumpView(tester, found(const SearchResults(), query: 'zzz'));

    expect(find.text('No results'), findsOneWidget);
    expect(find.text('No people or posts match “zzz”.'), findsOneWidget);
  });

  testWidgets('nothing in the chosen scope says so in its words', (
    tester,
  ) async {
    await pumpView(
      tester,
      found(
        SearchResults(posts: [p1]),
        query: 'zzz',
      ).copyWith(scope: SearchScope.people),
    );

    expect(find.text('No people match “zzz”.'), findsOneWidget);
  });

  testWidgets('a failure offers Try again', (tester) async {
    await pumpView(
      tester,
      const SearchState(
        status: SearchStatus.failure,
        query: 'ada',
        errorMessage: 'No connection.',
      ),
    );

    await tester.tap(find.text('Try again'));

    expect(sent().single, isA<SearchRetried>());
  });

  testWidgets('the chips choose the scope', (tester) async {
    await pumpView(tester, found(results));

    await tester.tap(find.widgetWithText(ChoiceChip, 'People'));

    expect(
      sent().whereType<SearchScopeChanged>().single.scope,
      SearchScope.people,
    );
  });

  testWidgets('a new search keeps the old results, under a progress bar', (
    tester,
  ) async {
    await pumpView(
      tester,
      found(results).copyWith(status: SearchStatus.loading),
    );

    expect(find.byType(LinearProgressIndicator), findsOneWidget);
    expect(find.widgetWithText(ListTile, 'Ada Lovelace'), findsOneWidget);
  });

  testWidgets('a first search shows a spinner', (tester) async {
    await pumpView(
      tester,
      const SearchState(status: SearchStatus.loading, query: 'ada'),
    );

    expect(find.text('Searching…'), findsOneWidget);
  });
}
