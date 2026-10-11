import 'package:connect_hub/domain/repository/settings_repository.dart';
import 'package:injectable/injectable.dart';

/// Turns the unread badges (Activity, Chats) on or off.
@injectable
class UpdateNotificationsEnabledUseCase {
  const UpdateNotificationsEnabledUseCase(this._settings);

  final SettingsRepository _settings;

  Future<void> call({required bool enabled}) =>
      _settings.updateNotificationsEnabled(enabled: enabled);
}
