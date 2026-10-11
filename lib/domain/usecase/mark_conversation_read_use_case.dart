import 'package:connect_hub/core/common/result.dart';
import 'package:connect_hub/domain/repository/chat_repository.dart';
import 'package:injectable/injectable.dart';

/// Marks a conversation read (optimistic, rolled back on failure).
@injectable
class MarkConversationReadUseCase {
  const MarkConversationReadUseCase(this._chat);

  final ChatRepository _chat;

  Future<Result<void>> call(String conversationId) =>
      _chat.markRead(conversationId);
}
