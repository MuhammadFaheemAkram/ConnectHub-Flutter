// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: type=lint

part of 'message_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MessageDto _$MessageDtoFromJson(Map<String, dynamic> json) =>
    $checkedCreate('MessageDto', json, ($checkedConvert) {
      final val = MessageDto(
        id: $checkedConvert('id', (v) => v as String),
        conversationId: $checkedConvert('conversationId', (v) => v as String),
        senderId: $checkedConvert('senderId', (v) => v as String),
        text: $checkedConvert('text', (v) => v as String),
        createdAt: $checkedConvert(
          'createdAt',
          (v) => DateTime.parse(v as String),
        ),
      );
      return val;
    });
