import 'dart:convert';

import 'package:connect_hub/core/common/demo_account.dart';
import 'package:connect_hub/core/network/fake_server/network_simulator.dart';
import 'package:connect_hub/di/injection.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Builds the app's real composition root for app-level tests, with two
/// swaps:
/// - the secure store is the plugin's in-memory mock, pre-filled with
///   [secureStorage];
/// - the simulated network has no latency, so the in-memory fake server
///   answers at once.
///
/// Everything else is the real code, so these tests also prove the DI graph
/// resolves. Call `getIt.reset()` in `tearDown`.
Future<void> configureTestDependencies({
  Map<String, String> secureStorage = const {},
}) async {
  FlutterSecureStorage.setMockInitialValues(Map.of(secureStorage));
  await configureDependencies();
  getIt
    ..unregister<NetworkSimulator>()
    ..registerLazySingleton<NetworkSimulator>(
      () => NetworkSimulator(latencyFactor: 0),
    );
}

/// A saved demo session, in the secure store's format: the app starts
/// signed in.
Map<String, String> storedDemoSession() => {
  'session': jsonEncode({
    'token': 'fake.u_demo.0123456789abcdef',
    'userId': 'u_demo',
    'email': DemoAccount.email,
  }),
};
