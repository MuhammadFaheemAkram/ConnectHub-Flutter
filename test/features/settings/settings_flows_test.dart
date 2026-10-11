import 'package:connect_hub/app/connect_hub_app.dart';
import 'package:connect_hub/core/storage/settings_local_data_source.dart';
import 'package:connect_hub/di/injection.dart';
import 'package:connect_hub/features/settings/cubit/settings_tools_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../../helpers/app_harness.dart';
import '../../helpers/pump_app.dart';
import '../../helpers/test_dependencies.dart';

// Settings end to end, on the real stack.
void main() {
  tearDown(getIt.reset);

  Finder destination(String label) => find.descendant(
    of: find.byType(NavigationBar),
    matching: find.text(label),
  );

  ThemeMode themeMode(WidgetTester tester) =>
      tester.widget<MaterialApp>(find.byType(MaterialApp)).themeMode!;

  Future<void> openSettings(WidgetTester tester) async {
    await tester.tapAndSettle(destination('Profile'));
    await tester.tapAndSettle(find.byTooltip('Settings'));
  }

  Future<void> scrollTo(WidgetTester tester, String text) async {
    await tester.scrollUntilVisible(
      find.text(text),
      200,
      scrollable: find
          .descendant(
            of: find.byType(ListView),
            matching: find.byType(Scrollable),
          )
          .first,
    );
    await tester.pumpAndSettle();
  }

  testWidgets('Dark applies app-wide, at once', (tester) async {
    await pumpConnectHub(tester, signedIn: true);
    await openSettings(tester);

    await tester.tapAndSettle(find.text('Dark'));
    expect(themeMode(tester), ThemeMode.dark);

    await tester.tapAndSettle(find.byType(BackButton));
    final onProfile = tester.element(find.text('Edit profile'));
    expect(Theme.of(onProfile).brightness, Brightness.dark);
  });

  testWidgets('a saved theme applies on the very first frame (Correctness '
      'Rule 13)', (tester) async {
    await configureTestDependencies(
      secureStorage: storedDemoSession(),
      preferences: {SettingsLocalDataSource.themeModeKey: 'dark'},
    );
    tester.usePhoneSurface();

    await tester.pumpWidget(const ConnectHubApp());

    expect(themeMode(tester), ThemeMode.dark);
    await tester.pumpAndSettle();
  });

  testWidgets('turning the badges off hides them, on the tab and on Chats', (
    tester,
  ) async {
    await pumpConnectHub(tester, signedIn: true);
    await openSettings(tester);

    await tester.tapAndSettle(find.text('Show unread badges'));
    await tester.tapAndSettle(find.byType(BackButton));

    // The Activity tab had 3 unread.
    expect(
      find.descendant(of: find.byType(NavigationBar), matching: find.text('3')),
      findsNothing,
    );
    await tester.tapAndSettle(destination('Feed'));
    expect(
      find.descendant(of: find.byTooltip('Chats'), matching: find.text('3')),
      findsNothing,
    );
  });

  testWidgets('Clear cache: confirmed, cleared, and the feed comes back', (
    tester,
  ) async {
    await pumpConnectHub(tester, signedIn: true);
    await openSettings(tester);
    await scrollTo(tester, 'Clear cache');

    await tester.tapAndSettle(find.text('Clear cache'));
    await tester.tapAndSettle(find.widgetWithText(FilledButton, 'Clear'));

    expect(find.text(SettingsToolsCubit.cacheClearedMessage), findsOneWidget);
    await tester.tapAndSettle(find.byType(BackButton));
    await tester.tapAndSettle(destination('Feed'));
    expect(find.textContaining('analytical engine scheduler'), findsOneWidget);
  });

  testWidgets('Expire session: the next request returns to Login, with the '
      'expiry message', (tester) async {
    await pumpConnectHub(tester, signedIn: true);
    await openSettings(tester);
    await scrollTo(tester, 'Expire session');

    await tester.tapAndSettle(find.text('Expire session'));
    expect(find.text(SettingsToolsCubit.sessionExpiredMessage), findsOneWidget);

    // The next request: Chats loads its conversations.
    await tester.tapAndSettle(find.byType(BackButton));
    await tester.tapAndSettle(destination('Feed'));
    await tester.tapAndSettle(find.byTooltip('Chats'));

    expect(find.text('Sign in'), findsWidgets);
    expect(
      find.text('Your session has expired. Please sign in again.'),
      findsOneWidget,
    );
  });

  testWidgets('Simulate network failure: requests fail until it is off', (
    tester,
  ) async {
    await pumpConnectHub(tester, signedIn: true);
    await openSettings(tester);
    await scrollTo(tester, 'Simulate network failure');

    await tester.tapAndSettle(find.text('Simulate network failure'));
    await tester.tapAndSettle(find.byType(BackButton));
    await tester.tapAndSettle(destination('Feed'));
    await tester.tapAndSettle(find.byTooltip('Chats'));

    // The conversations are cached already: they stay, and a SnackBar says
    // the refresh failed.
    expect(find.text('Grace Hopper'), findsOneWidget);
    expect(find.text("Couldn't refresh. Showing saved chats."), findsOneWidget);
  });
}
