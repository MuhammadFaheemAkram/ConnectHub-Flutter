import 'package:connect_hub/core/common/result.dart';
import 'package:connect_hub/domain/repository/notification_repository.dart';
import 'package:injectable/injectable.dart';

/// Fetches the server's notifications into the cache.
@injectable
class RefreshNotificationsUseCase {
  const RefreshNotificationsUseCase(this._notifications);

  final NotificationRepository _notifications;

  Future<Result<void>> call() => _notifications.refresh();
}
