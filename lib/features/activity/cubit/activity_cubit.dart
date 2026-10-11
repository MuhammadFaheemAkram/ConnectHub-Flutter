import 'dart:async';

import 'package:connect_hub/core/common/first_value.dart';
import 'package:connect_hub/core/common/result.dart';
import 'package:connect_hub/core/common/ui_message.dart';
import 'package:connect_hub/domain/model/app_notification.dart';
import 'package:connect_hub/domain/usecase/mark_all_notifications_read_use_case.dart';
import 'package:connect_hub/domain/usecase/mark_notification_read_use_case.dart';
import 'package:connect_hub/domain/usecase/refresh_notifications_use_case.dart';
import 'package:connect_hub/domain/usecase/watch_cache_cleared_use_case.dart';
import 'package:connect_hub/domain/usecase/watch_notifications_use_case.dart';
import 'package:connect_hub/features/activity/cubit/activity_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

/// Drives the Activity tab: the notifications cached in drift, refreshed
/// from the server, filtered by the chips.
///
/// The read state belongs to the server (Correctness Rule 10): marking read
/// is an optimistic write in the repository, which rolls it back when the
/// server refuses, and a refresh brings back what the server has.
@injectable
class ActivityCubit extends Cubit<ActivityState> {
  ActivityCubit(
    this._watchNotifications,
    this._refreshNotifications,
    this._markRead,
    this._markAllRead,
    WatchCacheClearedUseCase watchCacheCleared,
  ) : super(const ActivityState()) {
    _subscription = _watchNotifications().listen(_onNotifications);
    // "Clear cache" emptied the list: load it again rather than show
    // "No activity yet".
    _cacheCleared = watchCacheCleared().listen((_) => load());
  }

  final WatchNotificationsUseCase _watchNotifications;
  final RefreshNotificationsUseCase _refreshNotifications;
  final MarkNotificationReadUseCase _markRead;
  final MarkAllNotificationsReadUseCase _markAllRead;

  late final StreamSubscription<List<AppNotification>> _subscription;
  late final StreamSubscription<void> _cacheCleared;

  static const refreshFailedMessage =
      "Couldn't refresh. Showing saved activity.";
  static const markReadFailedMessage =
      "Couldn't mark it as read. Please try again.";
  static const markAllReadFailedMessage =
      "Couldn't mark everything as read. Please try again.";

  /// The cached notifications as drift last reported them; `null` until it
  /// answers.
  List<AppNotification>? _notifications;
  ActivityFilter _filter = ActivityFilter.all;
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

  void selectFilter(ActivityFilter filter) {
    _filter = filter;
    _emitState();
  }

  /// A tapped row is read. (The View opens its link at the same time.)
  Future<void> markRead(AppNotification notification) async {
    if (notification.isRead) return;
    final result = await _markRead(notification.id);
    if (result is Err<void>) _show(markReadFailedMessage);
  }

  Future<void> markAllRead() async {
    final result = await _markAllRead();
    if (result is Err<void>) _show(markAllReadFailedMessage);
  }

  Future<void> _runRefresh() async {
    final result = await _refreshNotifications();
    if (isClosed) return;
    switch (result) {
      case Ok():
        // Decide on the list as cached *now*: drift reports the refresh's
        // writes a moment later (conventions §11.3). The outcome is
        // recorded after the read (§11.33).
        _notifications = await _watchNotifications().firstValue;
        if (isClosed) return;
        _refresh = _Refresh.succeeded;
      case Err(:final exception):
        // A fast failure can beat drift's first read: check what is cached
        // now, so saved notifications stay and the screen says why
        // (Correctness Rule 6).
        _notifications = await _watchNotifications().firstValue;
        if (isClosed) return;
        _refresh = _Refresh.failed;
        _refreshError = exception.message;
        if (_notifications!.isNotEmpty) {
          _message = _nextMessage(refreshFailedMessage);
        }
    }
    _emitState();
  }

  void _onNotifications(List<AppNotification> notifications) {
    _notifications = notifications;
    _emitState();
  }

  void _show(String text) {
    _message = _nextMessage(text);
    _emitState();
  }

  UiMessage _nextMessage(String text) =>
      UiMessage(id: ++_messageCount, text: text);

  void _emitState() {
    if (isClosed) return;
    final notifications = _notifications;
    final status = switch (notifications) {
      null => ActivityStatus.loading,
      [] => switch (_refresh) {
        _Refresh.pending => ActivityStatus.loading,
        _Refresh.succeeded => ActivityStatus.loaded,
        _Refresh.failed => ActivityStatus.failure,
      },
      _ => ActivityStatus.loaded,
    };
    final next = ActivityState(
      status: status,
      filter: _filter,
      notifications: notifications ?? const [],
      errorMessage: status == ActivityStatus.failure ? _refreshError : '',
      message: _message,
    );
    if (next != state) emit(next);
  }

  @override
  Future<void> close() async {
    await _subscription.cancel();
    await _cacheCleared.cancel();
    return super.close();
  }
}

/// What the latest refresh found.
enum _Refresh { pending, succeeded, failed }
