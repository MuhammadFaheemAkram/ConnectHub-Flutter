import 'package:connect_hub/domain/model/app_language.dart';
import 'package:connect_hub/domain/repository/settings_repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class UpdateLanguageUseCase {
  const UpdateLanguageUseCase(this._settings);

  final SettingsRepository _settings;

  Future<void> call(AppLanguage language) => _settings.updateLanguage(language);
}
