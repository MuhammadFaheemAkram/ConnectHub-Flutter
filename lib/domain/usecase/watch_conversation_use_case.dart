import 'package:connect_hub/domain/model/conversation.dart';
import 'package:connect_hub/domain/repository/chat_repository.dart';
import 'package:injectable/injectable.dart';

/// One cached conversation as a stream; `null` while it isn't cached.
@injectable
class WatchConversationUseCase {
  const WatchConversationUseCase(this._chat);

  final ChatRepository _chat;

  Stream<Conversation?> call(String conversationId) =>
      _chat.watchConversation(conversationId);
}
