import 'package:connect_hub/core/database/app_database.dart';
import 'package:connect_hub/core/network/dto/user_dto.dart';
import 'package:connect_hub/domain/model/user.dart';

extension UserDtoMapper on UserDto {
  /// The row cached for this user. The email is never cached: only the
  /// session knows it.
  UserRow toRow() => UserRow(
    id: id,
    name: name,
    avatarUrl: avatarUrl,
    bio: bio,
    followersCount: followersCount,
    followingCount: followingCount,
  );
}

extension UserRowMapper on UserRow {
  User toDomain() => User(
    id: id,
    name: name,
    avatarUrl: avatarUrl,
    bio: bio,
    followersCount: followersCount,
    followingCount: followingCount,
  );
}
