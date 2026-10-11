import 'package:async/async.dart' show StreamQueue;
import 'package:connect_hub/core/storage/settings_local_data_source.dart';
import 'package:connect_hub/data/repository/settings_repository_impl.dart';
import 'package:connect_hub/domain/model/app_language.dart';
import 'package:connect_hub/domain/model/app_settings.dart';
import 'package:connect_hub/domain/model/app_theme_mode.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

import '../../helpers/stream_helpers.dart';

void main() {
  /// An in-memory platform store, pre-filled with [stored]: the real
  /// `SharedPreferencesWithCache` code paths, with no device storage.
  void storeHolds(Map<String, Object> stored) {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.withData(stored);
  }

  setUp(() => storeHolds({}));

  /// A repository as the app creates one at launch: the cache is loaded
  /// first (`@preResolve`), then everything is read synchronously.
  Future<SettingsRepositoryImpl> launch() async {
    final repository = SettingsRepositoryImpl(
      SettingsLocalDataSource(
        await SharedPreferencesWithCache.create(
          cacheOptions: const SharedPreferencesWithCacheOptions(
            allowList: SettingsLocalDataSource.allowList,
          ),
        ),
      ),
    );
    addTearDown(repository.dispose);
    return repository;
  }

  test('defaults: System appearance, badges on, English', () async {
    final repository = await launch();

    expect(repository.currentSettings, const AppSettings());
    expect(repository.currentSettings.notificationsEnabled, isTrue);
  });

  test('saved settings are there synchronously, from the first read, so '
      'the first frame has the right theme (Correctness Rule 13)', () async {
    storeHolds({
      SettingsLocalDataSource.themeModeKey: 'dark',
      SettingsLocalDataSource.notificationsEnabledKey: false,
      SettingsLocalDataSource.languageKey: 'fr',
    });

    final repository = await launch();

    expect(
      repository.currentSettings,
      const AppSettings(
        themeMode: AppThemeMode.dark,
        notificationsEnabled: false,
        language: AppLanguage.fr,
      ),
    );
  });

  test('emits the current settings, then every change', () async {
    final repository = await launch();
    final settings = StreamQueue(repository.watchSettings());
    addTearDown(settings.cancel);

    expect(await nextEvent(settings), const AppSettings());

    await repository.updateThemeMode(AppThemeMode.dark);
    expect(
      await nextEvent(settings),
      const AppSettings(themeMode: AppThemeMode.dark),
    );

    await repository.updateNotificationsEnabled(enabled: false);
    expect(
      await nextEvent(settings),
      const AppSettings(
        themeMode: AppThemeMode.dark,
        notificationsEnabled: false,
      ),
    );
  });

  test('changes persist: the next launch reads them', () async {
    final first = await launch();
    await first.updateThemeMode(AppThemeMode.light);
    await first.updateNotificationsEnabled(enabled: false);
    await first.updateLanguage(AppLanguage.de);

    final next = await launch();

    expect(
      next.currentSettings,
      const AppSettings(
        themeMode: AppThemeMode.light,
        notificationsEnabled: false,
        language: AppLanguage.de,
      ),
    );
  });

  test('an unknown stored value falls back to the default', () async {
    storeHolds({
      SettingsLocalDataSource.themeModeKey: 'sepia',
      SettingsLocalDataSource.languageKey: 'xx',
    });

    final repository = await launch();

    expect(repository.currentSettings, const AppSettings());
  });
}
