import 'package:connect_hub/core/common/ui_message.dart';
import 'package:connect_hub/domain/model/message.dart';
import 'package:connect_hub/domain/model/user.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'chat_detail_state.freezed.dart';

/// Where the chat stands.
enum ChatStatus {
  /// Nothing cached yet, and the server hasn't answered.
  loading,

  /// The messages, possibly none yet ("Say hello 👋").
  ready,

  /// The server has no such conversation (for this user).
  notFound,

  /// Nothing cached, and fetching failed.
  failure,
}

@freezed
abstract class ChatDetailState with _$ChatDetailState {
  const factory ChatDetailState({
    @Default(ChatStatus.loading) ChatStatus status,

    /// The other person; `null` until the conversation is cached.
    User? participant,

    /// Oldest first: the delivered messages in time order, then the ones
    /// still sending or failed.
    @Default(<Message>[]) List<Message> messages,

    /// A reply is on its way: the three dots.
    @Default(false) bool isTyping,
    @Default('') String errorMessage,

    /// A one-time SnackBar.
    UiMessage? message,
  }) = _ChatDetailState;
}
