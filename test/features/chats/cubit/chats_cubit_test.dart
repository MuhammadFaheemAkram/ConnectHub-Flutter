import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:connect_hub/core/common/app_exception.dart';
import 'package:connect_hub/core/common/result.dart';
import 'package:connect_hub/core/common/ui_message.dart';
import 'package:connect_hub/domain/model/conversation.dart';
import 'package:connect_hub/domain/usecase/refresh_conversations_use_case.dart';
import 'package:connect_hub/domain/usecase/watch_conversations_use_case.dart';
import 'package:connect_hub/features/chats/cubit/chats_cubit.dart';
import 'package:connect_hub/features/chats/cubit/chats_state.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fakes/fake_chat_repository.dart';
import '../../../helpers/fixtures.dart';

void main() {
  late FakeChatRepository chat;

  final withGrace = sampleConversation(
    'c1',
    lastMessage: 'Approved with 12 comments',
    unreadCount: 2,
  );
  final withAlan = sampleConversation(
    'c2',
    participant: alan,
    lastMessage: 'Can machines think?',
    minutesAgo: 30,
  );
  final networkError = const NetworkException().message;

  setUp(() => chat = FakeChatRepository());
  tearDown(() => chat.dispose());

  ChatsCubit buildCubit() => ChatsCubit(
    WatchConversationsUseCase(chat),
    RefreshConversationsUseCase(chat),
  );

  ChatsState loaded(
    List<Conversation> list, {
    String query = '',
    UiMessage? message,
  }) => ChatsState(
    status: ChatsStatus.loaded,
    conversations: list,
    query: query,
    message: message,
  );

  group('loading', () {
    blocTest<ChatsCubit, ChatsState>(
      'cached conversations show at once, before the server answers',
      setUp: () =>
          chat = FakeChatRepository(cachedConversations: [withGrace, withAlan])
            ..gate = Completer<void>(),
      build: buildCubit,
      act: (cubit) => unawaited(cubit.load()),
      expect: () => [
        loaded([withGrace, withAlan]),
      ],
    );

    blocTest<ChatsCubit, ChatsState>(
      'nothing cached: loading, then what the server has; none at all is '
      'the empty state',
      setUp: () => chat.refreshedConversations = [withAlan],
      build: buildCubit,
      act: (cubit) => cubit.load(),
      expect: () => [
        loaded([withAlan]),
      ],
    );

    blocTest<ChatsCubit, ChatsState>(
      'nothing cached and the refresh fails: the error; Try again loads',
      setUp: () =>
          chat.refreshConversationsResult = const Err(NetworkException()),
      build: buildCubit,
      act: (cubit) async {
        await cubit.load();
        chat
          ..refreshConversationsResult = const Ok(null)
          ..refreshedConversations = [withGrace];
        await cubit.load();
      },
      expect: () => [
        ChatsState(status: ChatsStatus.failure, errorMessage: networkError),
        const ChatsState(),
        loaded([withGrace]),
      ],
    );

    blocTest<ChatsCubit, ChatsState>(
      'cached conversations stay when the refresh fails, and a message '
      'says so',
      setUp: () =>
          chat = FakeChatRepository(cachedConversations: [withGrace])
            ..refreshConversationsResult = const Err(NetworkException()),
      build: buildCubit,
      act: (cubit) => cubit.refresh(),
      expect: () => [
        loaded([withGrace]),
        loaded(
          [withGrace],
          message: const UiMessage(
            id: 1,
            text: ChatsCubit.refreshFailedMessage,
          ),
        ),
      ],
    );

    blocTest<ChatsCubit, ChatsState>(
      'the list stays live: a reply moves its conversation to the top',
      setUp: () =>
          chat = FakeChatRepository(cachedConversations: [withGrace, withAlan]),
      build: buildCubit,
      act: (_) async {
        await pumpEventQueue();
        chat.setConversations([withAlan, withGrace]);
      },
      expect: () => [
        loaded([withGrace, withAlan]),
        loaded([withAlan, withGrace]),
      ],
    );
  });

  group('search', () {
    late ChatsCubit cubit;

    setUp(() async {
      chat = FakeChatRepository(cachedConversations: [withGrace, withAlan]);
      cubit = buildCubit();
      await cubit.load();
    });

    tearDown(() => cubit.close());

    test('filters by name or last message, ignoring case and spaces, with '
        'no request', () {
      cubit.search('  GRACE ');
      expect(cubit.state.visible, [withGrace]);

      cubit.search('machines');
      expect(cubit.state.visible, [withAlan]);

      cubit.search('');
      expect(cubit.state.visible, [withGrace, withAlan]);
      expect(chat.refreshConversationsCalls, 1);
    });

    test('no matches: nothing visible, while the list itself is not empty', () {
      cubit.search('zzz');

      expect(cubit.state.visible, isEmpty);
      expect(cubit.state.conversations, isNotEmpty);
      expect(cubit.state.query, 'zzz');
    });
  });
}
