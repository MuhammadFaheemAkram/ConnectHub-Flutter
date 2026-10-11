import 'package:connect_hub/core/database/app_database.dart';
import 'package:connect_hub/core/database/daos/notifications_dao.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/backend.dart';
import '../../helpers/database_rows.dart';

void main() {
  late AppDatabase database;
  late NotificationsDao dao;

  setUp(() {
    database = newTestDatabase();
    dao = database.notificationsDao;
  });

  tearDown(() => database.close());

  Future<Map<String, bool>> readStates() async => {
    for (final row in await dao.watchNotifications().first) row.id: row.isRead,
  };

  test('newest first, and the unread count', () async {
    await dao.replaceNotifications([
      notificationRow('n2', minutesAgo: 10, isRead: true),
      notificationRow('n1', minutesAgo: 1),
      notificationRow('n3', minutesAgo: 20),
    ]);

    expect((await readStates()).keys, ['n1', 'n2', 'n3']);
    expect(await dao.watchUnreadCount().first, 2);
  });

  test('replace mirrors the server, read states included (Correctness Rule '
      '10): what it no longer has goes', () async {
    await dao.replaceNotifications([
      notificationRow('n1'),
      notificationRow('n2'),
    ]);

    await dao.replaceNotifications([notificationRow('n1', isRead: true)]);

    expect(await readStates(), {'n1': true});
  });

  test(
    'setRead returns the state from before, or null when not cached',
    () async {
      await dao.replaceNotifications([notificationRow('n1')]);

      expect(await dao.setRead('n1', isRead: true), isFalse);
      expect(await dao.setRead('n1', isRead: true), isTrue);
      expect(await dao.setRead('n404', isRead: true), isNull);
      expect(await dao.watchUnreadCount().first, 0);
    },
  );

  test('markAllRead returns the ids that were unread, and markUnread puts '
      'exactly those back', () async {
    await dao.replaceNotifications([
      notificationRow('n1'),
      notificationRow('n2', isRead: true),
      notificationRow('n3'),
    ]);

    final wereUnread = await dao.markAllRead();
    expect(wereUnread, unorderedEquals(['n1', 'n3']));
    expect(await dao.watchUnreadCount().first, 0);

    await dao.markUnread(wereUnread);
    expect(await readStates(), {'n1': false, 'n2': true, 'n3': false});
  });
}
