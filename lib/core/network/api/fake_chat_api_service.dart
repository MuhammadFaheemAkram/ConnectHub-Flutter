import 'package:connect_hub/core/network/api/chat_api_service.dart';
import 'package:connect_hub/core/network/api/fake_api_client.dart';
import 'package:connect_hub/core/network/dto/chat_event_dto.dart';
import 'package:connect_hub/core/network/dto/conversation_dto.dart';
import 'package:connect_hub/core/network/dto/message_dto.dart';
import 'package:connect_hub/core/network/fake_server/fake_server.dart';
import 'package:injectable/injectable.dart';

/// [ChatApiService] backed by the in-memory [FakeServer].
@LazySingleton(as: ChatApiService)
class FakeChatApiService implements ChatApiService {
  const FakeChatApiService(this._client, this._server);

  final FakeApiClient _client;
  final FakeServer _server;

  static const _readLatency = Duration(milliseconds: 400);
  static const _writeLatency = Duration(milliseconds: 350);

  @override
  Future<List<ConversationDto>> getConversations() async {
    final userId = await _client.authenticate(_readLatency);
    return _server.getConversations(userId);
  }

  @override
  Future<List<MessageDto>> getMessages(String conversationId) async {
    final userId = await _client.authenticate(_readLatency);
    return _server.getMessages(userId, conversationId);
  }

  @override
  Future<MessageDto> sendMessage(
    String conversationId, {
    required String clientId,
    required String text,
  }) async {
    final userId = await _client.authenticate(_writeLatency);
    return _server.sendMessage(
      userId,
      conversationId,
      clientId: clientId,
      text: text,
    );
  }

  @override
  Future<void> markRead(String conversationId) async {
    final userId = await _client.authenticate(_writeLatency);
    return _server.markConversationRead(userId, conversationId);
  }

  /// Connecting is authenticated like any request (it fails offline, or with
  /// a 401); after that, events flow until the subscription is cancelled.
  @override
  Stream<ChatEventDto> events() async* {
    final userId = await _client.authenticate(Duration.zero);
    yield* _server.chatEvents(userId);
  }
}
