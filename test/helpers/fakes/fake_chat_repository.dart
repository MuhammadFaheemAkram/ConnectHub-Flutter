import 'dart:async';

import 'package:connect_hub/core/common/result.dart';
import 'package:connect_hub/domain/model/conversation.dart';
import 'package:connect_hub/domain/model/message.dart';
import 'package:connect_hub/domain/repository/chat_repository.dart';

/// A scriptable [ChatRepository] for the Cubit tests.
///
/// Like drift, the watch methods emit the current value, then every change,
/// announced asynchronously (conventions §11.3).
class FakeChatRepository implements ChatRepository {
  FakeChatRepository({
    List<Conversation> cachedConversations = const [],
    Map<String, List<Message>> cachedMessages = const {},
  }) : _conversations = cachedConversations,
       _messages = Map.of(cachedMessages);

  List<Conversation> _conversations;
  final Map<String, List<Message>> _messages;
  final _typing = <String>{};
  final _changes = StreamController<void>.broadcast();

  /// What a successful refresh leaves cached (`null`: unchanged).
  List<Conversation>? refreshedConversations;
  Result<void> refreshConversationsResult = const Ok(null);
  final refreshedMessages = <String, List<Message>>{};
  Result<void> refreshMessagesResult = const Ok(null);
  Result<void> sendResult = const Ok(null);
  Result<void> retryResult = const Ok(null);
  Result<void> markReadResult = const Ok(null);

  /// While set and not completed, refreshes wait for it.
  Completer<void>? gate;

  int refreshConversationsCalls = 0;
  final refreshMessagesCalls = <String>[];
  final sent = <({String conversationId, String text})>[];
  final retried = <String>[];
  final markedRead = <String>[];

  /// How many watchers each conversation's messages have (open screens).
  final openWatchers = <String, int>{};

  @override
  Stream<List<Conversation>> watchConversations() =>
      _watch(() => _conversations);

  @override
  Stream<Conversation?> watchConversation(String conversationId) => _watch(
    () => _conversations
        .where((conversation) => conversation.id == conversationId)
        .firstOrNull,
  );

  @override
  Stream<int> watchUnreadMessageCount() =>
      _watch(() => _conversations.fold(0, (sum, c) => sum + c.unreadCount));

  @override
  Future<Result<void>> refreshConversations() async {
    refreshConversationsCalls++;
    await gate?.future;
    final next = refreshedConversations;
    if (refreshConversationsResult is Ok<void> && next != null) {
      setConversations(next);
    }
    return refreshConversationsResult;
  }

  @override
  Future<Result<void>> markRead(String conversationId) async {
    markedRead.add(conversationId);
    return markReadResult;
  }

  @override
  Stream<List<Message>> watchMessages(String conversationId) {
    final messages = _watch(() => _messages[conversationId] ?? const []);
    return Stream.multi((watcher) {
      openWatchers.update(conversationId, (n) => n + 1, ifAbsent: () => 1);
      final subscription = messages.listen(watcher.add);
      watcher.onCancel = () {
        openWatchers.update(conversationId, (n) => n - 1);
        return subscription.cancel();
      };
    });
  }

  @override
  Future<Result<void>> refreshMessages(String conversationId) async {
    refreshMessagesCalls.add(conversationId);
    await gate?.future;
    final next = refreshedMessages[conversationId];
    if (refreshMessagesResult is Ok<void> && next != null) {
      setMessages(conversationId, next);
    }
    return refreshMessagesResult;
  }

  @override
  Stream<bool> watchTyping(String conversationId) =>
      _watch(() => _typing.contains(conversationId));

  @override
  Future<Result<void>> sendMessage(String conversationId, String text) async {
    sent.add((conversationId: conversationId, text: text));
    return sendResult;
  }

  @override
  Future<Result<void>> retryMessage(String messageId) async {
    retried.add(messageId);
    return retryResult;
  }

  void setConversations(List<Conversation> conversations) {
    _conversations = conversations;
    _changes.add(null);
  }

  void setMessages(String conversationId, List<Message> messages) {
    _messages[conversationId] = messages;
    _changes.add(null);
  }

  void setTyping(String conversationId, {required bool typing}) {
    typing ? _typing.add(conversationId) : _typing.remove(conversationId);
    _changes.add(null);
  }

  Stream<T> _watch<T>(T Function() read) => Stream.multi((watcher) {
    final subscription = _changes.stream.listen((_) => watcher.add(read()));
    watcher
      ..onCancel = subscription.cancel
      ..add(read());
  });

  Future<void> dispose() => _changes.close();
}
