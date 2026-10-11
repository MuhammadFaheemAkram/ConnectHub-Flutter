import 'dart:async';

import 'package:clock/clock.dart';
import 'package:connect_hub/core/common/app_exception.dart';
import 'package:connect_hub/core/common/id_generator.dart';
import 'package:connect_hub/core/common/result.dart';
import 'package:connect_hub/core/database/app_database.dart';
import 'package:connect_hub/core/database/daos/chat_dao.dart';
import 'package:connect_hub/core/database/tables/messages_table.dart';
import 'package:connect_hub/core/network/api/chat_api_service.dart';
import 'package:connect_hub/core/network/dto/chat_event_dto.dart';
import 'package:connect_hub/data/mapper/conversation_mappers.dart';
import 'package:connect_hub/data/mapper/message_mappers.dart';
import 'package:connect_hub/data/repository/api_guard.dart';
import 'package:connect_hub/domain/model/conversation.dart';
import 'package:connect_hub/domain/model/message.dart';
import 'package:connect_hub/domain/model/session.dart';
import 'package:connect_hub/domain/model/session_state.dart';
import 'package:connect_hub/domain/repository/chat_repository.dart';
import 'package:connect_hub/domain/repository/session_repository.dart';
import 'package:injectable/injectable.dart';
import 'package:synchronized/synchronized.dart';

/// Chat: the cache in drift, refreshed through the API, and kept current by
/// the realtime channel.
///
/// - **Sends** show at once ("Sending…"), then go out one at a time, in
///   order, with ids the client generated (see [sendMessage]).
/// - **The realtime channel** opens on first use and belongs to the session
///   that opened it: it closes when that session ends, and an event that
///   arrives for an ended session is dropped.
/// - **Typing** is a map of conversations with a reply on the way, driven by
///   the channel's events.
/// - **Unread:** a conversation on screen is read at once, including the
///   replies that arrive while it is open (Correctness Rule 9).
@LazySingleton(as: ChatRepository)
class ChatRepositoryImpl implements ChatRepository {
  ChatRepositoryImpl(
    this._api,
    this._chat,
    this._sessions,
    this._guard,
    this._ids,
    this._clock,
  ) {
    _sessionSubscription = _sessions.watchSession().listen((state) {
      if (state is SignedOut) _closeChannel();
    });
  }

  final ChatApiService _api;
  final ChatDao _chat;
  final SessionRepository _sessions;
  final ApiGuard _guard;
  final IdGenerator _ids;
  final Clock _clock;

  late final StreamSubscription<SessionState> _sessionSubscription;

  /// Sends go out one at a time, in the order they were made.
  final _sendLock = Lock();

  /// The realtime channel, while open, and the session it belongs to.
  StreamSubscription<void>? _channel;
  Session? _channelSession;

  /// Conversations whose other person is typing.
  final _typing = <String>{};
  final _typingChanges = StreamController<void>.broadcast(sync: true);

  /// Conversations on screen: how many watchers each one's messages have.
  final _open = <String, int>{};

  // ---------------------------------------------------------------------------
  // Conversations

  @override
  Stream<List<Conversation>> watchConversations() => _chat
      .watchConversations()
      .map((entries) => [for (final entry in entries) entry.toDomain()]);

  @override
  Stream<Conversation?> watchConversation(String conversationId) =>
      _chat.watchConversation(conversationId).map((entry) => entry?.toDomain());

  @override
  Stream<int> watchUnreadMessageCount() => _chat.watchUnreadCount();

  @override
  Future<Result<void>> refreshConversations() async {
    _openChannel();
    final result = await _guard.run(_api.getConversations);
    switch (result) {
      case Ok(value: final conversations):
        await _chat.replaceConversations([
          for (final conversation in conversations)
            _readIfOpen(conversation.toCached()),
        ]);
        return const Ok(null);
      case Err(:final exception):
        return Err(exception);
    }
  }

  @override
  Future<Result<void>> markRead(String conversationId) async {
    // The count drops at once. Even at zero here, the server is told: the
    // cache may be behind it.
    final before = await _chat.setUnreadCount(conversationId, 0);
    final result = await _guard.run(() => _api.markRead(conversationId));
    if (result case Err(:final exception)) {
      if (before != null) await _chat.setUnreadCount(conversationId, before);
      return Err(exception);
    }
    return const Ok(null);
  }

  // ---------------------------------------------------------------------------
  // Messages

  /// While someone watches a conversation's messages (its screen is open),
  /// the conversation counts as open: see [_onEvent].
  @override
  Stream<List<Message>> watchMessages(String conversationId) {
    return Stream.multi((watcher) {
      _open.update(conversationId, (count) => count + 1, ifAbsent: () => 1);
      final subscription = _chat.watchMessages(conversationId).listen((rows) {
        final me = _sessions.currentSession?.userId;
        watcher.add([for (final row in rows) row.toDomain(signedInUserId: me)]);
      }, onError: watcher.addError);
      watcher.onCancel = () {
        final left = (_open[conversationId] ?? 1) - 1;
        if (left > 0) {
          _open[conversationId] = left;
        } else {
          _open.remove(conversationId);
        }
        return subscription.cancel();
      };
    });
  }

  @override
  Future<Result<void>> refreshMessages(String conversationId) async {
    _openChannel();
    final result = await _guard.run(() => _api.getMessages(conversationId));
    switch (result) {
      case Ok(value: final messages):
        // A message row needs its conversation (a foreign key), and a deep
        // link can open a chat that isn't cached yet: fetch it first.
        if (!await _chat.isCached(conversationId)) {
          final conversations = await refreshConversations();
          if (conversations case Err(:final exception)) return Err(exception);
        }
        await _chat.replaceMessages(conversationId, [
          for (final message in messages) message.toRow(),
        ]);
        return const Ok(null);
      case Err(:final exception):
        return Err(exception);
    }
  }

  @override
  Stream<bool> watchTyping(String conversationId) {
    return Stream<bool>.multi((watcher) {
      _openChannel();
      watcher.add(_typing.contains(conversationId));
      final subscription = _typingChanges.stream.listen(
        (_) => watcher.add(_typing.contains(conversationId)),
      );
      watcher.onCancel = subscription.cancel;
    }).distinct();
  }

  /// The local row is written at once, so the screen shows "Sending…". The
  /// network part then runs one message at a time, like messages through a
  /// Swift actor's mailbox. Dart has no data races, but every `await` lets
  /// other code run, so two sends could still reach the server out of order
  /// without the lock.
  ///
  /// The id is made here, on the client, and the server keeps it. If a send
  /// is retried (the answer was lost, say), the server recognizes the id and
  /// returns the message it already has: a retry can't post it twice.
  @override
  Future<Result<void>> sendMessage(String conversationId, String text) async {
    final me = _sessions.currentSession?.userId;
    if (me == null) return const Err(UnauthorizedException());
    final id = _ids.next('m');
    await _chat.insertPending(
      MessageRow(
        id: id,
        conversationId: conversationId,
        senderId: me,
        content: text,
        createdAt: _clock.now().toUtc(),
        status: MessageRowStatus.sending,
      ),
    );
    _openChannel();
    return _sendLock.synchronized(() => _deliver(id));
  }

  /// Sends a failed message again, with the same id, in line with any other
  /// message being sent.
  @override
  Future<Result<void>> retryMessage(String messageId) async {
    if (!await _chat.markSending(messageId)) return const Ok(null);
    return _sendLock.synchronized(() => _deliver(messageId));
  }

  /// Sends one message (under the lock): `sent` with the server's time, or
  /// `failed`.
  Future<Result<void>> _deliver(String messageId) async {
    final message = await _chat.findMessage(messageId);
    // Wiped by a logout meanwhile, or already delivered: nothing to send.
    if (message == null || message.status != MessageRowStatus.sending) {
      return const Ok(null);
    }
    final result = await _guard.run(
      () => _api.sendMessage(
        message.conversationId,
        clientId: message.id,
        text: message.content,
      ),
    );
    switch (result) {
      case Ok(value: final sent):
        await _chat.confirmSent(sent.toRow());
        return const Ok(null);
      case Err(:final exception):
        await _chat.markFailed(messageId);
        return Err(exception);
    }
  }

  // ---------------------------------------------------------------------------
  // The realtime channel

  /// Opens the channel for the current session, unless it is already open
  /// for it.
  void _openChannel() {
    final session = _sessions.currentSession;
    if (session == null || (_channel != null && _channelSession == session)) {
      return;
    }
    _closeChannel();
    _channelSession = session;
    // asyncMap handles one event at a time, in order: "typing stopped"
    // waits until the reply before it is in the cache.
    _channel = _api
        .events()
        .asyncMap((event) => _onEvent(event, session))
        .listen(
          null,
          // Offline, or a 401: the channel closes; the next use reopens it.
          onError: (Object error) => _closeChannel(),
          onDone: _closeChannel,
          cancelOnError: true,
        );
  }

  void _closeChannel() {
    unawaited(_channel?.cancel());
    _channel = null;
    _channelSession = null;
    if (_typing.isNotEmpty) {
      _typing.clear();
      _typingChanges.add(null);
    }
  }

  Future<void> _onEvent(ChatEventDto event, Session session) async {
    // The session it was opened for has ended: the event belongs to a user
    // who is gone, and must not reach the cache.
    if (_sessions.currentSession != session) {
      _closeChannel();
      return;
    }
    switch (event) {
      case TypingStartedEvent(:final conversationId):
        if (_typing.add(conversationId)) _typingChanges.add(null);
      case TypingStoppedEvent(:final conversationId):
        if (_typing.remove(conversationId)) _typingChanges.add(null);
      case MessageReceivedEvent(:final message, :final conversation):
        await _chat.addIncoming(
          message: message.toRow(),
          conversation: _readIfOpen(conversation.toCached()),
        );
        // On screen, the reply is read the moment it arrives. Tell the
        // server too, or the next refresh would bring the count back.
        if (_open.containsKey(conversation.id)) {
          unawaited(_guard.run(() => _api.markRead(conversation.id)));
        }
    }
  }

  /// A conversation on screen has nothing unread, whatever the server's
  /// latest count says.
  CachedConversation _readIfOpen(CachedConversation entry) {
    if (!_open.containsKey(entry.conversation.id)) return entry;
    return (
      conversation: entry.conversation.copyWith(unreadCount: 0),
      participant: entry.participant,
    );
  }

  /// Closes the channel and the session subscription (for tests: the app
  /// keeps one repository for its whole lifetime).
  Future<void> dispose() async {
    _closeChannel();
    await _sessionSubscription.cancel();
    await _typingChanges.close();
  }
}
