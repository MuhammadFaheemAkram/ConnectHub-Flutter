import 'package:connect_hub/core/common/result.dart';
import 'package:connect_hub/domain/repository/notification_repository.dart';
import 'package:injectable/injectable.dart';

/// Marks every notification read (optimistic, rolled back on failure).
@injectable
class MarkAllNotificationsReadUseCase {
  const MarkAllNotificationsReadUseCase(this._notifications);

  final NotificationRepository _notifications;

  Future<Result<void>> call() => _notifications.markAllRead();
}
