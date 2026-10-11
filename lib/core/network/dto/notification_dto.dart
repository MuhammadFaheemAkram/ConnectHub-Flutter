import 'package:json_annotation/json_annotation.dart';

part 'notification_dto.g.dart';

/// What a notification is about. The JSON uses these names as is.
enum NotificationKindDto { like, comment, follow, mention }

/// An activity notification. Its read state belongs to the server, so a
/// refresh never resets it (Correctness Rule 10).
///
/// [postId] or [userId] says what tapping it opens; some open nothing.
@JsonSerializable(createToJson: false, checked: true)
class NotificationDto {
  const NotificationDto({
    required this.id,
    required this.kind,
    required this.text,
    required this.createdAt,
    required this.isRead,
    this.postId,
    this.userId,
  });

  factory NotificationDto.fromJson(Map<String, dynamic> json) =>
      _$NotificationDtoFromJson(json);

  final String id;
  final NotificationKindDto kind;
  final String text;
  final DateTime createdAt;
  final bool isRead;
  final String? postId;
  final String? userId;
}
