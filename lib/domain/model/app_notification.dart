import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_notification.freezed.dart';

/// What a notification is about.
enum NotificationKind { like, comment, follow, mention }

/// An activity notification. Tapping it opens [postId] or [userId] (at most
/// one is set), or nothing.
///
/// Named `AppNotification` because Flutter's widgets library already has a
/// `Notification` class.
@freezed
abstract class AppNotification with _$AppNotification {
  const factory AppNotification({
    required String id,
    required NotificationKind kind,
    required String text,
    required DateTime createdAt,
    required bool isRead,
    String? postId,
    String? userId,
  }) = _AppNotification;
}
