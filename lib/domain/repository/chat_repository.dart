import 'package:connect_hub/core/common/result.dart';
import 'package:connect_hub/domain/model/conversation.dart';
import 'package:connect_hub/domain/model/message.dart';

/// Conversations and messages: cached in drift, refreshed from the server,
/// and kept current by a realtime channel (typing, replies).
abstract interface class ChatRepository {
  /// The cached conversations, the most recent activity first.
  Stream<List<Conversation>> watchConversations();

  /// One cached conversation; `null` while it isn't cached.
  Stream<Conversation?> watchConversation(String conversationId);

  /// Every conversation's unread messages, added up: the Chats badge.
  Stream<int> watchUnreadMessageCount();

  Future<Result<void>> refreshConversations();

  /// A conversation's messages: the delivered ones in time order, then the
  /// ones still sending or failed.
  ///
  /// While anyone watches them, the conversation counts as *open*: a reply
  /// that arrives meanwhile is read at once (Correctness Rule 9).
  Stream<List<Message>> watchMessages(String conversationId);

  /// Makes the cache match the server's messages, keeping the ones not sent
  /// yet.
  Future<Result<void>> refreshMessages(String conversationId);

  /// Whether the other person is typing: on with the first pending reply,
  /// off after the last (Correctness Rule 8).
  Stream<bool> watchTyping(String conversationId);

  /// Shows the message at once ("Sending…"), then sends it, in order with
  /// any other message being sent. A failure leaves it "Not sent".
  Future<Result<void>> sendMessage(String conversationId, String text);

  /// Sends a failed message again, with the same id: the server can't store
  /// it twice.
  Future<Result<void>> retryMessage(String messageId);

  /// Marks a conversation read at once; rolled back if the server refuses.
  Future<Result<void>> markRead(String conversationId);
}
