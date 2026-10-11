import 'package:freezed_annotation/freezed_annotation.dart';

part 'message.freezed.dart';

/// Where one of the user's messages stands.
enum MessageStatus {
  /// On its way to the server: "Sending…".
  sending,

  /// The server has it.
  sent,

  /// The server didn't get it: "Not sent · Tap to retry".
  failed,
}

/// One chat message. [isMine] is worked out from the signed-in user when the
/// messages are read, never stored.
@freezed
abstract class Message with _$Message {
  const factory Message({
    required String id,
    required String conversationId,
    required String senderId,
    required String text,
    required DateTime createdAt,
    required bool isMine,
    @Default(MessageStatus.sent) MessageStatus status,
  }) = _Message;
}
