import 'package:connect_hub/core/network/dto/user_dto.dart';
import 'package:json_annotation/json_annotation.dart';

part 'auth_response_dto.g.dart';

/// What sign-in and sign-up return: a bearer token and the user's profile.
@JsonSerializable(createToJson: false, checked: true)
class AuthResponseDto {
  const AuthResponseDto({required this.token, required this.user});

  factory AuthResponseDto.fromJson(Map<String, dynamic> json) =>
      _$AuthResponseDtoFromJson(json);

  final String token;
  final UserDto user;
}
