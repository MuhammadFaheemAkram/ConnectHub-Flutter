import 'dart:async';

import 'package:connect_hub/domain/usecase/get_settings_use_case.dart';
import 'package:connect_hub/domain/usecase/refresh_conversations_use_case.dart';
import 'package:connect_hub/domain/usecase/refresh_notifications_use_case.dart';
import 'package:connect_hub/domain/usecase/watch_cache_cleared_use_case.dart';
import 'package:connect_hub/domain/usecase/watch_settings_use_case.dart';
import 'package:connect_hub/domain/usecase/watch_unread_message_count_use_case.dart';
import 'package:connect_hub/domain/usecase/watch_unread_notification_count_use_case.dart';
import 'package:connect_hub/features/shell/cubit/badges_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

/// Drives the unread badges: the Activity tab's and the Feed's Chats button.
///
/// It lives in the tab shell, which exists only while signed in, so it
/// belongs to the session: a new sign-in gets a new one. On creation it
/// fetches notifications and conversations once (which also opens the chat's
/// realtime channel), then follows the cached counts and the badges setting.
/// A failed fetch stays quiet: the badges keep the cached counts, and the
/// screens that own the data report their own errors.
@injectable
class BadgesCubit extends Cubit<BadgesState> {
  BadgesCubit(
    GetSettingsUseCase getSettings,
    WatchSettingsUseCase watchSettings,
    WatchUnreadNotificationCountUseCase watchUnreadNotifications,
    WatchUnreadMessageCountUseCase watchUnreadMessages,
    this._refreshNotifications,
    this._refreshConversations,
    WatchCacheClearedUseCase watchCacheCleared,
  ) : super(BadgesState(enabled: getSettings().notificationsEnabled)) {
    _subscriptions = [
      watchSettings().listen(
        (settings) => _update(enabled: settings.notificationsEnabled),
      ),
      watchUnreadNotifications().listen(
        (count) => _update(unreadNotifications: count),
      ),
      watchUnreadMessages().listen((count) => _update(unreadMessages: count)),
      // The counts were cleared with the cache: fetch them again.
      watchCacheCleared().listen((_) => load()),
    ];
  }

  final RefreshNotificationsUseCase _refreshNotifications;
  final RefreshConversationsUseCase _refreshConversations;
  late final List<StreamSubscription<Object?>> _subscriptions;

  /// Fetches the latest counts from the server.
  Future<void> load() async {
    await (_refreshNotifications(), _refreshConversations()).wait;
  }

  void _update({bool? enabled, int? unreadNotifications, int? unreadMessages}) {
    if (isClosed) return;
    final next = state.copyWith(
      enabled: enabled ?? state.enabled,
      unreadNotifications: unreadNotifications ?? state.unreadNotifications,
      unreadMessages: unreadMessages ?? state.unreadMessages,
    );
    if (next != state) emit(next);
  }

  @override
  Future<void> close() async {
    for (final subscription in _subscriptions) {
      await subscription.cancel();
    }
    return super.close();
  }
}
