import 'dart:async';

import 'package:connect_hub/domain/model/app_language.dart';
import 'package:connect_hub/domain/model/app_settings.dart';
import 'package:connect_hub/domain/model/app_theme_mode.dart';
import 'package:connect_hub/domain/repository/settings_repository.dart';

/// An in-memory [SettingsRepository]: like the real one, the current value is
/// synchronous, and `watchSettings()` emits it, then every change.
class FakeSettingsRepository implements SettingsRepository {
  FakeSettingsRepository([this._current = const AppSettings()]);

  AppSettings _current;
  final _changes = StreamController<AppSettings>.broadcast(sync: true);

  @override
  AppSettings get currentSettings => _current;

  @override
  Stream<AppSettings> watchSettings() => Stream.multi((watcher) {
    final subscription = _changes.stream.listen(watcher.add);
    watcher
      ..onCancel = subscription.cancel
      ..add(_current);
  });

  @override
  Future<void> updateThemeMode(AppThemeMode mode) async =>
      _publish(_current.copyWith(themeMode: mode));

  @override
  Future<void> updateNotificationsEnabled({required bool enabled}) async =>
      _publish(_current.copyWith(notificationsEnabled: enabled));

  @override
  Future<void> updateLanguage(AppLanguage language) async =>
      _publish(_current.copyWith(language: language));

  void _publish(AppSettings settings) {
    _current = settings;
    _changes.add(settings);
  }

  Future<void> dispose() => _changes.close();
}
