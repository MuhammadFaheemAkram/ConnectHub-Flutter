import 'package:connect_hub/core/common/app_exception.dart';
import 'package:connect_hub/core/common/result.dart';
import 'package:connect_hub/core/database/daos/posts_dao.dart';
import 'package:connect_hub/core/database/daos/users_dao.dart';
import 'package:connect_hub/core/network/api/user_api_service.dart';
import 'package:connect_hub/core/network/dto/update_profile_request_dto.dart';
import 'package:connect_hub/data/mapper/post_mappers.dart';
import 'package:connect_hub/data/mapper/user_mappers.dart';
import 'package:connect_hub/data/repository/api_guard.dart';
import 'package:connect_hub/domain/model/post.dart';
import 'package:connect_hub/domain/model/user.dart';
import 'package:connect_hub/domain/repository/profile_repository.dart';
import 'package:injectable/injectable.dart';

/// Profiles, read from the cache and refreshed from the server.
///
/// Authors are stored once, in `users`, and every post and comment JOINs
/// them. That is what lets an edit show up everywhere: [updateProfile]
/// rewrites one row, and every list on every screen re-renders with the new
/// name. Both native editions copied the author into each post, so an edited
/// name never reached them.
@LazySingleton(as: ProfileRepository)
class ProfileRepositoryImpl implements ProfileRepository {
  ProfileRepositoryImpl(this._api, this._users, this._posts, this._guard);

  final UserApiService _api;
  final UsersDao _users;
  final PostsDao _posts;
  final ApiGuard _guard;

  @override
  Stream<User?> watchUser(String userId) =>
      _users.watchUser(userId).map((row) => row?.toDomain());

  @override
  Future<Result<void>> refreshUser(String userId) async {
    final result = await _guard.run(() => _api.getUser(userId));
    switch (result) {
      case Ok(value: final user):
        await _users.upsertUser(user.toRow());
        return const Ok(null);
      case Err(:final exception):
        return Err(exception);
    }
  }

  @override
  Stream<List<Post>> watchUserPosts(String userId) => _posts
      .watchPostsByAuthor(userId)
      .map((entries) => [for (final entry in entries) entry.toDomain()]);

  @override
  Future<Result<void>> refreshUserPosts(String userId) async {
    final result = await _guard.run(() => _api.getUserPosts(userId));
    switch (result) {
      case Ok(value: final posts):
        await _posts.replacePostsByAuthor(userId, [
          for (final post in posts) post.toCached(),
        ]);
        return const Ok(null);
      case Err(:final exception):
        // No such user, so no such posts: the cached ones go too (Rule 1).
        if (exception is NotFoundException) {
          await _posts.replacePostsByAuthor(userId, const []);
        }
        return Err(exception);
    }
  }

  /// Not optimistic: the server may refuse (and trims what it stores), so
  /// the cache takes its answer. The form shows progress meanwhile.
  @override
  Future<Result<void>> updateProfile({
    required String name,
    required String bio,
    String? avatarUrl,
  }) async {
    final request = UpdateProfileRequestDto(
      name: name,
      bio: bio,
      avatarUrl: avatarUrl,
    );
    final result = await _guard.run(() => _api.updateMe(request));
    switch (result) {
      case Ok(value: final user):
        await _users.upsertUser(user.toRow());
        return const Ok(null);
      case Err(:final exception):
        return Err(exception);
    }
  }
}
