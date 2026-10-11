import 'package:connect_hub/core/database/app_database.dart';
import 'package:connect_hub/core/database/tables/messages_table.dart';
import 'package:drift/drift.dart' hide isNull;
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/backend.dart';
import '../../helpers/database_rows.dart';

void main() {
  late AppDatabase database;

  setUp(() => database = newTestDatabase());

  tearDown(() => database.close());

  test('clearAll leaves every table empty, recent searches included', () async {
    await database.feedDao.replaceFeed([
      cachedPost('p1', bookmarkedAt: testNow),
      cachedPost('p2', authorId: 'u_grace'),
    ]);
    await database.commentsDao.addComment(cachedComment('c1'));
    await database.searchDao.saveRecentSearch('ada', at: testNow);
    await database.chatDao.replaceConversations([cachedConversation('c1')]);
    await database.chatDao.replaceMessages('c1', [messageRow('m1')]);
    await database.notificationsDao.replaceNotifications([
      notificationRow('n1'),
    ]);

    await database.cacheDao.clearAll();

    // Every table, so one added by a later schema version without being
    // cleared here fails this test.
    for (final table in database.allTables) {
      final rows = await database.select(table).get();
      expect(rows, isEmpty, reason: table.actualTableName);
    }
  });

  group('clearServerData ("Clear cache")', () {
    Future<List<String>> idsOf(TableInfo<Table, dynamic> table) async {
      final rows = await database.select(table).get();
      return [for (final row in rows) (row as dynamic).id as String]..sort();
    }

    setUp(() async {
      // The feed: p1 (bookmarked, by Ada) and p2 (by Grace), with a comment
      // by Linus on p2.
      await database.feedDao.replaceFeed([
        cachedPost('p1', bookmarkedAt: testNow),
        cachedPost('p2', authorId: 'u_grace'),
      ]);
      await database.commentsDao.addComment(
        cachedComment('cm1', postId: 'p2', authorId: 'u_linus'),
      );
      // Me.
      await database.usersDao.upsertUser(userRow('u_demo'));
      // c1 with Katherine: delivered messages only. c2 with Alan: a
      // message still sending.
      await database.chatDao.replaceConversations([
        cachedConversation('c1', participantId: 'u_katherine'),
        cachedConversation('c2', participantId: 'u_alan'),
      ]);
      await database.chatDao.replaceMessages('c1', [
        messageRow('m1', senderId: 'u_katherine'),
      ]);
      await database.chatDao.replaceMessages('c2', [
        messageRow('m2', conversationId: 'c2', senderId: 'u_alan'),
      ]);
      await database.chatDao.insertPending(
        messageRow(
          'm3',
          conversationId: 'c2',
          senderId: 'u_demo',
          status: MessageRowStatus.sending,
        ),
      );
      await database.notificationsDao.replaceNotifications([
        notificationRow('n1'),
      ]);
      await database.searchDao.saveRecentSearch('ada', at: testNow);

      await database.cacheDao.clearServerData(keepUserId: 'u_demo');
    });

    test("deletes the server's data: the feed, comments, notifications, "
        'delivered messages and posts nobody bookmarked', () async {
      expect(await database.select(database.feedItems).get(), isEmpty);
      expect(await idsOf(database.comments), isEmpty);
      expect(await idsOf(database.notifications), isEmpty);
      expect(await idsOf(database.posts), ['p1']);
      expect(await idsOf(database.messages), ['m3']);
    });

    test(
      'keeps bookmarks (with their authors), me, unsent messages (with '
      'their conversations and the other person) and recent searches',
      () async {
        expect(await database.select(database.bookmarks).get(), hasLength(1));
        expect(await idsOf(database.conversations), ['c2']);
        expect(await idsOf(database.users), ['u_ada', 'u_alan', 'u_demo']);
        final searches = await database.searchDao.watchRecentSearches().first;
        expect(searches.map((search) => search.displayText), ['ada']);
      },
    );
  });
}
