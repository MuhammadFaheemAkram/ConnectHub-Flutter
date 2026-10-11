import 'package:connect_hub/core/database/app_database.dart';
import 'package:connect_hub/core/database/tables/notifications_table.dart';
import 'package:connect_hub/core/network/dto/notification_dto.dart';
import 'package:connect_hub/domain/model/app_notification.dart';

extension NotificationDtoMapper on NotificationDto {
  NotificationRow toRow() => NotificationRow(
    id: id,
    kind: switch (kind) {
      NotificationKindDto.like => NotificationRowKind.like,
      NotificationKindDto.comment => NotificationRowKind.comment,
      NotificationKindDto.follow => NotificationRowKind.follow,
      NotificationKindDto.mention => NotificationRowKind.mention,
    },
    content: text,
    createdAt: createdAt.toUtc(),
    isRead: isRead,
    postId: postId,
    userId: userId,
  );
}

extension NotificationRowMapper on NotificationRow {
  AppNotification toDomain() => AppNotification(
    id: id,
    kind: switch (kind) {
      NotificationRowKind.like => NotificationKind.like,
      NotificationRowKind.comment => NotificationKind.comment,
      NotificationRowKind.follow => NotificationKind.follow,
      NotificationRowKind.mention => NotificationKind.mention,
    },
    text: content,
    createdAt: createdAt,
    isRead: isRead,
    postId: postId,
    userId: userId,
  );
}
