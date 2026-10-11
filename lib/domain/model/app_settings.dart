import 'package:connect_hub/domain/model/app_language.dart';
import 'package:connect_hub/domain/model/app_theme_mode.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_settings.freezed.dart';

/// Every persisted preference as one immutable value. They belong to the
/// device, not the account: logging out keeps them.
@freezed
abstract class AppSettings with _$AppSettings {
  const factory AppSettings({
    @Default(AppThemeMode.system) AppThemeMode themeMode,

    /// Whether the Activity and Chats badges show unread counts.
    @Default(true) bool notificationsEnabled,
    @Default(AppLanguage.en) AppLanguage language,
  }) = _AppSettings;
}
