import 'package:connect_hub/core/database/app_database.dart';
import 'package:connect_hub/core/database/tables/notifications_table.dart';
import 'package:drift/drift.dart';

part 'notifications_dao.g.dart';

/// Cached notifications and their read state.
@DriftAccessor(tables: [Notifications])
class NotificationsDao extends DatabaseAccessor<AppDatabase>
    with _$NotificationsDaoMixin {
  NotificationsDao(super.attachedDatabase);

  /// The notifications, newest first (ties by id, like the server).
  Stream<List<NotificationRow>> watchNotifications() {
    final query = select(notifications)
      ..orderBy([
        (notification) => OrderingTerm.desc(notification.createdAt),
        (notification) => OrderingTerm.asc(notification.id),
      ]);
    return query.watch();
  }

  /// How many are unread: the Activity tab's badge.
  Stream<int> watchUnreadCount() {
    final count = notifications.id.count();
    final query = selectOnly(notifications)
      ..addColumns([count])
      ..where(notifications.isRead.equals(false));
    return query.map((row) => row.read(count) ?? 0).watchSingle();
  }

  /// Mirrors the server's notifications, read states included (Correctness
  /// Rules 1 and 10): a refresh never resets what was read.
  Future<void> replaceNotifications(List<NotificationRow> rows) {
    return batch((batch) {
      batch
        ..insertAllOnConflictUpdate(notifications, rows)
        ..deleteWhere(
          notifications,
          (notification) =>
              notification.id.isNotIn([for (final row in rows) row.id]),
        );
    });
  }

  /// Sets one notification's read state at once (an optimistic write).
  /// Returns the state from before, so a failed request can restore it, or
  /// `null` if it isn't cached.
  Future<bool?> setRead(String notificationId, {required bool isRead}) {
    return transaction(() async {
      final query = select(notifications)
        ..where((notification) => notification.id.equals(notificationId));
      final row = await query.getSingleOrNull();
      if (row == null) return null;
      await (update(notifications)
            ..where((notification) => notification.id.equals(notificationId)))
          .write(NotificationsCompanion(isRead: Value(isRead)));
      return row.isRead;
    });
  }

  /// Marks every notification read at once, and returns the ids that were
  /// unread, so a failed request can put exactly those back.
  Future<List<String>> markAllRead() {
    return transaction(() async {
      final query = select(notifications)
        ..where((notification) => notification.isRead.equals(false));
      final unread = await query.get();
      await (update(notifications)
            ..where((notification) => notification.isRead.equals(false)))
          .write(const NotificationsCompanion(isRead: Value(true)));
      return [for (final row in unread) row.id];
    });
  }

  /// Undoes [markAllRead] for [notificationIds].
  Future<void> markUnread(List<String> notificationIds) {
    final query = update(notifications)
      ..where((notification) => notification.id.isIn(notificationIds));
    return query.write(const NotificationsCompanion(isRead: Value(false)));
  }
}
