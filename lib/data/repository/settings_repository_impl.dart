import 'dart:async';

import 'package:connect_hub/core/storage/settings_local_data_source.dart';
import 'package:connect_hub/domain/model/app_language.dart';
import 'package:connect_hub/domain/model/app_settings.dart';
import 'package:connect_hub/domain/model/app_theme_mode.dart';
import 'package:connect_hub/domain/repository/settings_repository.dart';
import 'package:injectable/injectable.dart';

/// The default [SettingsRepository] (MovieExplorer's, plus the badges
/// switch).
///
/// It keeps the current [AppSettings] in memory, publishes every change to
/// its watchers at once, and persists through [SettingsLocalDataSource].
/// Stored values are enum names; unknown or missing values fall back to the
/// defaults.
@LazySingleton(as: SettingsRepository)
class SettingsRepositoryImpl implements SettingsRepository {
  SettingsRepositoryImpl(this._local) : _current = _read(_local);

  final SettingsLocalDataSource _local;
  final _changes = StreamController<AppSettings>.broadcast(sync: true);
  AppSettings _current;

  @override
  AppSettings get currentSettings => _current;

  @override
  Stream<AppSettings> watchSettings() {
    // The current value on listen, then every change. Subscribing to the
    // changes in the same step leaves no gap for an update to slip through.
    return Stream.multi((watcher) {
      final subscription = _changes.stream.listen(watcher.add);
      watcher
        ..onCancel = subscription.cancel
        ..add(_current);
    });
  }

  @override
  Future<void> updateThemeMode(AppThemeMode mode) {
    _publish(_current.copyWith(themeMode: mode));
    return _local.setThemeMode(mode.name);
  }

  @override
  Future<void> updateNotificationsEnabled({required bool enabled}) {
    _publish(_current.copyWith(notificationsEnabled: enabled));
    return _local.setNotificationsEnabled(enabled: enabled);
  }

  @override
  Future<void> updateLanguage(AppLanguage language) {
    _publish(_current.copyWith(language: language));
    return _local.setLanguage(language.name);
  }

  /// Closes the change stream (for tests: the app keeps one repository for
  /// its whole lifetime).
  Future<void> dispose() => _changes.close();

  void _publish(AppSettings settings) {
    if (settings == _current) return;
    _current = settings;
    _changes.add(settings);
  }

  static AppSettings _read(SettingsLocalDataSource local) => AppSettings(
    themeMode:
        AppThemeMode.values.asNameMap()[local.themeMode] ?? AppThemeMode.system,
    notificationsEnabled: local.notificationsEnabled ?? true,
    language: AppLanguage.values.asNameMap()[local.language] ?? AppLanguage.en,
  );
}
