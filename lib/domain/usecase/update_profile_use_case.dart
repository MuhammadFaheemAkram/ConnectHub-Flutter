import 'package:connect_hub/core/common/result.dart';
import 'package:connect_hub/domain/repository/profile_repository.dart';
import 'package:injectable/injectable.dart';

/// Saves the signed-in user's profile. Values are trimmed before they are
/// sent, and an empty avatar URL means "no picture".
@injectable
class UpdateProfileUseCase {
  const UpdateProfileUseCase(this._profiles);

  final ProfileRepository _profiles;

  Future<Result<void>> call({
    required String name,
    required String bio,
    String avatarUrl = '',
  }) {
    final url = avatarUrl.trim();
    return _profiles.updateProfile(
      name: name.trim(),
      bio: bio.trim(),
      avatarUrl: url.isEmpty ? null : url,
    );
  }
}
