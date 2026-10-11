import 'package:connect_hub/core/database/app_database.dart';
import 'package:connect_hub/core/database/daos/chat_dao.dart';
import 'package:connect_hub/core/database/tables/messages_table.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/backend.dart';
import '../../helpers/database_rows.dart';

void main() {
  late AppDatabase database;
  late ChatDao chat;

  setUp(() {
    database = newTestDatabase();
    chat = database.chatDao;
  });

  tearDown(() => database.close());

  Future<List<String>> conversationIds() async => [
    for (final entry in await chat.watchConversations().first)
      entry.conversation.id,
  ];

  Future<List<String>> messageIds([String conversationId = 'c1']) async => [
    for (final row in await chat.watchMessages(conversationId).first) row.id,
  ];

  Future<MessageRowStatus?> statusOf(String messageId) async =>
      (await chat.findMessage(messageId))?.status;

  group('conversations', () {
    test(
      'the most recent activity first, each with the other person',
      () async {
        await chat.replaceConversations([
          cachedConversation('c1', minutesAgo: 30),
          cachedConversation('c2', participantId: 'u_alan', minutesAgo: 5),
        ]);

        final conversations = await chat.watchConversations().first;
        expect(conversations.map((e) => e.conversation.id), ['c2', 'c1']);
        expect(conversations.first.participant.id, 'u_alan');
      },
    );

    test(
      'the unread total adds up every conversation, and is 0 with none',
      () async {
        expect(await chat.watchUnreadCount().first, 0);

        await chat.replaceConversations([
          cachedConversation('c1', unreadCount: 2),
          cachedConversation('c2', participantId: 'u_alan', unreadCount: 1),
        ]);

        expect(await chat.watchUnreadCount().first, 3);
      },
    );

    test('replace mirrors the server: upserts (renaming the other person) '
        'and deletes the conversations it no longer has, with their '
        'messages', () async {
      await chat.replaceConversations([
        cachedConversation('c1'),
        cachedConversation('c2', participantId: 'u_alan'),
      ]);
      await chat.replaceMessages('c2', [
        messageRow('m1', conversationId: 'c2'),
      ]);

      await chat.replaceConversations([
        cachedConversation('c1', participantName: 'Grace B. Hopper'),
      ]);

      expect(await conversationIds(), ['c1']);
      final c1 = await chat.watchConversation('c1').first;
      expect(c1!.participant.name, 'Grace B. Hopper');
      expect(await chat.findMessage('m1'), isNull);
    });

    test('setUnreadCount returns the count from before, or null when the '
        'conversation isn\'t cached', () async {
      await chat.replaceConversations([
        cachedConversation('c1', unreadCount: 2),
      ]);

      expect(await chat.setUnreadCount('c1', 0), 2);
      expect(await chat.watchUnreadCount().first, 0);
      expect(await chat.setUnreadCount('c404', 0), isNull);
    });
  });

  group('messages', () {
    setUp(() => chat.replaceConversations([cachedConversation('c1')]));

    test('delivered messages in time order, then the unsent ones in the '
        'order they were written', () async {
      await chat.replaceMessages('c1', [
        messageRow('m2', minutesAgo: 5),
        messageRow('m1', minutesAgo: 10),
      ]);
      // The device's clock says the first was written earlier than both:
      // it still comes after every delivered message.
      await chat.insertPending(
        messageRow('m3', status: MessageRowStatus.sending, minutesAgo: 20),
      );
      await chat.insertPending(
        messageRow('m4', status: MessageRowStatus.sending, minutesAgo: 30),
      );
      await chat.markFailed('m3');

      expect(await messageIds(), ['m1', 'm2', 'm3', 'm4']);
    });

    test("replace mirrors the server's delivered messages and keeps the "
        'unsent ones (Correctness Rule 7)', () async {
      await chat.replaceMessages('c1', [
        messageRow('m1', minutesAgo: 10),
        messageRow('m_gone', minutesAgo: 9),
      ]);
      await chat.insertPending(
        messageRow('m_sending', status: MessageRowStatus.sending),
      );
      await chat.insertPending(
        messageRow('m_failed', status: MessageRowStatus.sending),
      );
      await chat.markFailed('m_failed');

      await chat.replaceMessages('c1', [
        messageRow('m1', minutesAgo: 10),
        messageRow('m2', minutesAgo: 1),
      ]);

      expect(await messageIds(), ['m1', 'm2', 'm_sending', 'm_failed']);
    });

    test('a message the server already has while it is still sending here '
        'becomes sent, under the same id', () async {
      await chat.insertPending(
        messageRow('m_a', status: MessageRowStatus.sending),
      );

      await chat.replaceMessages('c1', [messageRow('m_a')]);

      expect(await statusOf('m_a'), MessageRowStatus.sent);
      expect(await messageIds(), ['m_a']);
    });

    test('nothing is written for a conversation that isn\'t cached (a '
        'logout meanwhile)', () async {
      await chat.insertPending(
        messageRow(
          'm_a',
          conversationId: 'c404',
          status: MessageRowStatus.sending,
        ),
      );
      await chat.replaceMessages('c404', [
        messageRow('m_b', conversationId: 'c404'),
      ]);

      expect(await chat.findMessage('m_a'), isNull);
      expect(await chat.findMessage('m_b'), isNull);
    });

    test("confirmSent takes the server's time, and makes the message the "
        "conversation's latest, unless a newer one already is", () async {
      await chat.insertPending(
        messageRow('m_a', status: MessageRowStatus.sending, minutesAgo: 1),
      );

      final accepted = messageRow('m_a', minutesAgo: -1);
      await chat.confirmSent(accepted);

      final row = await chat.findMessage('m_a');
      expect(row!.status, MessageRowStatus.sent);
      expect(row.createdAt, accepted.createdAt);
      var c1 = (await chat.watchConversation('c1').first)!.conversation;
      expect(c1.lastMessage, 'Message m_a');
      expect(c1.updatedAt, accepted.createdAt);

      // An older confirmation doesn't take the place of a newer message.
      await chat.insertPending(
        messageRow('m_b', status: MessageRowStatus.sending),
      );
      await chat.confirmSent(messageRow('m_b', minutesAgo: 10));
      c1 = (await chat.watchConversation('c1').first)!.conversation;
      expect(c1.lastMessage, 'Message m_a');
    });

    test('markSending puts only a failed message back to sending', () async {
      await chat.replaceMessages('c1', [messageRow('m_sent')]);
      await chat.insertPending(
        messageRow('m_a', status: MessageRowStatus.sending),
      );

      expect(await chat.markSending('m_a'), isFalse);
      expect(await chat.markSending('m_sent'), isFalse);
      await chat.markFailed('m_a');
      expect(await statusOf('m_a'), MessageRowStatus.failed);
      expect(await chat.markSending('m_a'), isTrue);
      expect(await statusOf('m_a'), MessageRowStatus.sending);
    });

    test('addIncoming caches the message with the conversation as it now '
        'stands, even one not cached before', () async {
      await chat.addIncoming(
        message: messageRow('m9', conversationId: 'c9', senderId: 'u_alan'),
        conversation: cachedConversation(
          'c9',
          participantId: 'u_alan',
          unreadCount: 1,
          lastMessage: 'Message m9',
        ),
      );

      expect(await messageIds('c9'), ['m9']);
      final c9 = await chat.watchConversation('c9').first;
      expect(c9!.conversation.unreadCount, 1);
      expect(c9.participant.id, 'u_alan');
    });
  });
}
