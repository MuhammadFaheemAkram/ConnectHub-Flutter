import 'package:connect_hub/di/injection.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../../helpers/app_harness.dart';

// Profiles and Edit Profile end to end, on the real stack.
void main() {
  tearDown(getIt.reset);

  Finder destination(String label) => find.descendant(
    of: find.byType(NavigationBar),
    matching: find.text(label),
  );

  int selectedTab(WidgetTester tester) =>
      tester.widget<NavigationBar>(find.byType(NavigationBar)).selectedIndex;

  Finder appBarTitled(String title) => find.widgetWithText(AppBar, title);

  testWidgets("someone else's profile shows their header and every post", (
    tester,
  ) async {
    await pumpConnectHub(tester, signedIn: true);

    await tester.tapAndSettle(find.text('Ada Lovelace').first);

    expect(find.text('Enchantress of numbers.'), findsOneWidget);
    expect(find.bySemanticsLabel('4.8K Followers'), findsOneWidget);
    expect(find.bySemanticsLabel('3 Posts'), findsOneWidget);
    expect(find.textContaining('analytical engine scheduler'), findsOneWidget);
    expect(find.text('Edit profile'), findsNothing);
  });

  testWidgets('my own name opens the Profile tab rather than a copy of it', (
    tester,
  ) async {
    // p16 is the demo user's.
    await pumpConnectHub(tester, signedIn: true, initialLocation: '/posts/p16');

    await tester.tapAndSettle(find.text('Demo User'));

    expect(selectedTab(tester), 4);
    expect(find.text('Edit profile'), findsOneWidget);
  });

  testWidgets('a link to my own id lands on the Profile tab', (tester) async {
    await pumpConnectHub(
      tester,
      signedIn: true,
      initialLocation: '/users/u_demo',
    );

    expect(selectedTab(tester), 4);
    expect(find.text('Edit profile'), findsOneWidget);
  });

  testWidgets('an unknown profile says so', (tester) async {
    await pumpConnectHub(
      tester,
      signedIn: true,
      initialLocation: '/users/u_nobody',
    );

    expect(find.text("This profile isn't available."), findsOneWidget);
  });

  testWidgets('a saved edit renames me on everything I wrote', (tester) async {
    await pumpConnectHub(tester, signedIn: true);
    await tester.tapAndSettle(destination('Profile'));
    expect(find.text('Demo User'), findsWidgets);

    await tester.tapAndSettle(find.text('Edit profile'));
    await tester.enterText(
      find.widgetWithText(TextField, 'Demo User'),
      'Demo Person',
    );
    await tester.pump();
    await tester.tapAndSettle(find.text('Save'));

    // Back on my profile: the header, and my posts (they JOIN my row).
    expect(appBarTitled('Profile'), findsOneWidget);
    expect(find.text('Demo User'), findsNothing);
    final myPost = find.ancestor(
      of: find.textContaining('Offline-first tip'),
      matching: find.byType(Card),
    );
    expect(
      find.descendant(of: myPost, matching: find.text('Demo Person')),
      findsOneWidget,
    );

    await tester.tapAndSettle(find.textContaining('Offline-first tip'));
    expect(appBarTitled('Post'), findsOneWidget);
    expect(find.text('Demo Person'), findsOneWidget);
  });

  testWidgets('leaving Edit profile with changes asks first', (tester) async {
    await pumpConnectHub(tester, signedIn: true);
    await tester.tapAndSettle(destination('Profile'));
    await tester.tapAndSettle(find.text('Edit profile'));

    await tester.enterText(
      find.widgetWithText(TextField, 'Demo User'),
      'Someone else',
    );
    await tester.pump();
    await tester.tapAndSettle(find.byType(CloseButton));
    expect(find.text('Discard changes?'), findsOneWidget);

    await tester.tapAndSettle(find.widgetWithText(FilledButton, 'Discard'));
    expect(appBarTitled('Profile'), findsOneWidget);
    expect(find.text('Someone else'), findsNothing);
  });
}
