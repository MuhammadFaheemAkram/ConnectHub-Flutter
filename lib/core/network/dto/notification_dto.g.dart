// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: type=lint

part of 'notification_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NotificationDto _$NotificationDtoFromJson(Map<String, dynamic> json) =>
    $checkedCreate('NotificationDto', json, ($checkedConvert) {
      final val = NotificationDto(
        id: $checkedConvert('id', (v) => v as String),
        kind: $checkedConvert(
          'kind',
          (v) => $enumDecode(_$NotificationKindDtoEnumMap, v),
        ),
        text: $checkedConvert('text', (v) => v as String),
        createdAt: $checkedConvert(
          'createdAt',
          (v) => DateTime.parse(v as String),
        ),
        isRead: $checkedConvert('isRead', (v) => v as bool),
        postId: $checkedConvert('postId', (v) => v as String?),
        userId: $checkedConvert('userId', (v) => v as String?),
      );
      return val;
    });

const _$NotificationKindDtoEnumMap = {
  NotificationKindDto.like: 'like',
  NotificationKindDto.comment: 'comment',
  NotificationKindDto.follow: 'follow',
  NotificationKindDto.mention: 'mention',
};
