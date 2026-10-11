import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:connect_hub/core/common/app_exception.dart';
import 'package:connect_hub/core/common/result.dart';
import 'package:connect_hub/core/common/ui_message.dart';
import 'package:connect_hub/domain/model/comment.dart';
import 'package:connect_hub/domain/usecase/add_comment_use_case.dart';
import 'package:connect_hub/domain/usecase/delete_comment_use_case.dart';
import 'package:connect_hub/domain/usecase/refresh_comments_use_case.dart';
import 'package:connect_hub/domain/usecase/watch_comments_use_case.dart';
import 'package:connect_hub/features/comments/cubit/comments_cubit.dart';
import 'package:connect_hub/features/comments/cubit/comments_state.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fakes/fake_comment_repository.dart';
import '../../../helpers/fixtures.dart';

void main() {
  late FakeCommentRepository comments;

  final c1 = sampleComment('c1', minutesAgo: 20);
  final c2 = sampleComment('c2', minutesAgo: 10);
  final mine = sampleComment('c3', isMine: true);
  final networkError = const NetworkException().message;

  setUp(() => comments = FakeCommentRepository());

  tearDown(() => comments.dispose());

  CommentsCubit buildCubit() => CommentsCubit(
    'p1',
    WatchCommentsUseCase(comments),
    RefreshCommentsUseCase(comments),
    AddCommentUseCase(comments),
    DeleteCommentUseCase(comments),
  );

  const loading = CommentsState();
  CommentsState loaded(List<Comment> list) =>
      CommentsState(status: CommentsStatus.loaded, comments: list);

  UiMessage message(int id, String text) => UiMessage(id: id, text: text);

  group('loading', () {
    blocTest<CommentsCubit, CommentsState>(
      'cached comments show at once, before the server answers',
      setUp: () =>
          comments = FakeCommentRepository(cached: [c1])
            ..refreshGate = Completer<void>(),
      build: buildCubit,
      act: (cubit) => unawaited(cubit.load()),
      expect: () => [
        loaded([c1]),
      ],
    );

    blocTest<CommentsCubit, CommentsState>(
      'nothing cached: loading, then the comments, oldest first',
      setUp: () => comments.refreshedComments = [c1, c2],
      build: buildCubit,
      act: (cubit) => cubit.load(),
      expect: () => [
        loaded([c1, c2]),
      ],
    );

    blocTest<CommentsCubit, CommentsState>(
      'no comments at all: loaded, with none (the empty state)',
      build: buildCubit,
      act: (cubit) => cubit.load(),
      expect: () => [loaded([])],
    );

    blocTest<CommentsCubit, CommentsState>(
      'nothing cached and the refresh fails: the error; Try again loads',
      setUp: () => comments.refreshResult = const Err(NetworkException()),
      build: buildCubit,
      act: (cubit) async {
        await cubit.load();
        comments
          ..refreshResult = const Ok(null)
          ..refreshedComments = [c1];
        await cubit.load();
      },
      expect: () => [
        CommentsState(
          status: CommentsStatus.failure,
          errorMessage: networkError,
        ),
        loading,
        loaded([c1]),
      ],
    );

    blocTest<CommentsCubit, CommentsState>(
      'a post that no longer exists says so',
      setUp: () => comments.refreshResult = const Err(NotFoundException()),
      build: buildCubit,
      act: (cubit) => cubit.load(),
      expect: () => [
        const CommentsState(
          status: CommentsStatus.failure,
          errorMessage: CommentsCubit.notFoundMessage,
        ),
      ],
    );

    blocTest<CommentsCubit, CommentsState>(
      'cached comments stay when the refresh fails, and a message says so',
      setUp: () =>
          comments = FakeCommentRepository(cached: [c1])
            ..refreshResult = const Err(NetworkException()),
      build: buildCubit,
      act: (cubit) => cubit.load(),
      expect: () => [
        loaded([c1]),
        loaded([c1])
            .copyWith(message: message(1, CommentsCubit.refreshFailedMessage)),
      ],
    );
  });

  group('sending', () {
    blocTest<CommentsCubit, CommentsState>(
      'shows progress, lists the comment, then clears the input',
      setUp: () =>
          comments = FakeCommentRepository(cached: [c1])..addedComment = mine,
      build: buildCubit,
      act: (cubit) async {
        await pumpEventQueue();
        await cubit.send('Hello');
      },
      expect: () => [
        loaded([c1]),
        loaded([c1]).copyWith(isSending: true),
        loaded([c1, mine]).copyWith(isSending: true),
        loaded([c1, mine]).copyWith(sentCount: 1),
      ],
    );

    blocTest<CommentsCubit, CommentsState>(
      'a failure says so, and the text stays (no sentCount)',
      setUp: () =>
          comments = FakeCommentRepository(cached: [c1])
            ..addResult = const Err(NetworkException()),
      build: buildCubit,
      act: (cubit) async {
        await pumpEventQueue();
        await cubit.send('Hello');
      },
      skip: 2,
      expect: () => [
        loaded([c1])
            .copyWith(message: message(1, CommentsCubit.sendFailedMessage)),
      ],
    );

    blocTest<CommentsCubit, CommentsState>(
      'blank text, and a second send while one is out, are ignored',
      setUp: () => comments.addGate = Completer<void>(),
      build: buildCubit,
      act: (cubit) async {
        await cubit.send('  ');
        unawaited(cubit.send('Hello'));
        await cubit.send('Hello again');
      },
      verify: (_) => expect(comments.addCalls, hasLength(1)),
    );
  });

  group('deleting', () {
    blocTest<CommentsCubit, CommentsState>(
      'asks the repository to delete that comment',
      setUp: () => comments = FakeCommentRepository(cached: [c1, mine]),
      build: buildCubit,
      act: (cubit) async {
        await pumpEventQueue();
        await cubit.delete(mine);
        await pumpEventQueue();
      },
      expect: () => [
        loaded([c1, mine]),
        loaded([c1]),
      ],
      verify: (_) => expect(comments.deleteCalls, ['c3']),
    );

    blocTest<CommentsCubit, CommentsState>(
      'a failure says so (the repository has put the comment back)',
      setUp: () =>
          comments = FakeCommentRepository(cached: [mine])
            ..deleteResult = const Err(NetworkException()),
      build: buildCubit,
      act: (cubit) async {
        await pumpEventQueue();
        await cubit.delete(mine);
      },
      expect: () => [
        loaded([mine]),
        loaded([mine])
            .copyWith(message: message(1, CommentsCubit.deleteFailedMessage)),
      ],
    );
  });
}
