import 'package:connect_hub/app/connect_hub_app.dart';
import 'package:flutter_test/flutter_test.dart';

import 'pump_app.dart';
import 'test_dependencies.dart';

/// Starts the whole app on the real DI graph (see
/// [configureTestDependencies]): signed in as the demo user, or signed out,
/// optionally on a deep link. Pair it with `tearDown(getIt.reset)`.
Future<void> pumpConnectHub(
  WidgetTester tester, {
  bool signedIn = false,
  String? initialLocation,
}) async {
  await configureTestDependencies(
    secureStorage: signedIn ? storedDemoSession() : const {},
  );
  tester.usePhoneSurface();
  await tester.pumpWidget(ConnectHubApp(initialLocation: initialLocation));
  await tester.pumpAndSettle();
}

extension AppHarness on WidgetTester {
  Future<void> tapAndSettle(Finder finder) async {
    await tap(finder);
    await pumpAndSettle();
  }
}
