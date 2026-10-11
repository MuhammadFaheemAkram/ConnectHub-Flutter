import 'package:connect_hub/core/common/result.dart';
import 'package:connect_hub/domain/repository/chat_repository.dart';
import 'package:injectable/injectable.dart';

/// Sends a chat message. The text is trimmed first; a blank one is not sent.
@injectable
class SendMessageUseCase {
  const SendMessageUseCase(this._chat);

  final ChatRepository _chat;

  Future<Result<void>> call(String conversationId, String text) {
    final message = text.trim();
    if (message.isEmpty) return Future.value(const Ok(null));
    return _chat.sendMessage(conversationId, message);
  }
}
