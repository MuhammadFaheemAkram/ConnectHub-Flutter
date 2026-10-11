import 'package:connect_hub/core/common/ui_message.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'settings_tools_state.freezed.dart';

/// The Settings screen's actions: Storage and Developer.
@freezed
abstract class SettingsToolsState with _$SettingsToolsState {
  const factory SettingsToolsState({
    /// "Simulate network failure".
    @Default(false) bool failsRequests,
    @Default(false) bool isClearingCache,

    /// A one-time SnackBar.
    UiMessage? message,
  }) = _SettingsToolsState;
}
