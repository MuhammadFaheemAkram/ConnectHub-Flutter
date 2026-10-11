import 'package:freezed_annotation/freezed_annotation.dart';

part 'badges_state.freezed.dart';

/// The unread counts behind the shell's badges, and whether badges show.
@freezed
abstract class BadgesState with _$BadgesState {
  const BadgesState._();

  const factory BadgesState({
    /// Settings → "Show unread badges".
    @Default(true) bool enabled,
    @Default(0) int unreadNotifications,
    @Default(0) int unreadMessages,
  }) = _BadgesState;

  /// The Activity tab's badge; 0 hides it.
  int get activity => enabled ? unreadNotifications : 0;

  /// The Feed's Chats button's badge; 0 hides it.
  int get chats => enabled ? unreadMessages : 0;
}
