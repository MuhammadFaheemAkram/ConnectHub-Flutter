import 'package:connect_hub/core/network/dto/user_dto.dart';
import 'package:json_annotation/json_annotation.dart';

part 'conversation_dto.g.dart';

/// A conversation as the signed-in user sees it: the other person, the last
/// message, and how many messages they haven't read.
@JsonSerializable(createToJson: false, checked: true)
class ConversationDto {
  const ConversationDto({
    required this.id,
    required this.participant,
    required this.lastMessage,
    required this.unreadCount,
    required this.updatedAt,
  });

  factory ConversationDto.fromJson(Map<String, dynamic> json) =>
      _$ConversationDtoFromJson(json);

  final String id;
  final UserDto participant;
  final String lastMessage;
  final int unreadCount;
  final DateTime updatedAt;
}
