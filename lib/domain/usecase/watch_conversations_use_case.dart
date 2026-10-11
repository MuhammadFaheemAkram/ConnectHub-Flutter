import 'package:connect_hub/domain/model/conversation.dart';
import 'package:connect_hub/domain/repository/chat_repository.dart';
import 'package:injectable/injectable.dart';

/// The cached conversations as a stream, the most recent activity first.
@injectable
class WatchConversationsUseCase {
  const WatchConversationsUseCase(this._chat);

  final ChatRepository _chat;

  Stream<List<Conversation>> call() => _chat.watchConversations();
}
