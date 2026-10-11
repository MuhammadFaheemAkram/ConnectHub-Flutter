import 'dart:convert';

import 'package:connect_hub/core/common/demo_account.dart';
import 'package:connect_hub/core/database/app_database.dart';
import 'package:connect_hub/core/network/fake_server/network_simulator.dart';
import 'package:connect_hub/di/injection.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

import 'backend.dart';

/// Builds the app's real composition root for app-level tests, with these
/// swaps:
/// - the secure store is the plugin's in-memory mock, pre-filled with
///   [secureStorage];
/// - preferences live in an in-memory store, pre-filled with [preferences]
///   (raw keys, as `SettingsLocalDataSource` names them);
/// - the package info is a fixed mock (version 1.0.0, build 1);
/// - the database lives in memory (and is closed by `getIt.reset()`);
/// - the simulated network has no latency, so the in-memory fake server
///   answers at once. (Chat replies still take their 1.9 s: pump past them.)
///
/// Everything else is the real code, so these tests also prove the DI graph
/// resolves. Call `getIt.reset()` in `tearDown`.
Future<void> configureTestDependencies({
  Map<String, String> secureStorage = const {},
  Map<String, Object> preferences = const {},
}) async {
  FlutterSecureStorage.setMockInitialValues(Map.of(secureStorage));
  SharedPreferencesAsyncPlatform.instance =
      InMemorySharedPreferencesAsync.withData(Map.of(preferences));
  PackageInfo.setMockInitialValues(
    appName: 'ConnectHub',
    packageName: 'co.bitfuse.flutter.connect_hub',
    version: '1.0.0',
    buildNumber: '1',
    buildSignature: '',
  );
  await configureDependencies();
  getIt
    ..unregister<AppDatabase>()
    ..registerLazySingleton<AppDatabase>(
      newTestDatabase,
      dispose: (database) => database.close(),
    )
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
