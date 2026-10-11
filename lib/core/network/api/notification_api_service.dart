import 'package:connect_hub/core/network/dto/notification_dto.dart';

/// The activity endpoints, Retrofit-style. Every call is authenticated.
abstract interface class NotificationApiService {
  /// `GET /me/notifications`: newest first, each with its read state.
  Future<List<NotificationDto>> getNotifications();

  /// `POST /me/notifications/{id}/read`
  Future<void> markRead(String notificationId);

  /// `POST /me/notifications/read`
  Future<void> markAllRead();
}
