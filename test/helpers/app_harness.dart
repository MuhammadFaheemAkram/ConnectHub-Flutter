import 'package:connect_hub/app/connect_hub_app.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'pump_app.dart';
import 'test_dependencies.dart';

/// Starts the whole app on the real DI graph (see
/// [configureTestDependencies]): signed in as the demo user, or signed out,
/// optionally on a deep link, with saved [preferences]. [beforeLaunch] runs once the graph exists and
/// before the first frame, e.g. to fill the cache as a previous launch
/// would have. Pair it with `tearDown(getIt.reset)`.
Future<void> pumpConnectHub(
  WidgetTester tester, {
  bool signedIn = false,
  String? initialLocation,
  Map<String, Object> preferences = const {},
  Future<void> Function()? beforeLaunch,
}) async {
  await configureTestDependencies(
    secureStorage: signedIn ? storedDemoSession() : const {},
    preferences: preferences,
  );
  await beforeLaunch?.call();
  tester.usePhoneSurface();
  await tester.pumpWidget(ConnectHubApp(initialLocation: initialLocation));
  await tester.pumpAndSettle();
}

/// The bottom bar's destination labelled [label] (a tab).
Finder destination(String label) =>
    find.descendant(of: find.byType(NavigationBar), matching: find.text(label));

/// The app bar showing [title]: which screen is on top.
Finder appBarTitled(String title) => find.widgetWithText(AppBar, title);

extension AppHarness on WidgetTester {
  /// The index of the selected tab.
  int get selectedTab =>
      widget<NavigationBar>(find.byType(NavigationBar)).selectedIndex;

  Future<void> tapAndSettle(Finder finder) async {
    await tap(finder);
    await pumpAndSettle();
  }

  /// Scrolls [finder] into view first, for widgets below the fold.
  Future<void> scrollToAndTap(Finder finder) async {
    await ensureVisible(finder);
    await pumpAndSettle();
    await tapAndSettle(finder);
  }
}
