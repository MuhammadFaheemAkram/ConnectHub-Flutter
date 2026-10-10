// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: type=lint

part of 'auth_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AuthResponseDto _$AuthResponseDtoFromJson(Map<String, dynamic> json) =>
    $checkedCreate('AuthResponseDto', json, ($checkedConvert) {
      final val = AuthResponseDto(
        token: $checkedConvert('token', (v) => v as String),
        user: $checkedConvert(
          'user',
          (v) => UserDto.fromJson(v as Map<String, dynamic>),
        ),
      );
      return val;
    });
