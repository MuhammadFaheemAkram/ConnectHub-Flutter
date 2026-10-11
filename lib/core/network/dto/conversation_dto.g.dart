// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: type=lint

part of 'conversation_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ConversationDto _$ConversationDtoFromJson(Map<String, dynamic> json) =>
    $checkedCreate('ConversationDto', json, ($checkedConvert) {
      final val = ConversationDto(
        id: $checkedConvert('id', (v) => v as String),
        participant: $checkedConvert(
          'participant',
          (v) => UserDto.fromJson(v as Map<String, dynamic>),
        ),
        lastMessage: $checkedConvert('lastMessage', (v) => v as String),
        unreadCount: $checkedConvert('unreadCount', (v) => (v as num).toInt()),
        updatedAt: $checkedConvert(
          'updatedAt',
          (v) => DateTime.parse(v as String),
        ),
      );
      return val;
    });
