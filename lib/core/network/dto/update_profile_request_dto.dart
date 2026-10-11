import 'package:json_annotation/json_annotation.dart';

part 'update_profile_request_dto.g.dart';

/// The body of `PATCH /me`: the signed-in user's new name, bio and picture.
///
/// Like `CreatePostRequestDto`, a request DTO only needs `toJson`.
@JsonSerializable(createFactory: false)
class UpdateProfileRequestDto {
  const UpdateProfileRequestDto({
    required this.name,
    required this.bio,
    this.avatarUrl,
  });

  final String name;
  final String bio;

  @JsonKey(name: 'avatarURL')
  final String? avatarUrl;

  Map<String, dynamic> toJson() => _$UpdateProfileRequestDtoToJson(this);
}
