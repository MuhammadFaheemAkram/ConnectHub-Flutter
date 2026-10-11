import 'package:connect_hub/core/common/result.dart';
import 'package:connect_hub/domain/repository/profile_repository.dart';
import 'package:injectable/injectable.dart';

/// Fetches a user's posts into the cache.
@injectable
class RefreshUserPostsUseCase {
  const RefreshUserPostsUseCase(this._profiles);

  final ProfileRepository _profiles;

  Future<Result<void>> call(String userId) =>
      _profiles.refreshUserPosts(userId);
}
