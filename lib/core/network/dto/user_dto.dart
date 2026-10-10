import 'package:json_annotation/json_annotation.dart';

part 'user_dto.g.dart';

/// A user as the API sends it.
///
/// The keys match the iOS edition's JSON, which is camelCase apart from
/// `avatarURL`. That one key is renamed with `@JsonKey`; MovieExplorer used a
/// blanket `fieldRename: snake` instead, because its JSON was snake_case.
@JsonSerializable(createToJson: false, checked: true)
class UserDto {
  const UserDto({
    required this.id,
    required this.name,
    this.email,
    this.avatarUrl,
    this.bio = '',
    this.followersCount = 0,
    this.followingCount = 0,
  });

  factory UserDto.fromJson(Map<String, dynamic> json) =>
      _$UserDtoFromJson(json);

  final String id;
  final String name;

  /// Only present on the signed-in user's own record.
  final String? email;

  @JsonKey(name: 'avatarURL')
  final String? avatarUrl;

  final String bio;
  final int followersCount;
  final int followingCount;
}
