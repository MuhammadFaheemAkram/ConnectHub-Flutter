import 'package:bloc_test/bloc_test.dart';
import 'package:connect_hub/domain/model/app_settings.dart';
import 'package:connect_hub/domain/usecase/get_settings_use_case.dart';
import 'package:connect_hub/domain/usecase/refresh_conversations_use_case.dart';
import 'package:connect_hub/domain/usecase/refresh_notifications_use_case.dart';
import 'package:connect_hub/domain/usecase/watch_cache_cleared_use_case.dart';
import 'package:connect_hub/domain/usecase/watch_settings_use_case.dart';
import 'package:connect_hub/domain/usecase/watch_unread_message_count_use_case.dart';
import 'package:connect_hub/domain/usecase/watch_unread_notification_count_use_case.dart';
import 'package:connect_hub/features/shell/cubit/badges_cubit.dart';
import 'package:connect_hub/features/shell/cubit/badges_state.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fakes/fake_cache_repository.dart';
import '../../../helpers/fakes/fake_chat_repository.dart';
import '../../../helpers/fakes/fake_notification_repository.dart';
import '../../../helpers/fakes/fake_settings_repository.dart';
import '../../../helpers/fixtures.dart';

void main() {
  late FakeSettingsRepository settings;
  late FakeNotificationRepository notifications;
  late FakeChatRepository chat;
  late FakeCacheRepository cache;

  setUp(() {
    settings = FakeSettingsRepository();
    notifications = FakeNotificationRepository();
    chat = FakeChatRepository();
    cache = FakeCacheRepository();
  });

  tearDown(() async {
    await settings.dispose();
    await notifications.dispose();
    await chat.dispose();
    await cache.dispose();
  });

  BadgesCubit buildCubit() => BadgesCubit(
    GetSettingsUseCase(settings),
    WatchSettingsUseCase(settings),
    WatchUnreadNotificationCountUseCase(notifications),
    WatchUnreadMessageCountUseCase(chat),
    RefreshNotificationsUseCase(notifications),
    RefreshConversationsUseCase(chat),
    WatchCacheClearedUseCase(cache),
  );

  void serverHasUnread({int notificationCount = 2, int messageCount = 3}) {
    notifications.refreshed = [
      for (var i = 0; i < notificationCount; i++) sampleNotification('n$i'),
      sampleNotification('read', isRead: true),
    ];
    chat.refreshedConversations = [
      sampleConversation('c1', unreadCount: messageCount),
      sampleConversation('c2', participant: alan),
    ];
  }

  blocTest<BadgesCubit, BadgesState>(
    'load fetches notifications and conversations once, and the badges '
    'show their unread counts',
    setUp: serverHasUnread,
    build: buildCubit,
    act: (cubit) => cubit.load(),
    verify: (cubit) {
      expect(notifications.refreshCalls, 1);
      expect(chat.refreshConversationsCalls, 1);
      expect(cubit.state.activity, 2);
      expect(cubit.state.chats, 3);
    },
  );

  blocTest<BadgesCubit, BadgesState>(
    'the counts follow the cache: reading lowers the badge',
    setUp: serverHasUnread,
    build: buildCubit,
    act: (cubit) async {
      await cubit.load();
      await notifications.markAllRead();
      await pumpEventQueue();
    },
    verify: (cubit) => expect(cubit.state.activity, 0),
  );

  test('badges turned off in Settings show nothing (from the first frame), '
      'and come back when turned on', () async {
    settings = FakeSettingsRepository(
      const AppSettings(notificationsEnabled: false),
    );
    serverHasUnread();
    final cubit = buildCubit();
    addTearDown(cubit.close);
    expect(cubit.state.enabled, isFalse);

    await cubit.load();
    await pumpEventQueue();
    expect(cubit.state.activity, 0);
    expect(cubit.state.chats, 0);
    expect(cubit.state.unreadNotifications, 2, reason: 'still counted');

    await settings.updateNotificationsEnabled(enabled: true);
    await pumpEventQueue();
    expect(cubit.state.activity, 2);
    expect(cubit.state.chats, 3);
  });

  blocTest<BadgesCubit, BadgesState>(
    'after "Clear cache", the counts are fetched again',
    build: buildCubit,
    act: (cubit) async {
      await cubit.load();
      await cache.clearCache();
      await pumpEventQueue();
    },
    verify: (_) {
      expect(notifications.refreshCalls, 2);
      expect(chat.refreshConversationsCalls, 2);
    },
  );
}
