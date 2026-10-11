import 'dart:async';

import 'package:connect_hub/domain/model/app_language.dart';
import 'package:connect_hub/domain/model/app_settings.dart';
import 'package:connect_hub/domain/model/app_theme_mode.dart';
import 'package:connect_hub/domain/usecase/get_settings_use_case.dart';
import 'package:connect_hub/domain/usecase/update_language_use_case.dart';
import 'package:connect_hub/domain/usecase/update_notifications_enabled_use_case.dart';
import 'package:connect_hub/domain/usecase/update_theme_mode_use_case.dart';
import 'package:connect_hub/domain/usecase/watch_settings_use_case.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

/// App-scoped settings: one instance, provided *above* `MaterialApp.router`.
///
/// - The app root reads `themeMode` from it.
/// - The Settings screen reads and changes the settings through it.
///
/// It is a Cubit, not a Bloc. It is app-wide, but its intents are plain
/// setters, with no event semantics (debouncing, cancellation) that would
/// justify events. Its first state comes synchronously from the repository,
/// which read `shared_preferences` before `runApp`, so the saved theme
/// applies from the very first frame (Correctness Rule 13).
@injectable
class SettingsCubit extends Cubit<AppSettings> {
  SettingsCubit(
    GetSettingsUseCase getSettings,
    WatchSettingsUseCase watchSettings,
    this._updateThemeMode,
    this._updateNotificationsEnabled,
    this._updateLanguage,
  ) : super(getSettings()) {
    _subscription = watchSettings().listen((settings) {
      if (settings != state) emit(settings);
    });
  }

  final UpdateThemeModeUseCase _updateThemeMode;
  final UpdateNotificationsEnabledUseCase _updateNotificationsEnabled;
  final UpdateLanguageUseCase _updateLanguage;
  late final StreamSubscription<AppSettings> _subscription;

  /// The repository publishes the change and this Cubit re-emits it, so
  /// there is exactly one path for new settings to reach the UI.
  Future<void> selectThemeMode(AppThemeMode mode) => _updateThemeMode(mode);

  /// "Show unread badges": the Activity tab's and the Chats button's.
  Future<void> setNotificationsEnabled({required bool enabled}) =>
      _updateNotificationsEnabled(enabled: enabled);

  Future<void> selectLanguage(AppLanguage language) =>
      _updateLanguage(language);

  @override
  Future<void> close() async {
    await _subscription.cancel();
    return super.close();
  }
}
