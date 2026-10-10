import 'package:connect_hub/app/connect_hub_app.dart';
import 'package:connect_hub/core/navigation/placeholder_session.dart';
import 'package:connect_hub/di/injection.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../../helpers/pump_app.dart';
import '../../helpers/test_dependencies.dart';

void main() {
  late PlaceholderSession session;

  tearDown(getIt.reset);

  Future<void> pumpConnectHub(
    WidgetTester tester, {
    bool signedIn = false,
    String? initialLocation,
  }) async {
    session = registerTestDependencies(signedIn: signedIn);
    tester.usePhoneSurface();
    await tester.pumpWidget(ConnectHubApp(initialLocation: initialLocation));
    await tester.pumpAndSettle();
  }

  // Scoped to the NavigationBar: "Search" is also the Search screen's title.
  Finder destination(String label) => find.descendant(
    of: find.byType(NavigationBar),
    matching: find.text(label),
  );

  Future<void> tapAndSettle(WidgetTester tester, Finder finder) async {
    await tester.tap(finder);
    await tester.pumpAndSettle();
  }

  Finder appBarTitled(String title) => find.widgetWithText(AppBar, title);

  int selectedTab(WidgetTester tester) =>
      tester.widget<NavigationBar>(find.byType(NavigationBar)).selectedIndex;

  group('Sign-in gate', () {
    testWidgets('a signed-out launch lands on Login, without the tab bar', (
      tester,
    ) async {
      await pumpConnectHub(tester);

      expect(find.text('Welcome to ConnectHub'), findsOneWidget);
      expect(find.byType(NavigationBar), findsNothing);
    });

    testWidgets('signing in moves to the Feed with no navigation code', (
      tester,
    ) async {
      await pumpConnectHub(tester);

      await tapAndSettle(tester, find.text('Continue'));

      expect(session.isSignedIn, isTrue);
      expect(appBarTitled('ConnectHub'), findsOneWidget);
      expect(selectedTab(tester), 0);
    });

    testWidgets('logging out from the Profile tab returns to Login', (
      tester,
    ) async {
      await pumpConnectHub(tester, signedIn: true);
      await tapAndSettle(tester, destination('Profile'));

      await tapAndSettle(tester, find.text('Log out'));

      expect(find.text('Welcome to ConnectHub'), findsOneWidget);
      expect(find.byType(NavigationBar), findsNothing);
    });

    testWidgets('a deep link while signed out lands on Login', (tester) async {
      await pumpConnectHub(tester, initialLocation: '/posts/p1');

      expect(find.text('Welcome to ConnectHub'), findsOneWidget);
      expect(find.text('Post "p1"'), findsNothing);
    });

    testWidgets('while signed in, Login is unreachable', (tester) async {
      await pumpConnectHub(tester, signedIn: true, initialLocation: '/login');

      expect(appBarTitled('ConnectHub'), findsOneWidget);
    });

    testWidgets('Sign Up opens over Login, and Back returns to it', (
      tester,
    ) async {
      await pumpConnectHub(tester);

      await tapAndSettle(tester, find.text('Create an account'));
      expect(appBarTitled('Create account'), findsOneWidget);

      await tapAndSettle(tester, find.byType(BackButton));
      expect(find.text('Welcome to ConnectHub'), findsOneWidget);
    });
  });

  group('Tab shell', () {
    testWidgets('has five destinations, each with its own screen', (
      tester,
    ) async {
      await pumpConnectHub(tester, signedIn: true);

      expect(
        tester.widget<NavigationBar>(find.byType(NavigationBar)).destinations,
        hasLength(5),
      );

      await tapAndSettle(tester, destination('Search'));
      expect(appBarTitled('Search'), findsOneWidget);
      await tapAndSettle(tester, destination('Bookmarks'));
      expect(appBarTitled('Bookmarks'), findsOneWidget);
      await tapAndSettle(tester, destination('Activity'));
      expect(appBarTitled('Activity'), findsOneWidget);
      await tapAndSettle(tester, destination('Profile'));
      expect(appBarTitled('Profile'), findsOneWidget);
      await tapAndSettle(tester, destination('Feed'));
      expect(appBarTitled('ConnectHub'), findsOneWidget);
    });
  });

  group('Screens above the shell', () {
    testWidgets('a post opened from the Feed covers the tab bar, and Back '
        'returns to the Feed', (tester) async {
      await pumpConnectHub(tester, signedIn: true);

      await tapAndSettle(tester, find.text('Open a sample post'));
      expect(find.text('Post "p1"'), findsOneWidget);
      // Root-level routes sit above the shell, so the tab bar is hidden.
      expect(find.byType(NavigationBar), findsNothing);

      await tapAndSettle(tester, find.byType(BackButton));
      expect(appBarTitled('ConnectHub'), findsOneWidget);
      expect(selectedTab(tester), 0);
    });

    testWidgets('comments open on top of their post', (tester) async {
      await pumpConnectHub(tester, signedIn: true);
      await tapAndSettle(tester, find.text('Open a sample post'));

      await tapAndSettle(tester, find.text('View comments'));
      expect(appBarTitled('Comments'), findsOneWidget);

      await tapAndSettle(tester, find.byType(BackButton));
      expect(find.text('Post "p1"'), findsOneWidget);
    });

    testWidgets('Chats opens from the Feed app bar, and a chat from Chats', (
      tester,
    ) async {
      await pumpConnectHub(tester, signedIn: true);

      await tapAndSettle(tester, find.byTooltip('Chats'));
      expect(appBarTitled('Chats'), findsOneWidget);
      await tapAndSettle(tester, find.text('Open a sample chat'));
      expect(appBarTitled('Chat'), findsOneWidget);

      await tapAndSettle(tester, find.byType(BackButton));
      await tapAndSettle(tester, find.byType(BackButton));
      expect(appBarTitled('ConnectHub'), findsOneWidget);
    });

    testWidgets('New post opens as a full-screen dialog with a close button', (
      tester,
    ) async {
      await pumpConnectHub(tester, signedIn: true);

      await tapAndSettle(tester, find.byTooltip('New post'));
      expect(appBarTitled('New post'), findsOneWidget);
      expect(find.byType(CloseButton), findsOneWidget);

      await tapAndSettle(tester, find.byType(CloseButton));
      expect(appBarTitled('ConnectHub'), findsOneWidget);
    });

    testWidgets('Settings and Edit profile open from the Profile tab, and '
        'closing them returns to that tab', (tester) async {
      await pumpConnectHub(tester, signedIn: true);
      await tapAndSettle(tester, destination('Profile'));

      await tapAndSettle(tester, find.byTooltip('Settings'));
      expect(appBarTitled('Settings'), findsOneWidget);
      await tapAndSettle(tester, find.byType(BackButton));
      expect(selectedTab(tester), 4);

      await tapAndSettle(tester, find.text('Edit profile'));
      expect(find.byType(CloseButton), findsOneWidget);
      await tapAndSettle(tester, find.byType(CloseButton));
      expect(appBarTitled('Profile'), findsOneWidget);
      expect(selectedTab(tester), 4);
    });

    testWidgets('someone else\'s profile opens above the shell', (
      tester,
    ) async {
      await pumpConnectHub(tester, signedIn: true);

      await tapAndSettle(tester, find.text('Open a sample profile'));

      expect(find.text('Profile "u_ada" arrives in Phase 5.'), findsOneWidget);
      expect(find.byType(NavigationBar), findsNothing);
    });
  });
}
