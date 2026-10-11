import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:connect_hub/core/common/app_exception.dart';
import 'package:connect_hub/core/common/result.dart';
import 'package:connect_hub/core/common/ui_message.dart';
import 'package:connect_hub/domain/model/message.dart';
import 'package:connect_hub/domain/usecase/mark_conversation_read_use_case.dart';
import 'package:connect_hub/domain/usecase/refresh_messages_use_case.dart';
import 'package:connect_hub/domain/usecase/retry_message_use_case.dart';
import 'package:connect_hub/domain/usecase/send_message_use_case.dart';
import 'package:connect_hub/domain/usecase/watch_conversation_use_case.dart';
import 'package:connect_hub/domain/usecase/watch_messages_use_case.dart';
import 'package:connect_hub/domain/usecase/watch_typing_use_case.dart';
import 'package:connect_hub/features/chat_detail/cubit/chat_detail_cubit.dart';
import 'package:connect_hub/features/chat_detail/cubit/chat_detail_state.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fakes/fake_chat_repository.dart';
import '../../../helpers/fixtures.dart';

void main() {
  late FakeChatRepository chat;

  final conversation = sampleConversation('c1', unreadCount: 2);
  final m1 = sampleMessage('m1', minutesAgo: 10);
  final m2 = sampleMessage('m2', isMine: true, minutesAgo: 5);
  final networkError = const NetworkException().message;

  setUp(() => chat = FakeChatRepository());
  tearDown(() => chat.dispose());

  ChatDetailCubit buildCubit() => ChatDetailCubit(
    'c1',
    WatchConversationUseCase(chat),
    WatchMessagesUseCase(chat),
    WatchTypingUseCase(chat),
    RefreshMessagesUseCase(chat),
    MarkConversationReadUseCase(chat),
    SendMessageUseCase(chat),
    RetryMessageUseCase(chat),
  );

  /// A chat cached with [conversation] and [messages].
  FakeChatRepository cached({List<Message> messages = const []}) =>
      FakeChatRepository(
        cachedConversations: [conversation],
        cachedMessages: {'c1': messages},
      );

  ChatDetailState ready(List<Message> messages, {UiMessage? message}) =>
      ChatDetailState(
        status: ChatStatus.ready,
        participant: grace,
        messages: messages,
        message: message,
      );

  group('loading', () {
    blocTest<ChatDetailCubit, ChatDetailState>(
      'cached messages show at once, before the server answers',
      setUp: () => chat = cached(messages: [m1, m2])..gate = Completer<void>(),
      build: buildCubit,
      act: (cubit) => unawaited(cubit.load()),
      expect: () => [
        ready([m1, m2]),
      ],
    );

    blocTest<ChatDetailCubit, ChatDetailState>(
      'nothing cached (a deep link): loading, then the messages; never "Say '
      'hello" before they arrive',
      setUp: () => chat.refreshedMessages['c1'] = [m1, m2],
      build: buildCubit,
      act: (cubit) async {
        // The repository fetches the conversation along with the messages.
        chat.setConversations([conversation]);
        await cubit.load();
      },
      expect: () => [
        const ChatDetailState(participant: grace),
        ready([m1, m2]),
      ],
    );

    blocTest<ChatDetailCubit, ChatDetailState>(
      'a chat with no messages yet is ready: "Say hello"',
      setUp: () => chat = cached(),
      build: buildCubit,
      act: (cubit) => cubit.load(),
      expect: () => [
        const ChatDetailState(participant: grace),
        ready(const []),
      ],
    );

    blocTest<ChatDetailCubit, ChatDetailState>(
      'nothing cached and the refresh fails: the error; Try again loads',
      setUp: () => chat.refreshMessagesResult = const Err(NetworkException()),
      build: buildCubit,
      act: (cubit) async {
        await cubit.load();
        chat
          ..refreshMessagesResult = const Ok(null)
          ..setConversations([conversation])
          ..refreshedMessages['c1'] = [m1];
        await cubit.load();
      },
      expect: () => [
        ChatDetailState(status: ChatStatus.failure, errorMessage: networkError),
        const ChatDetailState(),
        const ChatDetailState(participant: grace),
        ready([m1]),
      ],
    );

    blocTest<ChatDetailCubit, ChatDetailState>(
      'cached messages stay when the refresh fails, and a message says so',
      setUp: () =>
          chat = cached(messages: [m1])
            ..refreshMessagesResult = const Err(NetworkException()),
      build: buildCubit,
      act: (cubit) => cubit.load(),
      expect: () => [
        ready([m1]),
        ready(
          [m1],
          message: const UiMessage(
            id: 1,
            text: ChatDetailCubit.refreshFailedMessage,
          ),
        ),
      ],
    );

    blocTest<ChatDetailCubit, ChatDetailState>(
      "a conversation the server doesn't have (for this user): not found",
      setUp: () =>
          chat = cached(messages: [m1])
            ..refreshMessagesResult = const Err(NotFoundException()),
      build: buildCubit,
      act: (cubit) => cubit.load(),
      skip: 1,
      expect: () => [
        ChatDetailState(
          status: ChatStatus.notFound,
          participant: grace,
          messages: [m1],
        ),
      ],
    );
  });

  group('while open', () {
    test('opening the chat reads it (Correctness Rule 9)', () async {
      chat = cached(messages: [m1]);
      final cubit = buildCubit();
      addTearDown(cubit.close);

      await cubit.load();

      expect(chat.markedRead, ['c1']);
    });

    test('the messages are watched (the conversation counts as open) for '
        'as long as the screen lives', () async {
      chat = cached(messages: [m1]);
      final cubit = buildCubit();
      await pumpEventQueue();
      expect(chat.openWatchers['c1'], 1);

      await cubit.close();

      expect(chat.openWatchers['c1'], 0);
    });

    blocTest<ChatDetailCubit, ChatDetailState>(
      'the typing indicator follows the repository',
      setUp: () => chat = cached(messages: [m1]),
      build: buildCubit,
      act: (cubit) async {
        await cubit.load();
        chat.setTyping('c1', typing: true);
        await pumpEventQueue();
        chat.setTyping('c1', typing: false);
      },
      expect: () => [
        ready([m1]),
        ready([m1]).copyWith(isTyping: true),
        ready([m1]),
      ],
    );

    blocTest<ChatDetailCubit, ChatDetailState>(
      'a reply arriving appends to the list',
      setUp: () => chat = cached(messages: [m1]),
      build: buildCubit,
      act: (cubit) async {
        await cubit.load();
        chat.setMessages('c1', [m1, m2]);
      },
      expect: () => [
        ready([m1]),
        ready([m1, m2]),
      ],
    );

    blocTest<ChatDetailCubit, ChatDetailState>(
      'send forwards the trimmed text (blank sends nothing); retry forwards '
      'the message',
      setUp: () => chat = cached(messages: [m1]),
      build: buildCubit,
      act: (cubit) async {
        await cubit.send('  Hello  ');
        await cubit.send('   ');
        await cubit.retry(m2);
      },
      verify: (_) {
        expect(chat.sent, [(conversationId: 'c1', text: 'Hello')]);
        expect(chat.retried, ['m2']);
      },
    );
  });
}
