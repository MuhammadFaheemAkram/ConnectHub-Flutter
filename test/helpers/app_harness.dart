import 'package:connect_hub/app/connect_hub_app.dart';
import 'package:flutter_test/flutter_test.dart';

import 'pump_app.dart';
import 'test_dependencies.dart';

/// Starts the whole app on the real DI graph (see
/// [configureTestDependencies]): signed in as the demo user, or signed out,
/// optionally on a deep link. [beforeLaunch] runs once the graph exists and
/// before the first frame, e.g. to fill the cache as a previous launch
/// would have. Pair it with `tearDown(getIt.reset)`.
Future<void> pumpConnectHub(
  WidgetTester tester, {
  bool signedIn = false,
  String? initialLocation,
  Future<void> Function()? beforeLaunch,
}) async {
  await configureTestDependencies(
    secureStorage: signedIn ? storedDemoSession() : const {},
  );
  await beforeLaunch?.call();
  tester.usePhoneSurface();
  await tester.pumpWidget(ConnectHubApp(initialLocation: initialLocation));
  await tester.pumpAndSettle();
}

extension AppHarness on WidgetTester {
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
