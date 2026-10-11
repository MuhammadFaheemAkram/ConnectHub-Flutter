import 'package:connect_hub/core/common/result.dart';
import 'package:connect_hub/domain/model/post.dart';
import 'package:connect_hub/domain/model/user.dart';

/// Profiles: anyone's, read from the cache and refreshed from the server,
/// and the signed-in user's own, which they can edit.
abstract interface class ProfileRepository {
  /// The cached profile: now, then after every change; `null` while it
  /// isn't cached.
  Stream<User?> watchUser(String userId);

  /// Fetches the profile into the cache. Answers `NotFoundException` when
  /// the server has no such user.
  Future<Result<void>> refreshUser(String userId);

  /// The user's cached posts, newest first: now, then after every change.
  Stream<List<Post>> watchUserPosts(String userId);

  /// Makes the cache match the server's list of the user's posts.
  Future<Result<void>> refreshUserPosts(String userId);

  /// Saves the signed-in user's profile. Once the server has it, the cache
  /// is updated, so every post and comment they wrote shows the new name and
  /// picture.
  Future<Result<void>> updateProfile({
    required String name,
    required String bio,
    String? avatarUrl,
  });
}
