import 'package:connect_hub/core/network/dto/conversation_dto.dart';
import 'package:connect_hub/core/network/dto/message_dto.dart';

/// What the realtime chat channel pushes to the client, without being asked.
///
/// A real client would decode these from the socket's JSON frames (a `type`
/// field picks the subclass). The fake channel hands the objects over as is.
sealed class ChatEventDto {
  const ChatEventDto(this.conversationId);

  final String conversationId;
}

/// The other person started typing a reply.
final class TypingStartedEvent extends ChatEventDto {
  const TypingStartedEvent(super.conversationId);
}

/// The other person has no reply left to type.
final class TypingStoppedEvent extends ChatEventDto {
  const TypingStoppedEvent(super.conversationId);
}

/// A reply arrived, with the conversation as it now stands (last message,
/// unread count).
final class MessageReceivedEvent extends ChatEventDto {
  MessageReceivedEvent({required this.message, required this.conversation})
    : super(message.conversationId);

  final MessageDto message;
  final ConversationDto conversation;
}
