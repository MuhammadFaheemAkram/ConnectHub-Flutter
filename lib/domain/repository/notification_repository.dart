import 'package:connect_hub/core/common/result.dart';
import 'package:connect_hub/domain/model/app_notification.dart';

/// Activity notifications: owned by the server (read state included),
/// cached in drift.
abstract interface class NotificationRepository {
  /// The cached notifications, newest first: now, then after every change.
  Stream<List<AppNotification>> watchNotifications();

  /// How many are unread: the Activity tab's badge.
  Stream<int> watchUnreadCount();

  /// Makes the cache match the server, read states included.
  Future<Result<void>> refresh();

  /// Marks one read at once; rolled back if the server refuses.
  Future<Result<void>> markRead(String notificationId);

  /// Marks all read at once; rolled back if the server refuses.
  Future<Result<void>> markAllRead();
}
