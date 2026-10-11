import 'package:connect_hub/domain/repository/chat_repository.dart';
import 'package:injectable/injectable.dart';

/// Unread messages across every conversation, as a stream: the Chats badge.
@injectable
class WatchUnreadMessageCountUseCase {
  const WatchUnreadMessageCountUseCase(this._chat);

  final ChatRepository _chat;

  Stream<int> call() => _chat.watchUnreadMessageCount();
}
