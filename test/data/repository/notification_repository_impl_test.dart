import 'package:connect_hub/core/common/result.dart';
import 'package:connect_hub/data/repository/notification_repository_impl.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/data_stack.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late DataStack backend;
  NotificationRepositoryImpl notifications() => backend.notifications;

  setUp(() async {
    backend = DataStack();
    await notifications().refresh();
  });

  tearDown(() => backend.dispose());

  Future<Map<String, bool>> cachedReadStates() async => {
    for (final notification in await notifications().watchNotifications().first)
      notification.id: notification.isRead,
  };

  Future<bool> readOnServer(String id) async =>
      (await backend.server.getNotifications('u_demo'))
          .firstWhere((notification) => notification.id == id)
          .isRead;

  test('refresh caches the notifications newest first, with their links, '
      'and counts the unread', () async {
    final cached = await notifications().watchNotifications().first;

    expect(cached.map((n) => n.id), [
      'n1',
      'n2',
      'n3',
      'n4',
      'n5',
      'n6',
      'n7',
      'n8',
    ]);
    expect(cached.first.postId, 'p16');
    expect(cached[2].userId, 'u_katherine');
    expect(await notifications().watchUnreadCount().first, 3);
  });

  test('the read state is the server\'s: one read elsewhere is read after a '
      'refresh, and a refresh never resets one read here (Correctness Rule '
      '10)', () async {
    await backend.server.markNotificationRead('u_demo', 'n2');
    await notifications().markRead('n1');

    await notifications().refresh();

    final states = await cachedReadStates();
    expect(states['n1'], isTrue);
    expect(states['n2'], isTrue);
    expect(states['n3'], isFalse);
  });

  test('markRead is read at once, then confirmed by the server', () async {
    final marking = notifications().markRead('n1');
    await pumpEventQueue(times: 2);
    expect((await cachedReadStates())['n1'], isTrue);

    expect(await marking, isA<Ok<void>>());
    expect(await readOnServer('n1'), isTrue);
    expect(await notifications().watchUnreadCount().first, 2);
  });

  test(
    'a failed markRead puts it back to unread (Correctness Rule 4)',
    () async {
      backend.network.failRequests = true;

      expect(await notifications().markRead('n1'), isA<Err<void>>());

      expect((await cachedReadStates())['n1'], isFalse);
    },
  );

  test('marking one that is already read sends nothing', () async {
    backend.network.failRequests = true;

    expect(await notifications().markRead('n4'), isA<Ok<void>>());
  });

  test('markAllRead reads them all, here and on the server', () async {
    expect(await notifications().markAllRead(), isA<Ok<void>>());

    expect(await notifications().watchUnreadCount().first, 0);
    final onServer = await backend.server.getNotifications('u_demo');
    expect(onServer.every((notification) => notification.isRead), isTrue);
  });

  test(
    'a failed markAllRead puts back exactly the ones that were unread',
    () async {
      backend.network.failRequests = true;

      expect(await notifications().markAllRead(), isA<Err<void>>());

      final states = await cachedReadStates();
      expect(
        [
          for (final MapEntry(:key, :value) in states.entries)
            if (!value) key,
        ],
        ['n1', 'n2', 'n3'],
      );
    },
  );

  test('a failed refresh keeps what is cached', () async {
    backend.network.failRequests = true;

    expect(await notifications().refresh(), isA<Err<void>>());

    expect(await cachedReadStates(), hasLength(8));
  });
}
