import 'package:connect_hub/domain/model/app_notification.dart';
import 'package:connect_hub/domain/repository/notification_repository.dart';
import 'package:injectable/injectable.dart';

/// The cached notifications as a stream, newest first.
@injectable
class WatchNotificationsUseCase {
  const WatchNotificationsUseCase(this._notifications);

  final NotificationRepository _notifications;

  Stream<List<AppNotification>> call() => _notifications.watchNotifications();
}
