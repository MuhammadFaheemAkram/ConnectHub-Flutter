import 'package:connect_hub/core/common/result.dart';
import 'package:connect_hub/core/database/daos/notifications_dao.dart';
import 'package:connect_hub/core/network/api/notification_api_service.dart';
import 'package:connect_hub/data/mapper/notification_mappers.dart';
import 'package:connect_hub/data/repository/api_guard.dart';
import 'package:connect_hub/domain/model/app_notification.dart';
import 'package:connect_hub/domain/repository/notification_repository.dart';
import 'package:injectable/injectable.dart';

/// Notifications and their read state, which the server owns: a refresh
/// mirrors it (so it never resets what was read), and marking read is an
/// optimistic write the server confirms or the repository rolls back.
@LazySingleton(as: NotificationRepository)
class NotificationRepositoryImpl implements NotificationRepository {
  NotificationRepositoryImpl(this._api, this._notifications, this._guard);

  final NotificationApiService _api;
  final NotificationsDao _notifications;
  final ApiGuard _guard;

  @override
  Stream<List<AppNotification>> watchNotifications() => _notifications
      .watchNotifications()
      .map((rows) => [for (final row in rows) row.toDomain()]);

  @override
  Stream<int> watchUnreadCount() => _notifications.watchUnreadCount();

  @override
  Future<Result<void>> refresh() async {
    final result = await _guard.run(_api.getNotifications);
    switch (result) {
      case Ok(value: final notifications):
        await _notifications.replaceNotifications([
          for (final notification in notifications) notification.toRow(),
        ]);
        return const Ok(null);
      case Err(:final exception):
        return Err(exception);
    }
  }

  @override
  Future<Result<void>> markRead(String notificationId) async {
    final before = await _notifications.setRead(notificationId, isRead: true);
    // Already read: nothing to tell the server.
    if (before ?? false) return const Ok(null);
    final result = await _guard.run(() => _api.markRead(notificationId));
    if (result case Err(:final exception)) {
      if (before != null) {
        await _notifications.setRead(notificationId, isRead: before);
      }
      return Err(exception);
    }
    return const Ok(null);
  }

  @override
  Future<Result<void>> markAllRead() async {
    final wereUnread = await _notifications.markAllRead();
    if (wereUnread.isEmpty) return const Ok(null);
    final result = await _guard.run(_api.markAllRead);
    if (result case Err(:final exception)) {
      await _notifications.markUnread(wereUnread);
      return Err(exception);
    }
    return const Ok(null);
  }
}
