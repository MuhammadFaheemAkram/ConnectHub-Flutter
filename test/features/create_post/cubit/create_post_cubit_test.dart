import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:connect_hub/core/common/app_exception.dart';
import 'package:connect_hub/core/common/form_status.dart';
import 'package:connect_hub/core/common/result.dart';
import 'package:connect_hub/domain/usecase/create_post_use_case.dart';
import 'package:connect_hub/features/create_post/cubit/create_post_cubit.dart';
import 'package:connect_hub/features/create_post/cubit/create_post_state.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fakes/fake_post_repository.dart';

void main() {
  late FakePostRepository posts;

  setUp(() => posts = FakePostRepository());

  tearDown(() => posts.dispose());

  CreatePostCubit buildCubit() => CreatePostCubit(CreatePostUseCase(posts));

  group('validation', () {
    test('an untouched form shows no errors, but Post is disabled', () {
      const state = CreatePostState();

      expect(state.contentError, isNull);
      expect(state.imageUrlError, isNull);
      expect(state.canSubmit, isFalse);
      expect(state.hasDraft, isFalse);
    });

    test('some text is enough to post, and the counter counts it', () {
      const state = CreatePostState(content: 'Hello 👋');

      expect(state.length, 7);
      expect(state.canSubmit, isTrue);
    });

    test('whitespace only asks for something to share', () {
      const state = CreatePostState(content: '   ');

      expect(state.contentError, 'Write something to share.');
      expect(state.canSubmit, isFalse);
      expect(state.hasDraft, isFalse);
    });

    test('over 280 characters: the error, and Post is disabled', () {
      final state = CreatePostState(content: 'a' * 281);

      expect(state.length, 281);
      expect(state.contentError, 'Posts are limited to 280 characters.');
      expect(state.canSubmit, isFalse);
    });

    test('a bad image URL blocks posting; an empty one is fine', () {
      const bad = CreatePostState(content: 'Hi', imageUrl: 'not a url');
      const none = CreatePostState(content: 'Hi');

      expect(bad.imageUrlError, 'Enter a valid image URL, or leave it empty.');
      expect(bad.canSubmit, isFalse);
      expect(none.canSubmit, isTrue);
    });

    test('an image URL alone is a draft worth asking about', () {
      expect(
        const CreatePostState(imageUrl: 'https://x.dev/a.png').hasDraft,
        isTrue,
      );
    });
  });

  group('submit', () {
    blocTest<CreatePostCubit, CreatePostState>(
      'sends the values trimmed, then reports success',
      build: buildCubit,
      act: (cubit) async {
        cubit
          ..contentChanged('  Hello  ')
          ..imageUrlChanged(' https://picsum.photos/600/400 ');
        await cubit.submit();
      },
      skip: 2,
      expect: () => [
        const CreatePostState(
          content: '  Hello  ',
          imageUrl: ' https://picsum.photos/600/400 ',
          status: FormStatus.submitting,
        ),
        const CreatePostState(
          content: '  Hello  ',
          imageUrl: ' https://picsum.photos/600/400 ',
          status: FormStatus.success,
        ),
      ],
      verify: (_) => expect(posts.createCalls, [
        (content: 'Hello', imageUrl: 'https://picsum.photos/600/400'),
      ]),
    );

    blocTest<CreatePostCubit, CreatePostState>(
      'an empty image URL is sent as no image',
      build: buildCubit,
      act: (cubit) async {
        cubit.contentChanged('Hello');
        await cubit.submit();
      },
      verify: (_) =>
          expect(posts.createCalls, [(content: 'Hello', imageUrl: null)]),
    );

    blocTest<CreatePostCubit, CreatePostState>(
      "a failure keeps the input and shows the server's message; editing "
      'clears it',
      setUp: () => posts.createResult = const Err(NetworkException()),
      build: buildCubit,
      act: (cubit) async {
        cubit.contentChanged('Hello');
        await cubit.submit();
        cubit.contentChanged('Hello!');
      },
      skip: 2,
      expect: () => [
        CreatePostState(
          content: 'Hello',
          status: FormStatus.failure,
          errorMessage: const NetworkException().message,
        ),
        const CreatePostState(content: 'Hello!'),
      ],
    );

    blocTest<CreatePostCubit, CreatePostState>(
      'an invalid form, or a second submit while one runs, is not sent',
      setUp: () => posts.createGate = Completer<void>(),
      build: buildCubit,
      act: (cubit) async {
        await cubit.submit(); // empty
        cubit.contentChanged('Hello');
        unawaited(cubit.submit());
        await cubit.submit();
      },
      verify: (_) => expect(posts.createCalls, hasLength(1)),
    );
  });
}
