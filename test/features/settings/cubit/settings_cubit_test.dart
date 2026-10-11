import 'package:bloc_test/bloc_test.dart';
import 'package:connect_hub/domain/model/app_language.dart';
import 'package:connect_hub/domain/model/app_settings.dart';
import 'package:connect_hub/domain/model/app_theme_mode.dart';
import 'package:connect_hub/domain/usecase/get_settings_use_case.dart';
import 'package:connect_hub/domain/usecase/update_language_use_case.dart';
import 'package:connect_hub/domain/usecase/update_notifications_enabled_use_case.dart';
import 'package:connect_hub/domain/usecase/update_theme_mode_use_case.dart';
import 'package:connect_hub/domain/usecase/watch_settings_use_case.dart';
import 'package:connect_hub/features/settings/cubit/settings_cubit.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fakes/fake_settings_repository.dart';

void main() {
  late FakeSettingsRepository settings;

  setUp(() => settings = FakeSettingsRepository());
  tearDown(() => settings.dispose());

  SettingsCubit buildCubit() => SettingsCubit(
    GetSettingsUseCase(settings),
    WatchSettingsUseCase(settings),
    UpdateThemeModeUseCase(settings),
    UpdateNotificationsEnabledUseCase(settings),
    UpdateLanguageUseCase(settings),
  );

  test('the first state is the saved settings, read synchronously '
      '(Correctness Rule 13)', () {
    settings = FakeSettingsRepository(
      const AppSettings(themeMode: AppThemeMode.dark),
    );

    final cubit = buildCubit();
    addTearDown(cubit.close);

    // No await: the first frame already has it.
    expect(cubit.state.themeMode, AppThemeMode.dark);
  });

  blocTest<SettingsCubit, AppSettings>(
    'selecting Dark saves it, and the app hears it',
    build: buildCubit,
    act: (cubit) => cubit.selectThemeMode(AppThemeMode.dark),
    expect: () => [const AppSettings(themeMode: AppThemeMode.dark)],
    verify: (_) =>
        expect(settings.currentSettings.themeMode, AppThemeMode.dark),
  );

  blocTest<SettingsCubit, AppSettings>(
    'the badges switch and the language',
    build: buildCubit,
    act: (cubit) async {
      await cubit.setNotificationsEnabled(enabled: false);
      await cubit.selectLanguage(AppLanguage.fr);
    },
    expect: () => [
      const AppSettings(notificationsEnabled: false),
      const AppSettings(notificationsEnabled: false, language: AppLanguage.fr),
    ],
  );

  blocTest<SettingsCubit, AppSettings>(
    'a change made elsewhere reaches it too',
    build: buildCubit,
    act: (_) => settings.updateLanguage(AppLanguage.de),
    expect: () => [const AppSettings(language: AppLanguage.de)],
  );
}
