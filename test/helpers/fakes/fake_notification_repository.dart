import 'dart:async';

import 'package:connect_hub/core/common/result.dart';
import 'package:connect_hub/domain/model/app_notification.dart';
import 'package:connect_hub/domain/repository/notification_repository.dart';

/// A scriptable [NotificationRepository] for the Cubit tests.
///
/// Like drift, the watch methods emit the current value, then every change,
/// announced asynchronously (conventions §11.3). Marking read is optimistic
/// and rolled back on a scripted failure, like the real repository.
class FakeNotificationRepository implements NotificationRepository {
  FakeNotificationRepository({List<AppNotification> cached = const []})
    : _notifications = cached;

  List<AppNotification> _notifications;
  final _changes = StreamController<void>.broadcast();

  /// What a successful refresh leaves cached (`null`: unchanged).
  List<AppNotification>? refreshed;
  Result<void> refreshResult = const Ok(null);
  Result<void> markReadResult = const Ok(null);
  Result<void> markAllReadResult = const Ok(null);

  /// While set and not completed, refresh waits for it.
  Completer<void>? gate;

  int refreshCalls = 0;
  final markReadCalls = <String>[];
  int markAllReadCalls = 0;

  @override
  Stream<List<AppNotification>> watchNotifications() =>
      _watch(() => _notifications);

  @override
  Stream<int> watchUnreadCount() =>
      _watch(() => _notifications.where((n) => !n.isRead).length);

  @override
  Future<Result<void>> refresh() async {
    refreshCalls++;
    await gate?.future;
    final next = refreshed;
    if (refreshResult is Ok<void> && next != null) replace(next);
    return refreshResult;
  }

  @override
  Future<Result<void>> markRead(String notificationId) async {
    markReadCalls.add(notificationId);
    final before = _notifications;
    replace([
      for (final n in _notifications)
        n.id == notificationId ? n.copyWith(isRead: true) : n,
    ]);
    if (markReadResult is Err<void>) replace(before);
    return markReadResult;
  }

  @override
  Future<Result<void>> markAllRead() async {
    markAllReadCalls++;
    final before = _notifications;
    replace([for (final n in _notifications) n.copyWith(isRead: true)]);
    if (markAllReadResult is Err<void>) replace(before);
    return markAllReadResult;
  }

  /// Changes the cache as another screen (or the server) would.
  void replace(List<AppNotification> notifications) {
    _notifications = notifications;
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
