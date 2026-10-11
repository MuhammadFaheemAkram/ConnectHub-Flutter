import 'package:connect_hub/di/injection.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../../helpers/app_harness.dart';

// Search end to end, on the real stack: fake server, API services, drift (in
// memory) and repositories, with the real 300 ms debounce in fake time.
void main() {
  tearDown(getIt.reset);

  Finder destination(String label) => find.descendant(
    of: find.byType(NavigationBar),
    matching: find.text(label),
  );

  final searchField = find.byType(TextField);
  final adaRow = find.widgetWithText(ListTile, 'Ada Lovelace');

  /// Types [query] and waits out the debounce and the search.
  Future<void> typeQuery(WidgetTester tester, String query) async {
    await tester.enterText(searchField, query);
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpAndSettle();
  }

  Future<void> openSearch(WidgetTester tester) async {
    await pumpConnectHub(tester, signedIn: true);
    await tester.tapAndSettle(destination('Search'));
  }

  testWidgets('finds people and posts; opening a person shows their profile, '
      'and the query becomes a recent search', (tester) async {
    await openSearch(tester);
    expect(find.text('Search ConnectHub'), findsOneWidget);

    await typeQuery(tester, 'ada');
    expect(adaRow, findsOneWidget);
    expect(find.textContaining('analytical engine scheduler'), findsOneWidget);

    await tester.tapAndSettle(adaRow);
    expect(find.text('Enchantress of numbers.'), findsOneWidget);
    await tester.tapAndSettle(find.byType(BackButton));

    await tester.tapAndSettle(find.byTooltip('Clear search'));
    expect(find.text('Recent searches'), findsOneWidget);
    expect(find.widgetWithText(ListTile, 'ada'), findsOneWidget);
  });

  testWidgets('typing alone saves no recent search', (tester) async {
    await openSearch(tester);

    await typeQuery(tester, 'ada');
    await typeQuery(tester, '');

    expect(find.text('Search ConnectHub'), findsOneWidget);
  });

  testWidgets('a like in the results is the same like everywhere', (
    tester,
  ) async {
    await openSearch(tester);
    await typeQuery(tester, 'scheduler');

    await tester.tapAndSettle(find.byTooltip('Like'));
    expect(find.byTooltip('Unlike'), findsOneWidget);

    await tester.tapAndSettle(destination('Feed'));
    final firstCard = find.ancestor(
      of: find.textContaining('analytical engine scheduler'),
      matching: find.byType(Card),
    );
    expect(
      find.descendant(of: firstCard, matching: find.byTooltip('Unlike')),
      findsOneWidget,
    );
  });

  testWidgets('the People chip shows only people', (tester) async {
    await openSearch(tester);
    await typeQuery(tester, 'ada');

    await tester.tapAndSettle(find.widgetWithText(ChoiceChip, 'People'));

    expect(adaRow, findsOneWidget);
    expect(find.byType(Card), findsNothing);
  });

  testWidgets("logging out deletes the recent searches: they're the user's", (
    tester,
  ) async {
    await openSearch(tester);
    await tester.enterText(searchField, 'ada');
    await tester.testTextInput.receiveAction(TextInputAction.search);
    await tester.pumpAndSettle();

    await tester.tapAndSettle(destination('Profile'));
    await tester.tapAndSettle(find.text('Log out'));
    await tester.tapAndSettle(find.widgetWithText(FilledButton, 'Log out'));
    await tester.tapAndSettle(find.text('Use demo account'));
    await tester.tapAndSettle(find.text('Sign in'));

    await tester.tapAndSettle(destination('Search'));
    expect(find.text('Search ConnectHub'), findsOneWidget);
    expect(find.text('Recent searches'), findsNothing);
  });
}
