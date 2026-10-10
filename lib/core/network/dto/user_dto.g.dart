// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: type=lint

part of 'user_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserDto _$UserDtoFromJson(Map<String, dynamic> json) =>
    $checkedCreate('UserDto', json, ($checkedConvert) {
      final val = UserDto(
        id: $checkedConvert('id', (v) => v as String),
        name: $checkedConvert('name', (v) => v as String),
        email: $checkedConvert('email', (v) => v as String?),
        avatarUrl: $checkedConvert('avatarURL', (v) => v as String?),
        bio: $checkedConvert('bio', (v) => v as String? ?? ''),
        followersCount: $checkedConvert(
          'followersCount',
          (v) => (v as num?)?.toInt() ?? 0,
        ),
        followingCount: $checkedConvert(
          'followingCount',
          (v) => (v as num?)?.toInt() ?? 0,
        ),
      );
      return val;
    }, fieldKeyMap: const {'avatarUrl': 'avatarURL'});
