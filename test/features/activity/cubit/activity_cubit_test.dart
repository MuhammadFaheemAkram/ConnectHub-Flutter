import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:connect_hub/core/common/app_exception.dart';
import 'package:connect_hub/core/common/result.dart';
import 'package:connect_hub/core/common/ui_message.dart';
import 'package:connect_hub/domain/model/app_notification.dart';
import 'package:connect_hub/domain/usecase/mark_all_notifications_read_use_case.dart';
import 'package:connect_hub/domain/usecase/mark_notification_read_use_case.dart';
import 'package:connect_hub/domain/usecase/refresh_notifications_use_case.dart';
import 'package:connect_hub/domain/usecase/watch_cache_cleared_use_case.dart';
import 'package:connect_hub/domain/usecase/watch_notifications_use_case.dart';
import 'package:connect_hub/features/activity/cubit/activity_cubit.dart';
import 'package:connect_hub/features/activity/cubit/activity_state.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fakes/fake_cache_repository.dart';
import '../../../helpers/fakes/fake_notification_repository.dart';
import '../../../helpers/fixtures.dart';

void main() {
  late FakeNotificationRepository notifications;
  late FakeCacheRepository cache;

  final like = sampleNotification('n1', postId: 'p1');
  final comment = sampleNotification(
    'n2',
    kind: NotificationKind.comment,
    minutesAgo: 5,
  );
  final follow = sampleNotification(
    'n3',
    kind: NotificationKind.follow,
    isRead: true,
    userId: 'u_ada',
    minutesAgo: 10,
  );
  final mention = sampleNotification(
    'n4',
    kind: NotificationKind.mention,
    isRead: true,
    minutesAgo: 20,
  );
  final all = [like, comment, follow, mention];
  final networkError = const NetworkException().message;

  setUp(() {
    notifications = FakeNotificationRepository();
    cache = FakeCacheRepository();
  });

  tearDown(() async {
    await notifications.dispose();
    await cache.dispose();
  });

  ActivityCubit buildCubit() => ActivityCubit(
    WatchNotificationsUseCase(notifications),
    RefreshNotificationsUseCase(notifications),
    MarkNotificationReadUseCase(notifications),
    MarkAllNotificationsReadUseCase(notifications),
    WatchCacheClearedUseCase(cache),
  );

  ActivityState loaded(
    List<AppNotification> list, {
    ActivityFilter filter = ActivityFilter.all,
    UiMessage? message,
  }) => ActivityState(
    status: ActivityStatus.loaded,
    notifications: list,
    filter: filter,
    message: message,
  );

  group('loading', () {
    blocTest<ActivityCubit, ActivityState>(
      'cached notifications show at once, before the server answers',
      setUp: () =>
          notifications = FakeNotificationRepository(cached: all)
            ..gate = Completer<void>(),
      build: buildCubit,
      act: (cubit) => unawaited(cubit.load()),
      expect: () => [loaded(all)],
    );

    blocTest<ActivityCubit, ActivityState>(
      'nothing cached: loading, then what the server has',
      setUp: () => notifications.refreshed = all,
      build: buildCubit,
      act: (cubit) => cubit.load(),
      expect: () => [loaded(all)],
    );

    blocTest<ActivityCubit, ActivityState>(
      'no notifications at all: loaded with none (the empty state)',
      build: buildCubit,
      act: (cubit) => cubit.load(),
      expect: () => [loaded(const [])],
    );

    blocTest<ActivityCubit, ActivityState>(
      'nothing cached and the refresh fails: the error; Try again loads',
      setUp: () => notifications.refreshResult = const Err(NetworkException()),
      build: buildCubit,
      act: (cubit) async {
        await cubit.load();
        notifications
          ..refreshResult = const Ok(null)
          ..refreshed = all;
        await cubit.load();
      },
      expect: () => [
        ActivityState(
          status: ActivityStatus.failure,
          errorMessage: networkError,
        ),
        const ActivityState(),
        loaded(all),
      ],
    );

    blocTest<ActivityCubit, ActivityState>(
      'cached notifications stay when the refresh fails, and a message '
      'says so',
      setUp: () =>
          notifications = FakeNotificationRepository(cached: all)
            ..refreshResult = const Err(NetworkException()),
      build: buildCubit,
      act: (cubit) => cubit.load(),
      expect: () => [
        loaded(all),
        loaded(
          all,
          message: const UiMessage(
            id: 1,
            text: ActivityCubit.refreshFailedMessage,
          ),
        ),
      ],
    );

    blocTest<ActivityCubit, ActivityState>(
      'after "Clear cache", it loads again: a spinner, never "No activity '
      'yet"',
      setUp: () =>
          notifications = FakeNotificationRepository(cached: all)
            ..refreshed = all,
      build: buildCubit,
      act: (cubit) async {
        await cubit.load();
        // The cache is wiped, and the screens hear it before drift reports
        // the emptied table. The refresh that follows takes a moment.
        notifications.gate = Completer<void>();
        await cache.clearCache();
        notifications.replace(const []);
        await pumpEventQueue();
        notifications.gate!.complete();
        await pumpEventQueue();
      },
      expect: () => [loaded(all), const ActivityState(), loaded(all)],
    );
  });

  group('filters', () {
    late ActivityCubit cubit;

    setUp(() async {
      notifications = FakeNotificationRepository(cached: all);
      cubit = buildCubit();
      await cubit.load();
    });

    tearDown(() => cubit.close());

    test('each chip shows its kind; Unread shows the unread', () {
      List<String> visibleWith(ActivityFilter filter) {
        cubit.selectFilter(filter);
        return [for (final n in cubit.state.visible) n.id];
      }

      expect(visibleWith(ActivityFilter.all), ['n1', 'n2', 'n3', 'n4']);
      expect(visibleWith(ActivityFilter.unread), ['n1', 'n2']);
      expect(visibleWith(ActivityFilter.likes), ['n1']);
      expect(visibleWith(ActivityFilter.comments), ['n2']);
      expect(visibleWith(ActivityFilter.follows), ['n3']);
      expect(visibleWith(ActivityFilter.mentions), ['n4']);
    });

    test('a read notification leaves the Unread filter', () async {
      cubit.selectFilter(ActivityFilter.unread);

      await cubit.markRead(like);
      await pumpEventQueue();

      expect(cubit.state.visible.map((n) => n.id), ['n2']);
      expect(cubit.state.hasUnread, isTrue);
    });
  });

  group('marking read', () {
    blocTest<ActivityCubit, ActivityState>(
      'a tapped row is marked read; an already read one sends nothing',
      setUp: () => notifications = FakeNotificationRepository(cached: all),
      build: buildCubit,
      act: (cubit) async {
        await cubit.markRead(like);
        await cubit.markRead(follow);
      },
      verify: (_) => expect(notifications.markReadCalls, ['n1']),
    );

    blocTest<ActivityCubit, ActivityState>(
      'a failure is rolled back (by the repository) and reported',
      setUp: () =>
          notifications = FakeNotificationRepository(cached: all)
            ..markReadResult = const Err(NetworkException()),
      build: buildCubit,
      seed: () => loaded(all),
      act: (cubit) => cubit.markRead(like),
      expect: () => [
        loaded(
          all,
          message: const UiMessage(
            id: 1,
            text: ActivityCubit.markReadFailedMessage,
          ),
        ),
      ],
    );

    blocTest<ActivityCubit, ActivityState>(
      'Mark all read reads everything; nothing unread is left',
      setUp: () => notifications = FakeNotificationRepository(cached: all),
      build: buildCubit,
      act: (cubit) async {
        await cubit.markAllRead();
        await pumpEventQueue();
      },
      verify: (cubit) {
        expect(notifications.markAllReadCalls, 1);
        expect(cubit.state.hasUnread, isFalse);
      },
    );

    blocTest<ActivityCubit, ActivityState>(
      'a failed Mark all read is reported',
      setUp: () =>
          notifications = FakeNotificationRepository(cached: all)
            ..markAllReadResult = const Err(NetworkException()),
      build: buildCubit,
      act: (cubit) async {
        await cubit.markAllRead();
        await pumpEventQueue();
      },
      verify: (cubit) {
        expect(
          cubit.state.message?.text,
          ActivityCubit.markAllReadFailedMessage,
        );
        expect(cubit.state.hasUnread, isTrue);
      },
    );
  });
}
