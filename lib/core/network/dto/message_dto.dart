import 'package:json_annotation/json_annotation.dart';

part 'message_dto.g.dart';

/// One chat message. Whether it is *mine* isn't sent: the client compares
/// [senderId] with the signed-in user.
///
/// For a message the client sent, [id] is the id the client generated, so a
/// retried send can't create a duplicate.
@JsonSerializable(createToJson: false, checked: true)
class MessageDto {
  const MessageDto({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.text,
    required this.createdAt,
  });

  factory MessageDto.fromJson(Map<String, dynamic> json) =>
      _$MessageDtoFromJson(json);

  final String id;
  final String conversationId;
  final String senderId;
  final String text;
  final DateTime createdAt;
}
