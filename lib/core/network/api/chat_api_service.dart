import 'package:connect_hub/core/network/dto/chat_event_dto.dart';
import 'package:connect_hub/core/network/dto/conversation_dto.dart';
import 'package:connect_hub/core/network/dto/message_dto.dart';

/// The chat endpoints, Retrofit-style, plus the realtime channel. Every call
/// is authenticated.
abstract interface class ChatApiService {
  /// `GET /me/conversations`: the most recent activity first.
  Future<List<ConversationDto>> getConversations();

  /// `GET /conversations/{id}/messages`: oldest first.
  Future<List<MessageDto>> getMessages(String conversationId);

  /// `POST /conversations/{id}/messages`. [clientId] is the id the client
  /// gave the message: sending it twice stores it once.
  Future<MessageDto> sendMessage(
    String conversationId, {
    required String clientId,
    required String text,
  });

  /// `POST /conversations/{id}/read`
  Future<void> markRead(String conversationId);

  /// The realtime channel (a WebSocket, in a real app): typing started,
  /// typing stopped, message received. It stays open until cancelled.
  Stream<ChatEventDto> events();
}
