import 'package:connect_hub/core/common/ui_message.dart';
import 'package:connect_hub/domain/model/conversation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'chats_state.freezed.dart';

/// Where the list stands. "Empty" is [loaded] with no conversations.
enum ChatsStatus {
  /// Nothing cached yet, and the server hasn't answered.
  loading,

  /// Showing what's cached (possibly nothing).
  loaded,

  /// Nothing cached, and fetching failed.
  failure,
}

/// One class rather than a union: the search query outlives every status.
@freezed
abstract class ChatsState with _$ChatsState {
  const ChatsState._();

  const factory ChatsState({
    @Default(ChatsStatus.loading) ChatsStatus status,

    /// Every cached conversation, the most recent activity first.
    @Default(<Conversation>[]) List<Conversation> conversations,

    /// The search field's text, as typed.
    @Default('') String query,
    @Default('') String errorMessage,

    /// A one-time SnackBar.
    UiMessage? message,
  }) = _ChatsState;

  /// The conversations the search matches, by name or last message,
  /// ignoring case. Local and instant: no request.
  List<Conversation> get visible {
    final query = this.query.trim().toLowerCase();
    if (query.isEmpty) return conversations;
    return [
      for (final conversation in conversations)
        if (conversation.participant.name.toLowerCase().contains(query) ||
            conversation.lastMessage.toLowerCase().contains(query))
          conversation,
    ];
  }
}
