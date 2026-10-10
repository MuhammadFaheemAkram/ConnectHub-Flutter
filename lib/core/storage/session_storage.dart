import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';

/// The fields of a saved session, as plain values. The domain `Session` is
/// mapped from this in the data layer, so `core/` doesn't depend on `domain/`.
typedef StoredSession = ({String token, String userId, String email});

/// Persists the session in the platform's secure store: the iOS Keychain, or
/// the Android Keystore through `flutter_secure_storage`.
///
/// A token is a credential, so it doesn't belong in `shared_preferences`
/// (plain files any backup or rooted device can read). Preferences such as
/// the theme go there instead (Phase 6).
@lazySingleton
class SessionStorage {
  const SessionStorage(this._secureStorage);

  final FlutterSecureStorage _secureStorage;

  static const _key = 'session';

  /// The saved session, or `null` if there is none or it can't be read.
  Future<StoredSession?> read() async {
    final raw = await _secureStorage.read(key: _key);
    if (raw == null) return null;
    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      return (
        token: json['token'] as String,
        userId: json['userId'] as String,
        email: json['email'] as String,
      );
    } on Object {
      // A corrupt entry (e.g. from an older app version) must not lock the
      // user out on every launch: drop it and start signed out.
      await delete();
      return null;
    }
  }

  Future<void> write(StoredSession session) => _secureStorage.write(
    key: _key,
    value: jsonEncode({
      'token': session.token,
      'userId': session.userId,
      'email': session.email,
    }),
  );

  Future<void> delete() => _secureStorage.delete(key: _key);
}
