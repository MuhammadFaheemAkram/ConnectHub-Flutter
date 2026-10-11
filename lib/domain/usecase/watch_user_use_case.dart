import 'package:connect_hub/domain/model/user.dart';
import 'package:connect_hub/domain/repository/profile_repository.dart';
import 'package:injectable/injectable.dart';

/// One cached profile as a stream; `null` while it isn't cached.
@injectable
class WatchUserUseCase {
  const WatchUserUseCase(this._profiles);

  final ProfileRepository _profiles;

  Stream<User?> call(String userId) => _profiles.watchUser(userId);
}
