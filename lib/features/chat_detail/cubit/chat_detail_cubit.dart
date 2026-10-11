import 'dart:async';

import 'package:connect_hub/core/common/app_exception.dart';
import 'package:connect_hub/core/common/first_value.dart';
import 'package:connect_hub/core/common/result.dart';
import 'package:connect_hub/core/common/ui_message.dart';
import 'package:connect_hub/domain/model/message.dart';
import 'package:connect_hub/domain/model/user.dart';
import 'package:connect_hub/domain/usecase/mark_conversation_read_use_case.dart';
import 'package:connect_hub/domain/usecase/refresh_messages_use_case.dart';
import 'package:connect_hub/domain/usecase/retry_message_use_case.dart';
import 'package:connect_hub/domain/usecase/send_message_use_case.dart';
import 'package:connect_hub/domain/usecase/watch_conversation_use_case.dart';
import 'package:connect_hub/domain/usecase/watch_messages_use_case.dart';
import 'package:connect_hub/domain/usecase/watch_typing_use_case.dart';
import 'package:connect_hub/features/chat_detail/cubit/chat_detail_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:stream_transform/stream_transform.dart';

/// Drives one chat: its messages from drift, the typing indicator, sending
/// and retrying.
///
/// It follows the cache: the conversation (for the title) and its messages,
/// combined into one value as in `ProfileCubit` (so the title never shows
/// with the messages not yet read), and the typing flag. Following the
/// messages is also what keeps the conversation *open* in the repository, so
/// a reply that arrives while this screen is up is read at once
/// (Correctness Rule 9).
///
/// Sending is fire-and-forget here: the repository shows the message at once
/// ("Sending…"), and its bubble reports the outcome ("Not sent · Tap to
/// retry"), so the screen needs no SnackBar or spinner for it.
@injectable
class ChatDetailCubit extends Cubit<ChatDetailState> {
  ChatDetailCubit(
    @factoryParam this.conversationId,
    this._watchConversation,
    this._watchMessages,
    WatchTypingUseCase watchTyping,
    this._refreshMessages,
    this._markRead,
    this._sendMessage,
    this._retryMessage,
  ) : super(const ChatDetailState()) {
    _subscriptions = [
      _cache().listen(_onCache),
      watchTyping(conversationId).listen(_onTyping),
    ];
  }

  final String conversationId;
  final WatchConversationUseCase _watchConversation;
  final WatchMessagesUseCase _watchMessages;
  final RefreshMessagesUseCase _refreshMessages;
  final MarkConversationReadUseCase _markRead;
  final SendMessageUseCase _sendMessage;
  final RetryMessageUseCase _retryMessage;

  late final List<StreamSubscription<Object?>> _subscriptions;

  static const refreshFailedMessage =
      "Couldn't refresh. Showing saved messages.";

  User? _participant;

  /// The cached messages as drift last reported them; `null` until it
  /// answers.
  List<Message>? _messages;
  bool _isTyping = false;
  _Refresh _refresh = _Refresh.pending;
  String _refreshError = '';
  UiMessage? _message;
  int _messageCount = 0;

  /// The first load, and "Try again" after it failed.
  ///
  /// Opening the chat reads it: the unread count drops at once, and the
  /// server is told. That runs beside the refresh. If it fails, the
  /// repository restores the count, so the badge stays truthful; the
  /// refresh's message reports the same failure, so it adds none of its own.
  Future<void> load() async {
    _refresh = _Refresh.pending;
    _emitState();
    unawaited(_markRead(conversationId));
    await _runRefresh();
  }

  /// Sends [text] (trimmed; blank text is ignored).
  Future<void> send(String text) async {
    await _sendMessage(conversationId, text);
  }

  /// "Not sent · Tap to retry".
  Future<void> retry(Message message) async {
    await _retryMessage(message.id);
  }

  Future<void> _runRefresh() async {
    final result = await _refreshMessages(conversationId);
    if (isClosed) return;
    switch (result) {
      case Ok():
        // Decide on what is cached *now*: drift reports the refresh's writes
        // a moment later (conventions §11.3). An empty chat that is about to
        // fill up must never flash "Say hello", so the outcome is recorded
        // only after the read (§11.33).
        _read(await _cache().firstValue);
        if (isClosed) return;
        _refresh = _Refresh.succeeded;
      case Err(exception: NotFoundException()):
        _refresh = _Refresh.notFound;
      case Err(:final exception):
        // A fast failure can beat drift's first read: check what is cached
        // now, so saved messages stay and the screen says why.
        _read(await _cache().firstValue);
        if (isClosed) return;
        _refresh = _Refresh.failed;
        _refreshError = exception.message;
        if (_messages!.isNotEmpty) {
          _message = UiMessage(id: ++_messageCount, text: refreshFailedMessage);
        }
    }
    _emitState();
  }

  /// The other person and the messages, as one value.
  Stream<_Cached> _cache() => _watchConversation(conversationId).combineLatest(
    _watchMessages(conversationId),
    (conversation, messages) =>
        (participant: conversation?.participant, messages: messages),
  );

  void _onCache(_Cached cached) {
    _read(cached);
    _emitState();
  }

  void _read(_Cached cached) {
    _participant = cached.participant;
    _messages = cached.messages;
  }

  void _onTyping(bool isTyping) {
    _isTyping = isTyping;
    _emitState();
  }

  void _emitState() {
    if (isClosed) return;
    final messages = _messages;
    final ChatStatus status;
    if (_refresh == _Refresh.notFound) {
      // The server's answer wins over anything still cached.
      status = ChatStatus.notFound;
    } else if (messages == null) {
      status = ChatStatus.loading;
    } else if (messages.isNotEmpty || _refresh == _Refresh.succeeded) {
      status = ChatStatus.ready;
    } else if (_refresh == _Refresh.failed) {
      status = ChatStatus.failure;
    } else {
      status = ChatStatus.loading;
    }
    final next = ChatDetailState(
      status: status,
      participant: _participant,
      messages: messages ?? const [],
      isTyping: _isTyping,
      errorMessage: status == ChatStatus.failure ? _refreshError : '',
      message: _message,
    );
    if (next != state) emit(next);
  }

  @override
  Future<void> close() async {
    for (final subscription in _subscriptions) {
      await subscription.cancel();
    }
    return super.close();
  }
}

typedef _Cached = ({User? participant, List<Message> messages});

/// What the latest refresh found.
enum _Refresh { pending, succeeded, notFound, failed }
