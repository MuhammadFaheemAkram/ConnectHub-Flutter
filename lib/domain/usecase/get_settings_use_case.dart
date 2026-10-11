import 'package:connect_hub/domain/model/app_settings.dart';
import 'package:connect_hub/domain/repository/settings_repository.dart';
import 'package:injectable/injectable.dart';

/// The settings right now (synchronous). The Settings Cubit's first state,
/// so the first frame already has the right theme.
@injectable
class GetSettingsUseCase {
  const GetSettingsUseCase(this._settings);

  final SettingsRepository _settings;

  AppSettings call() => _settings.currentSettings;
}
