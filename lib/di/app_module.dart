import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';

/// Registers types the app doesn't own, so they can be injected (and replaced
/// in tests) like everything else.
@module
abstract class AppModule {
  /// The asset bundle the fake server reads its seed JSON from.
  @lazySingleton
  AssetBundle get assetBundle => rootBundle;

  /// Keychain on iOS, Keystore-backed storage on Android.
  @lazySingleton
  FlutterSecureStorage get secureStorage => const FlutterSecureStorage();
}
