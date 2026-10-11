import 'dart:async';

import 'package:connect_hub/core/common/app_exception.dart';
import 'package:connect_hub/core/common/result.dart';
import 'package:connect_hub/core/database/app_database.dart';
import 'package:connect_hub/core/database/tables/messages_table.dart';
import 'package:connect_hub/core/network/fake_server/fake_server.dart';
import 'package:connect_hub/core/network/fake_server/reply_scheduler.dart';
import 'package:connect_hub/data/repository/chat_repository_impl.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/backend.dart';
import '../../helpers/data_stack.dart';
import '../../helpers/fakes/gated_chat_api.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const bounded = Duration(seconds: 2);

  late DataStack backend;
  ChatRepositoryImpl chat() => backend.chat;

  setUp(() => backend = DataStack(replies: quickReplies()));
  tearDown(() => backend.dispose());

  /// The cached messages, read straight from the DAO: reading them through
  /// the repository would open the conversation (and so read it).
  Future<List<MessageRow>> cachedMessages(String conversationId) =>
      backend.database.chatDao.watchMessages(conversationId).first;

  /// Waits, bounded, until the cached messages in [conversationId] pass
  /// [test].
  Future<List<MessageRow>> cachedMessagesWhere(
    String conversationId,
    bool Function(List<MessageRow> rows) test,
  ) => backend.database.chatDao
      .watchMessages(conversationId)
      .firstWhere(test)
      .timeout(bounded);

  Future<int> cachedUnread(String conversationId) async =>
      (await backend.database.chatDao.watchConversation(conversationId).first)!
          .conversation
          .unreadCount;

  Future<int> serverUnread(String conversationId) async =>
      (await backend.server.getConversations('u_demo'))
          .firstWhere((conversation) => conversation.id == conversationId)
          .unreadCount;

  /// Waits, bounded, until [condition] holds (for work the repository does
  /// in the background).
  Future<void> eventually(Future<bool> Function() condition) async {
    final deadline = DateTime.now().add(bounded);
    while (!await condition()) {
      if (DateTime.now().isAfter(deadline)) fail('Timed out waiting');
      await Future<void>.delayed(const Duration(milliseconds: 5));
    }
  }

  bool hasReplyFrom(List<MessageRow> rows, String senderId) =>
      rows.any((row) => row.senderId == senderId);

  /// Rebuilds the stack with its chat service wrapped in a [GatedChatApi],
  /// and fetches the conversations.
  Future<GatedChatApi> gatedChat() async {
    await backend.dispose();
    backend = DataStack(replies: quickReplies());
    final gated = GatedChatApi(backend.chatApi);
    backend.chatApiOverride = (_) => gated;
    await chat().refreshConversations();
    return gated;
  }

  /// My messages in c2 on the server, after the seed's one.
  Future<List<String>> myNewMessagesOnServer() async => [
    for (final message in await backend.server.getMessages('u_demo', 'c2'))
      if (message.senderId == 'u_demo') message.text,
  ].skip(1).toList();

  group('conversations and messages', () {
    test('refresh caches the conversations, the most recent activity first, '
        'and the unread total adds them up', () async {
      expect(await chat().refreshConversations(), isA<Ok<void>>());

      final conversations = await chat().watchConversations().first;
      expect(conversations.map((c) => c.id), ['c1', 'c2', 'c3']);
      expect(conversations.first.participant.name, 'Grace Hopper');
      expect(await chat().watchUnreadMessageCount().first, 3);
    });

    test('a chat opened from a deep link fetches its conversation first, '
        'then its messages', () async {
      expect(await chat().refreshMessages('c3'), isA<Ok<void>>());

      expect(await chat().watchConversation('c3').first, isNotNull);
      final onServer = await backend.server.getMessages('u_demo', 'c3');
      expect(
        (await cachedMessages('c3')).map((row) => row.id),
        onServer.map((message) => message.id),
      );
    });

    test('an unknown conversation is a NotFoundException', () async {
      final result = await chat().refreshMessages('c404');

      expect(
        result,
        isA<Err<void>>().having(
          (err) => err.exception,
          'exception',
          isA<NotFoundException>(),
        ),
      );
    });

    test('isMine comes from the signed-in user', () async {
      await chat().refreshMessages('c1');

      final messages = await chat().watchMessages('c1').first;
      expect(messages.map((message) => message.isMine), [
        false,
        true,
        false,
        false,
      ]);
    });
  });

  group('sending', () {
    setUp(() => chat().refreshConversations());

    test('20 messages sent at once reach the server in order, and all end '
        'sent', () async {
      final texts = [for (var i = 1; i <= 20; i++) 'Message $i'];

      final results = await Future.wait([
        for (final text in texts) chat().sendMessage('c2', text),
      ]);

      expect(results, everyElement(isA<Ok<void>>()));
      final onServer = await backend.server.getMessages('u_demo', 'c2');
      expect(
        onServer
            .where((message) => message.senderId == 'u_demo')
            .map((message) => message.text)
            .skip(1), // the seed's
        texts,
      );
      // c2's history was never fetched: the cache holds only what was sent
      // (and the replies).
      final mine = (await cachedMessages('c2'))
          .where((row) => row.senderId == 'u_demo');
      expect(mine.map((row) => row.content), texts);
      expect(
        mine.map((row) => row.status),
        everyElement(MessageRowStatus.sent),
      );
    });

    test('a failed send ends "Not sent", and a retry sends it with the same '
        'id', () async {
      backend.network.failRequests = true;

      final failed = await chat().sendMessage('c2', 'Hello');

      expect(failed, isA<Err<void>>());
      final row = (await cachedMessages('c2')).last;
      expect(row.content, 'Hello');
      expect(row.status, MessageRowStatus.failed);

      backend.network.failRequests = false;
      expect(await chat().retryMessage(row.id), isA<Ok<void>>());

      final retried = await backend.database.chatDao.findMessage(row.id);
      expect(retried!.status, MessageRowStatus.sent);
      final onServer = await backend.server.getMessages('u_demo', 'c2');
      expect(onServer.where((message) => message.id == row.id), hasLength(1));
    });

    test('sends reach the server in the order they were made, even when '
        'the first is slow (the Lock)', () async {
      final api = await gatedChat();
      final slow = Completer<void>();
      api.holdNextSend = slow;

      final sends = [
        for (final text in ['One', 'Two', 'Three'])
          chat().sendMessage('c2', text),
      ];
      // All three show at once, in order, while the first is in flight.
      final pending = await cachedMessagesWhere(
        'c2',
        (rows) => rows.length == 3,
      );
      expect(pending.map((row) => row.content), ['One', 'Two', 'Three']);
      expect(
        pending.map((row) => row.status),
        everyElement(MessageRowStatus.sending),
      );

      slow.complete();
      await Future.wait(sends);

      expect(await myNewMessagesOnServer(), ['One', 'Two', 'Three']);
    });

    test('a retry after a lost answer cannot post the message twice: the '
        'server recognizes its id', () async {
      final api = await gatedChat();

      api.loseNextAnswer = true;
      expect(await chat().sendMessage('c2', 'Hello'), isA<Err<void>>());
      final row = (await cachedMessages('c2')).last;
      expect(row.status, MessageRowStatus.failed);

      expect(await chat().retryMessage(row.id), isA<Ok<void>>());

      expect(await myNewMessagesOnServer(), ['Hello']);
      final mine = (await cachedMessages('c2'))
          .where((cached) => cached.content == 'Hello');
      expect(mine.single.status, MessageRowStatus.sent);
    });

    test('signed out, nothing is written or sent', () async {
      await backend.sessions.clear();

      final result = await chat().sendMessage('c2', 'Hello');

      expect(
        result,
        isA<Err<void>>().having(
          (err) => err.exception,
          'exception',
          isA<UnauthorizedException>(),
        ),
      );
      expect(
        (await cachedMessages('c2')).where((row) => row.content == 'Hello'),
        isEmpty,
      );
    });
  });

  group('the realtime channel', () {
    setUp(() => chat().refreshConversations());

    test("the other person's reply is cached as it arrives", () async {
      await chat().sendMessage('c2', 'Hello');

      final rows = await cachedMessagesWhere(
        'c2',
        (rows) => rows.last.senderId == 'u_alan',
      );
      expect(rows.last.content, FakeServer.cannedReplies.first);
      final c2 = (await chat().watchConversation('c2').first)!;
      expect(c2.lastMessage, FakeServer.cannedReplies.first);
    });

    test('typing turns on with the first pending reply and off after the '
        'last, across overlapping replies (Correctness Rule 8)', () async {
      // Replies that take long enough for two sends to overlap. (The
      // scheduler's timing itself is tested in fake time.)
      await backend.dispose();
      backend = DataStack(
        replies: ReplyScheduler(
          typingDelay: Duration.zero,
          replyDelay: const Duration(milliseconds: 50),
        ),
      );
      await chat().refreshConversations();
      final typing = <bool>[];
      final subscription = chat().watchTyping('c2').listen(typing.add);
      addTearDown(subscription.cancel);

      await chat().sendMessage('c2', 'One');
      await chat().sendMessage('c2', 'Two');
      await cachedMessagesWhere(
        'c2',
        (rows) => rows.where((row) => row.senderId == 'u_alan').length == 2,
      );
      await eventually(() async => typing.last == false);

      // On once, off once: never off between the two replies.
      expect(typing, [false, true, false]);
    });

    test(
      'a reply that arrives after logout is dropped, and typing resets',
      () async {
        await backend.dispose();
        backend = DataStack(
          replies: ReplyScheduler(
            typingDelay: Duration.zero,
            replyDelay: const Duration(milliseconds: 30),
          ),
        );
        await chat().refreshConversations();
        final typing = <bool>[];
        final subscription = chat().watchTyping('c2').listen(typing.add);
        addTearDown(subscription.cancel);
        await chat().sendMessage('c2', 'Hello');
        await eventually(() async => typing.last);
        final before = (await cachedMessages('c2')).length;

        await backend.sessions.clear();
        await Future<void>.delayed(const Duration(milliseconds: 80));

        expect(await cachedMessages('c2'), hasLength(before));
        expect(typing.last, isFalse);
      },
    );
  });

  group('unread (Correctness Rule 9)', () {
    setUp(() => chat().refreshConversations());

    test("a reply in a conversation that isn't on screen raises its unread "
        'count', () async {
      await chat().sendMessage('c2', 'Hello');

      await chat()
          .watchUnreadMessageCount()
          .firstWhere((total) => total == 4)
          .timeout(bounded);
      expect(await cachedUnread('c2'), 1);
    });

    test('a reply in the conversation on screen stays read, and the server '
        'is told', () async {
      final onScreen = chat().watchMessages('c2').listen((_) {});
      addTearDown(onScreen.cancel);

      await chat().sendMessage('c2', 'Hello');
      await cachedMessagesWhere('c2', (rows) => hasReplyFrom(rows, 'u_alan'));

      expect(await cachedUnread('c2'), 0);
      await eventually(() async => await serverUnread('c2') == 0);
    });

    test('markRead clears the count at once and on the server', () async {
      final marking = chat().markRead('c1');
      // At once, before the server answers.
      await pumpEventQueue(times: 2);
      expect(await cachedUnread('c1'), 0);

      expect(await marking, isA<Ok<void>>());
      expect(await serverUnread('c1'), 0);
    });

    test(
      'a failed markRead puts the count back (Correctness Rule 4)',
      () async {
        backend.network.failRequests = true;

        expect(await chat().markRead('c3'), isA<Err<void>>());

        expect(await cachedUnread('c3'), 1);
      },
    );

    test('a refresh keeps the conversation on screen read, whatever the '
        "server's count still says", () async {
      final onScreen = chat().watchMessages('c1').listen((_) {});
      addTearDown(onScreen.cancel);
      expect(await serverUnread('c1'), 2);

      await chat().refreshConversations();

      expect(await cachedUnread('c1'), 0);
    });
  });
}
