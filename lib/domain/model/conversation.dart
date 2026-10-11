import 'package:connect_hub/domain/model/user.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'conversation.freezed.dart';

/// A chat with one other person, as the Chats list shows it.
@freezed
abstract class Conversation with _$Conversation {
  const factory Conversation({
    required String id,
    required User participant,
    required String lastMessage,
    required int unreadCount,
    required DateTime updatedAt,
  }) = _Conversation;
}
