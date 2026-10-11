import 'package:connect_hub/domain/repository/notification_repository.dart';
import 'package:injectable/injectable.dart';

/// How many notifications are unread, as a stream: the Activity badge.
@injectable
class WatchUnreadNotificationCountUseCase {
  const WatchUnreadNotificationCountUseCase(this._notifications);

  final NotificationRepository _notifications;

  Stream<int> call() => _notifications.watchUnreadCount();
}
