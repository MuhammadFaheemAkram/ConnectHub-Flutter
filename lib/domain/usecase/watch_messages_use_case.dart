import 'package:connect_hub/domain/model/message.dart';
import 'package:connect_hub/domain/repository/chat_repository.dart';
import 'package:injectable/injectable.dart';

/// A conversation's cached messages as a stream. While watched, the
/// conversation counts as open (its replies are read at once).
@injectable
class WatchMessagesUseCase {
  const WatchMessagesUseCase(this._chat);

  final ChatRepository _chat;

  Stream<List<Message>> call(String conversationId) =>
      _chat.watchMessages(conversationId);
}
