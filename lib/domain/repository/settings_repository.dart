import 'package:connect_hub/domain/model/app_language.dart';
import 'package:connect_hub/domain/model/app_settings.dart';
import 'package:connect_hub/domain/model/app_theme_mode.dart';

/// The device's preferences (as in MovieExplorer, plus the badges switch).
///
/// It hides the storage (`shared_preferences`), so widgets never read
/// preferences directly and tests can swap in a fake.
abstract interface class SettingsRepository {
  /// The current settings, available synchronously. The app reads them before
  /// its first frame, so a saved dark theme never flashes light
  /// (Correctness Rule 13).
  AppSettings get currentSettings;

  /// Emits the current settings at once, then after every change.
  Stream<AppSettings> watchSettings();

  Future<void> updateThemeMode(AppThemeMode mode);

  Future<void> updateNotificationsEnabled({required bool enabled});

  Future<void> updateLanguage(AppLanguage language);
}
