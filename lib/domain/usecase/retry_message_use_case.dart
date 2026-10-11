import 'package:connect_hub/core/common/result.dart';
import 'package:connect_hub/domain/repository/chat_repository.dart';
import 'package:injectable/injectable.dart';

/// Sends a failed message again ("Tap to retry").
@injectable
class RetryMessageUseCase {
  const RetryMessageUseCase(this._chat);

  final ChatRepository _chat;

  Future<Result<void>> call(String messageId) => _chat.retryMessage(messageId);
}
