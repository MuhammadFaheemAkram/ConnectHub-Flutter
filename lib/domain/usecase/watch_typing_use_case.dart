import 'package:connect_hub/domain/repository/chat_repository.dart';
import 'package:injectable/injectable.dart';

/// Whether the other person is typing in a conversation, as a stream.
@injectable
class WatchTypingUseCase {
  const WatchTypingUseCase(this._chat);

  final ChatRepository _chat;

  Stream<bool> call(String conversationId) => _chat.watchTyping(conversationId);
}
