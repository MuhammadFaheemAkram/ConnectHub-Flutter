import 'package:connect_hub/core/navigation/placeholder_session.dart';
import 'package:connect_hub/di/injection.dart';

/// Registers the app's dependencies with test doubles, so app-level tests can
/// pump the real `ConnectHubApp`.
///
/// Call `getIt.reset()` in `tearDown` so every test starts clean.
PlaceholderSession registerTestDependencies({bool signedIn = false}) {
  final session = PlaceholderSession(signedIn: signedIn);
  getIt.registerSingleton<PlaceholderSession>(session);
  return session;
}
