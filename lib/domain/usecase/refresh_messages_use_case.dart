import 'package:connect_hub/core/common/result.dart';
import 'package:connect_hub/domain/repository/chat_repository.dart';
import 'package:injectable/injectable.dart';

/// Fetches a conversation's messages into the cache.
@injectable
class RefreshMessagesUseCase {
  const RefreshMessagesUseCase(this._chat);

  final ChatRepository _chat;

  Future<Result<void>> call(String conversationId) =>
      _chat.refreshMessages(conversationId);
}
