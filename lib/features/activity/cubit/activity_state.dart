import 'package:connect_hub/core/common/ui_message.dart';
import 'package:connect_hub/domain/model/app_notification.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'activity_state.freezed.dart';

/// The chips above the list.
enum ActivityFilter {
  all('All'),
  unread('Unread'),
  likes('Likes'),
  comments('Comments'),
  follows('Follows'),
  mentions('Mentions');

  const ActivityFilter(this.label);

  final String label;

  bool matches(AppNotification notification) => switch (this) {
    ActivityFilter.all => true,
    ActivityFilter.unread => !notification.isRead,
    ActivityFilter.likes => notification.kind == NotificationKind.like,
    ActivityFilter.comments => notification.kind == NotificationKind.comment,
    ActivityFilter.follows => notification.kind == NotificationKind.follow,
    ActivityFilter.mentions => notification.kind == NotificationKind.mention,
  };
}

/// Where the list stands. "Empty" is [loaded] with nothing to show.
enum ActivityStatus {
  /// Nothing cached yet, and the server hasn't answered.
  loading,

  /// Showing what's cached (possibly nothing).
  loaded,

  /// Nothing cached, and fetching failed.
  failure,
}

/// One class rather than a union: the filter outlives every status.
@freezed
abstract class ActivityState with _$ActivityState {
  const ActivityState._();

  const factory ActivityState({
    @Default(ActivityStatus.loading) ActivityStatus status,
    @Default(ActivityFilter.all) ActivityFilter filter,

    /// Every cached notification, newest first, whatever the filter.
    @Default(<AppNotification>[]) List<AppNotification> notifications,
    @Default('') String errorMessage,

    /// A one-time SnackBar.
    UiMessage? message,
  }) = _ActivityState;

  /// What the current filter shows.
  List<AppNotification> get visible => filter == ActivityFilter.all
      ? notifications
      : notifications.where(filter.matches).toList();

  /// Enables "Mark all read".
  bool get hasUnread =>
      notifications.any((notification) => !notification.isRead);
}
