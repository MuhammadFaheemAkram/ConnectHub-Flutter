import 'package:connect_hub/domain/model/post.dart';
import 'package:connect_hub/domain/repository/profile_repository.dart';
import 'package:injectable/injectable.dart';

/// A user's cached posts as a stream, newest first.
@injectable
class WatchUserPostsUseCase {
  const WatchUserPostsUseCase(this._profiles);

  final ProfileRepository _profiles;

  Stream<List<Post>> call(String userId) => _profiles.watchUserPosts(userId);
}
