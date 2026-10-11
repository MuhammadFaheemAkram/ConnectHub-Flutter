import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Reads and writes the raw preference values. The keys live here and
/// nowhere else.
///
/// Preferences belong in `shared_preferences`: small, non-secret values the
/// device owns. The session token goes to secure storage instead, and the
/// server's data to drift.
///
/// It is backed by `SharedPreferencesWithCache`, created once before `runApp`
/// (`@preResolve` in `AppModule`): reads are synchronous afterwards, and
/// writes update the cache at once and the disk asynchronously.
@lazySingleton
class SettingsLocalDataSource {
  const SettingsLocalDataSource(this._preferences);

  static const themeModeKey = 'settings.themeMode';
  static const notificationsEnabledKey = 'settings.notificationsEnabled';
  static const languageKey = 'settings.language';

  /// The only keys the cache loads and allows writing.
  static const allowList = {themeModeKey, notificationsEnabledKey, languageKey};

  final SharedPreferencesWithCache _preferences;

  String? get themeMode => _preferences.getString(themeModeKey);

  bool? get notificationsEnabled =>
      _preferences.getBool(notificationsEnabledKey);

  String? get language => _preferences.getString(languageKey);

  Future<void> setThemeMode(String value) =>
      _preferences.setString(themeModeKey, value);

  Future<void> setNotificationsEnabled({required bool enabled}) =>
      _preferences.setBool(notificationsEnabledKey, enabled);

  Future<void> setLanguage(String value) =>
      _preferences.setString(languageKey, value);
}
