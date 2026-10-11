import 'dart:async';

import 'package:connect_hub/core/common/first_value.dart';
import 'package:connect_hub/core/common/result.dart';
import 'package:connect_hub/core/common/ui_message.dart';
import 'package:connect_hub/domain/model/conversation.dart';
import 'package:connect_hub/domain/usecase/refresh_conversations_use_case.dart';
import 'package:connect_hub/domain/usecase/watch_conversations_use_case.dart';
import 'package:connect_hub/features/chats/cubit/chats_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

/// Drives the Chats list: the conversations cached in drift, refreshed from
/// the server, filtered locally by the search field.
///
/// A Cubit, not a Bloc like Search: the filter runs on what is already on
/// screen, with no request to debounce or cancel, so a plain method is
/// enough. The list stays live: a reply arriving through the realtime
/// channel moves its conversation to the top.
@injectable
class ChatsCubit extends Cubit<ChatsState> {
  ChatsCubit(this._watchConversations, this._refreshConversations)
    : super(const ChatsState()) {
    _subscription = _watchConversations().listen(_onConversations);
  }

  final WatchConversationsUseCase _watchConversations;
  final RefreshConversationsUseCase _refreshConversations;

  late final StreamSubscription<List<Conversation>> _subscription;

  static const refreshFailedMessage = "Couldn't refresh. Showing saved chats.";

  /// The cached conversations as drift last reported them; `null` until it
  /// answers.
  List<Conversation>? _conversations;
  String _query = '';
  _Refresh _refresh = _Refresh.pending;
  String _refreshError = '';
  UiMessage? _message;
  int _messageCount = 0;

  /// The first load, and "Try again" after it failed.
  Future<void> load() async {
    _refresh = _Refresh.pending;
    _emitState();
    await _runRefresh();
  }

  /// Pull to refresh: the list stays on screen while it runs.
  Future<void> refresh() => _runRefresh();

  void search(String query) {
    _query = query;
    _emitState();
  }

  Future<void> _runRefresh() async {
    final result = await _refreshConversations();
    if (isClosed) return;
    switch (result) {
      case Ok():
        // Decide on the list as cached *now* (conventions §11.3), then
        // record the outcome (§11.33).
        _conversations = await _watchConversations().firstValue;
        if (isClosed) return;
        _refresh = _Refresh.succeeded;
      case Err(:final exception):
        _conversations = await _watchConversations().firstValue;
        if (isClosed) return;
        _refresh = _Refresh.failed;
        _refreshError = exception.message;
        if (_conversations!.isNotEmpty) {
          _message = UiMessage(id: ++_messageCount, text: refreshFailedMessage);
        }
    }
    _emitState();
  }

  void _onConversations(List<Conversation> conversations) {
    _conversations = conversations;
    _emitState();
  }

  void _emitState() {
    if (isClosed) return;
    final conversations = _conversations;
    final status = switch (conversations) {
      null => ChatsStatus.loading,
      [] => switch (_refresh) {
        _Refresh.pending => ChatsStatus.loading,
        _Refresh.succeeded => ChatsStatus.loaded,
        _Refresh.failed => ChatsStatus.failure,
      },
      _ => ChatsStatus.loaded,
    };
    final next = ChatsState(
      status: status,
      conversations: conversations ?? const [],
      query: _query,
      errorMessage: status == ChatsStatus.failure ? _refreshError : '',
      message: _message,
    );
    if (next != state) emit(next);
  }

  @override
  Future<void> close() async {
    await _subscription.cancel();
    return super.close();
  }
}

/// What the latest refresh found.
enum _Refresh { pending, succeeded, failed }
