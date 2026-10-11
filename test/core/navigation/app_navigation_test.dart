import 'package:connect_hub/di/injection.dart';
import 'package:connect_hub/domain/repository/session_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../../helpers/app_harness.dart';

// End-to-end tests of the sign-in gate and navigation, on the real stack: the
// real DI graph, fake server, repositories and AuthBloc. Only the secure
// store (an in-memory mock) and the network latency (zero) are swapped.
void main() {
  tearDown(getIt.reset);

  Finder destination(String label) => find.descendant(
    of: find.byType(NavigationBar),
    matching: find.text(label),
  );

  Finder appBarTitled(String title) => find.widgetWithText(AppBar, title);

  final onLogin = find.text('Welcome to ConnectHub');
  final onFeed = appBarTitled('ConnectHub');

  // p1, the newest post in the seed, by Ada Lovelace.
  final firstPost = find.textContaining('analytical engine scheduler');
  final onPost = appBarTitled('Post');

  int selectedTab(WidgetTester tester) =>
      tester.widget<NavigationBar>(find.byType(NavigationBar)).selectedIndex;

  Future<void> signInWithDemoAccount(WidgetTester tester) async {
    await tester.tapAndSettle(find.text('Use demo account'));
    await tester.tapAndSettle(find.text('Sign in'));
  }

  group('Session', () {
    testWidgets('a launch without a saved session lands on Login', (
      tester,
    ) async {
      await pumpConnectHub(tester);

      expect(onLogin, findsOneWidget);
      expect(find.byType(NavigationBar), findsNothing);
    });

    testWidgets('a saved session is restored straight into the Feed', (
      tester,
    ) async {
      await pumpConnectHub(tester, signedIn: true);

      expect(onFeed, findsOneWidget);
      expect(selectedTab(tester), 0);
    });

    testWidgets('signing in with the demo account opens the Feed', (
      tester,
    ) async {
      await pumpConnectHub(tester);

      await signInWithDemoAccount(tester);

      expect(onFeed, findsOneWidget);
    });

    testWidgets('a wrong password keeps the user on Login, with the reason', (
      tester,
    ) async {
      await pumpConnectHub(tester);

      await tester.enterText(
        find.widgetWithText(TextField, 'Email'),
        'demo@connecthub.app',
      );
      await tester.enterText(
        find.widgetWithText(TextField, 'Password'),
        'not-the-password',
      );
      await tester.tapAndSettle(find.text('Sign in'));

      expect(find.text('Incorrect email or password.'), findsOneWidget);
      expect(onLogin, findsOneWidget);
    });

    testWidgets('creating an account signs it in', (tester) async {
      await pumpConnectHub(tester);
      await tester.tapAndSettle(find.text('Create an account'));

      Finder field(String label) => find.widgetWithText(TextField, label);
      await tester.enterText(field('Name'), 'Ada Lovelace');
      await tester.enterText(field('Email'), 'ada@example.com');
      await tester.enterText(field('Password'), 'engines');
      await tester.enterText(field('Confirm password'), 'engines');
      await tester.tapAndSettle(
        find.widgetWithText(FilledButton, 'Create account'),
      );

      expect(onFeed, findsOneWidget);
      await tester.tapAndSettle(destination('Profile'));
      expect(
        find.textContaining('Signed in as ada@example.com'),
        findsOneWidget,
      );
    });

    testWidgets('logging out asks first, then returns to Login', (
      tester,
    ) async {
      await pumpConnectHub(tester, signedIn: true);
      await tester.tapAndSettle(destination('Profile'));

      await tester.tapAndSettle(find.text('Log out'));
      expect(find.text('Log out?'), findsOneWidget);
      await tester.tapAndSettle(find.text('Cancel'));
      expect(appBarTitled('Profile'), findsOneWidget);

      await tester.tapAndSettle(find.text('Log out'));
      await tester.tapAndSettle(find.widgetWithText(FilledButton, 'Log out'));

      expect(onLogin, findsOneWidget);
      expect(find.byType(NavigationBar), findsNothing);
    });

    testWidgets('a deep link while signed out opens after signing in, and its '
        'back button then leads to the Feed', (tester) async {
      await pumpConnectHub(tester, initialLocation: '/posts/p3');
      expect(onLogin, findsOneWidget);

      await signInWithDemoAccount(tester);
      expect(onPost, findsOneWidget);
      expect(find.textContaining('teaching my test suite'), findsOneWidget);

      // Opened directly, the post has nothing underneath to go back to.
      await tester.tapAndSettle(find.byTooltip('Go to the feed'));
      expect(onFeed, findsOneWidget);
    });

    testWidgets('an expired session returns to Login with an explanation, and '
        'signing in again returns to where the user was', (tester) async {
      await pumpConnectHub(tester, signedIn: true);
      await tester.tapAndSettle(firstPost);
      expect(onPost, findsOneWidget);

      // What ApiGuard does when the server answers 401.
      await getIt<SessionRepository>().expire();
      await tester.pumpAndSettle();

      expect(
        find.text('Your session has expired. Please sign in again.'),
        findsOneWidget,
      );
      await signInWithDemoAccount(tester);
      expect(onPost, findsOneWidget);
      expect(firstPost, findsOneWidget);
    });

    testWidgets('Sign Up opens over Login, and Back returns to it', (
      tester,
    ) async {
      await pumpConnectHub(tester);

      await tester.tapAndSettle(find.text('Create an account'));
      expect(appBarTitled('Create account'), findsOneWidget);

      await tester.tapAndSettle(find.byType(BackButton));
      expect(onLogin, findsOneWidget);
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

      await tester.tapAndSettle(destination('Search'));
      expect(appBarTitled('Search'), findsOneWidget);
      await tester.tapAndSettle(destination('Bookmarks'));
      expect(appBarTitled('Bookmarks'), findsOneWidget);
      await tester.tapAndSettle(destination('Activity'));
      expect(appBarTitled('Activity'), findsOneWidget);
      await tester.tapAndSettle(destination('Profile'));
      expect(appBarTitled('Profile'), findsOneWidget);
      await tester.tapAndSettle(destination('Feed'));
      expect(onFeed, findsOneWidget);
    });
  });

  group('Screens above the shell', () {
    testWidgets('a post opened from the Feed covers the tab bar, and Back '
        'returns to the Feed', (tester) async {
      await pumpConnectHub(tester, signedIn: true);

      await tester.tapAndSettle(firstPost);
      expect(onPost, findsOneWidget);
      expect(find.byType(NavigationBar), findsNothing);

      await tester.tapAndSettle(find.byType(BackButton));
      expect(onFeed, findsOneWidget);
      expect(selectedTab(tester), 0);
    });

    testWidgets('comments open on top of their post', (tester) async {
      await pumpConnectHub(tester, signedIn: true);
      await tester.tapAndSettle(firstPost);

      await tester.scrollToAndTap(find.text('View all 3 comments'));
      expect(appBarTitled('Comments'), findsOneWidget);

      await tester.tapAndSettle(find.byType(BackButton));
      expect(onPost, findsOneWidget);
    });

    testWidgets('Chats opens from the Feed app bar, and a chat from Chats', (
      tester,
    ) async {
      await pumpConnectHub(tester, signedIn: true);

      await tester.tapAndSettle(find.byTooltip('Chats'));
      expect(appBarTitled('Chats'), findsOneWidget);
      await tester.tapAndSettle(find.text('Open a sample chat'));
      expect(appBarTitled('Chat'), findsOneWidget);

      await tester.tapAndSettle(find.byType(BackButton));
      await tester.tapAndSettle(find.byType(BackButton));
      expect(onFeed, findsOneWidget);
    });

    testWidgets('New post opens as a full-screen dialog with a close button', (
      tester,
    ) async {
      await pumpConnectHub(tester, signedIn: true);

      await tester.tapAndSettle(find.byTooltip('New post'));
      expect(appBarTitled('New post'), findsOneWidget);
      expect(find.byType(CloseButton), findsOneWidget);

      await tester.tapAndSettle(find.byType(CloseButton));
      expect(onFeed, findsOneWidget);
    });

    testWidgets('a full-screen dialog opened directly closes to the Feed', (
      tester,
    ) async {
      await pumpConnectHub(tester, signedIn: true, initialLocation: '/compose');
      expect(appBarTitled('New post'), findsOneWidget);

      await tester.tapAndSettle(find.byTooltip('Go to the feed'));
      expect(onFeed, findsOneWidget);
    });

    testWidgets('Settings and Edit profile open from the Profile tab, and '
        'closing them returns to that tab', (tester) async {
      await pumpConnectHub(tester, signedIn: true);
      await tester.tapAndSettle(destination('Profile'));

      await tester.tapAndSettle(find.byTooltip('Settings'));
      expect(appBarTitled('Settings'), findsOneWidget);
      await tester.tapAndSettle(find.byType(BackButton));
      expect(selectedTab(tester), 4);

      await tester.tapAndSettle(find.text('Edit profile'));
      expect(find.byType(CloseButton), findsOneWidget);
      await tester.tapAndSettle(find.byType(CloseButton));
      expect(appBarTitled('Profile'), findsOneWidget);
      expect(selectedTab(tester), 4);
    });

    testWidgets("someone else's profile opens above the shell", (tester) async {
      await pumpConnectHub(tester, signedIn: true);

      await tester.tapAndSettle(find.text('Ada Lovelace').first);

      expect(find.text('Profile "u_ada" arrives in Phase 5.'), findsOneWidget);
      expect(find.byType(NavigationBar), findsNothing);
    });
  });
}
