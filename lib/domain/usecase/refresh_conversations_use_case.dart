import 'package:connect_hub/core/common/result.dart';
import 'package:connect_hub/domain/repository/chat_repository.dart';
import 'package:injectable/injectable.dart';

/// Fetches the server's conversations into the cache.
@injectable
class RefreshConversationsUseCase {
  const RefreshConversationsUseCase(this._chat);

  final ChatRepository _chat;

  Future<Result<void>> call() => _chat.refreshConversations();
}
