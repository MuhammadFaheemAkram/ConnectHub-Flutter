import 'dart:async';

import 'package:connect_hub/core/common/app_exception.dart';
import 'package:connect_hub/core/network/api/chat_api_service.dart';
import 'package:connect_hub/core/network/dto/chat_event_dto.dart';
import 'package:connect_hub/core/network/dto/conversation_dto.dart';
import 'package:connect_hub/core/network/dto/message_dto.dart';

/// Wraps a real [ChatApiService] to stage what a real network does to sends:
/// - [holdNextSend] keeps the next send "in flight" until it is completed;
/// - [loseNextAnswer] lets the next send reach the server, then loses the
///   answer on the way back (a [NetworkException]): the case a retry must
///   not turn into a duplicate.
class GatedChatApi implements ChatApiService {
  GatedChatApi(this._inner);

  final ChatApiService _inner;

  Completer<void>? holdNextSend;
  bool loseNextAnswer = false;

  @override
  Future<MessageDto> sendMessage(
    String conversationId, {
    required String clientId,
    required String text,
  }) async {
    final hold = holdNextSend;
    holdNextSend = null;
    await hold?.future;
    final sent = await _inner.sendMessage(
      conversationId,
      clientId: clientId,
      text: text,
    );
    if (loseNextAnswer) {
      loseNextAnswer = false;
      throw const NetworkException();
    }
    return sent;
  }

  @override
  Future<List<ConversationDto>> getConversations() => _inner.getConversations();

  @override
  Future<List<MessageDto>> getMessages(String conversationId) =>
      _inner.getMessages(conversationId);

  @override
  Future<void> markRead(String conversationId) =>
      _inner.markRead(conversationId);

  @override
  Stream<ChatEventDto> events() => _inner.events();
}
