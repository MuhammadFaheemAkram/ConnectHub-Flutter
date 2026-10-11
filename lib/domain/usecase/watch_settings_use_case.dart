import 'package:connect_hub/domain/model/app_settings.dart';
import 'package:connect_hub/domain/repository/settings_repository.dart';
import 'package:injectable/injectable.dart';

/// The settings as a stream: the current value first, then every change.
@injectable
class WatchSettingsUseCase {
  const WatchSettingsUseCase(this._settings);

  final SettingsRepository _settings;

  Stream<AppSettings> call() => _settings.watchSettings();
}
