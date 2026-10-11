import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:connect_hub/core/common/app_exception.dart';
import 'package:connect_hub/core/common/result.dart';
import 'package:connect_hub/core/common/ui_message.dart';
import 'package:connect_hub/domain/usecase/add_comment_use_case.dart';
import 'package:connect_hub/domain/usecase/bookmark_post_use_case.dart';
import 'package:connect_hub/domain/usecase/like_post_use_case.dart';
import 'package:connect_hub/domain/usecase/refresh_comments_use_case.dart';
import 'package:connect_hub/domain/usecase/refresh_post_use_case.dart';
import 'package:connect_hub/domain/usecase/watch_comments_use_case.dart';
import 'package:connect_hub/domain/usecase/watch_post_use_case.dart';
import 'package:connect_hub/features/post_detail/cubit/post_detail_cubit.dart';
import 'package:connect_hub/features/post_detail/cubit/post_detail_state.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fakes/fake_comment_repository.dart';
import '../../../helpers/fakes/fake_post_repository.dart';
import '../../../helpers/fixtures.dart';

void main() {
  late FakePostRepository posts;
  late FakeCommentRepository comments;

  final p1 = samplePost('p1', commentCount: 3);
  final networkError = const NetworkException().message;

  setUp(() {
    posts = FakePostRepository();
    comments = FakeCommentRepository();
  });

  tearDown(() async {
    await posts.dispose();
    await comments.dispose();
  });

  PostDetailCubit buildCubit() => PostDetailCubit(
    'p1',
    WatchPostUseCase(posts),
    RefreshPostUseCase(posts),
    WatchCommentsUseCase(comments),
    RefreshCommentsUseCase(comments),
    AddCommentUseCase(comments),
    LikePostUseCase(posts),
    BookmarkPostUseCase(posts),
  );

  UiMessage message(int id, String text) => UiMessage(id: id, text: text);

  group('loading', () {
    blocTest<PostDetailCubit, PostDetailState>(
      'a cached post shows at once, before the server answers',
      setUp: () =>
          posts = FakePostRepository(cached: p1)
            ..refreshGate = Completer<void>(),
      build: buildCubit,
      act: (cubit) => unawaited(cubit.load()),
      expect: () => [PostDetailState.loaded(post: p1)],
    );

    blocTest<PostDetailCubit, PostDetailState>(
      'an uncached post loads without ever flashing an error first',
      setUp: () => posts.refreshedPost = p1,
      build: buildCubit,
      act: (cubit) => cubit.load(),
      expect: () => [PostDetailState.loaded(post: p1)],
    );

    blocTest<PostDetailCubit, PostDetailState>(
      'uncached and the fetch fails: the error; Try again loads',
      setUp: () => posts.refreshResult = const Err(NetworkException()),
      build: buildCubit,
      act: (cubit) async {
        await cubit.load();
        posts
          ..refreshResult = const Ok(null)
          ..refreshedPost = p1;
        await cubit.load();
      },
      expect: () => [
        PostDetailState.error(networkError),
        const PostDetailState.loading(),
        PostDetailState.loaded(post: p1),
      ],
    );

    blocTest<PostDetailCubit, PostDetailState>(
      'a post the server no longer has: not found, even if it was cached',
      setUp: () =>
          posts = FakePostRepository(cached: p1)
            ..refreshResult = const Err(NotFoundException()),
      build: buildCubit,
      act: (cubit) => cubit.load(),
      expect: () => [
        PostDetailState.loaded(post: p1),
        const PostDetailState.notFound(),
      ],
    );

    blocTest<PostDetailCubit, PostDetailState>(
      'a cached post stays when the refresh fails, and a message says so',
      setUp: () =>
          posts = FakePostRepository(cached: p1)
            ..refreshResult = const Err(NetworkException()),
      build: buildCubit,
      act: (cubit) => cubit.load(),
      expect: () => [
        PostDetailState.loaded(post: p1),
        PostDetailState.loaded(
          post: p1,
          message: message(1, PostDetailCubit.refreshFailedMessage),
        ),
      ],
    );

    blocTest<PostDetailCubit, PostDetailState>(
      'comments that fail to load are reported too',
      setUp: () {
        posts.refreshedPost = p1;
        comments.refreshResult = const Err(NetworkException());
      },
      build: buildCubit,
      act: (cubit) => cubit.load(),
      expect: () => [
        // The post shows as soon as it is cached; the failure follows.
        PostDetailState.loaded(post: p1),
        PostDetailState.loaded(
          post: p1,
          message: message(1, PostDetailCubit.commentsFailedMessage),
        ),
      ],
    );
  });

  blocTest<PostDetailCubit, PostDetailState>(
    'previews the three most recent comments, the oldest of them first',
    setUp: () {
      posts = FakePostRepository(cached: p1);
      comments = FakeCommentRepository(
        cached: [
          for (var i = 1; i <= 5; i++) sampleComment('c$i', minutesAgo: 10 - i),
        ],
      );
    },
    build: buildCubit,
    act: (_) => pumpEventQueue(),
    verify: (cubit) => expect(
      (cubit.state as PostDetailLoaded).recentComments.map((c) => c.id),
      ['c3', 'c4', 'c5'],
    ),
  );

  group('sending a comment', () {
    final sent = sampleComment('c_new', isMine: true);

    blocTest<PostDetailCubit, PostDetailState>(
      'shows progress, then lists the comment as the input clears',
      setUp: () {
        posts = FakePostRepository(cached: p1);
        comments.addedComment = sent;
      },
      build: buildCubit,
      act: (cubit) async {
        await pumpEventQueue();
        await cubit.sendComment('Hello');
      },
      expect: () => [
        PostDetailState.loaded(post: p1),
        PostDetailState.loaded(post: p1, isSending: true),
        // The comment is listed while the button still shows progress…
        PostDetailState.loaded(
          post: p1,
          recentComments: [sent],
          isSending: true,
        ),
        // …then the input clears.
        PostDetailState.loaded(post: p1, recentComments: [sent], sentCount: 1),
      ],
      verify: (_) => expect(comments.addCalls, [(postId: 'p1', text: 'Hello')]),
    );

    blocTest<PostDetailCubit, PostDetailState>(
      'a failure says so, and the text stays (no sentCount)',
      setUp: () {
        posts = FakePostRepository(cached: p1);
        comments.addResult = const Err(NetworkException());
      },
      build: buildCubit,
      act: (cubit) async {
        await pumpEventQueue();
        await cubit.sendComment('Hello');
      },
      skip: 2,
      expect: () => [
        PostDetailState.loaded(
          post: p1,
          message: message(1, PostDetailCubit.sendFailedMessage),
        ),
      ],
    );

    blocTest<PostDetailCubit, PostDetailState>(
      'blank text, and a second send while one is out, are ignored',
      setUp: () {
        posts = FakePostRepository(cached: p1);
        comments.addGate = Completer<void>();
      },
      build: buildCubit,
      act: (cubit) async {
        await pumpEventQueue();
        await cubit.sendComment('   ');
        unawaited(cubit.sendComment('Hello'));
        await cubit.sendComment('Hello again');
      },
      verify: (_) => expect(comments.addCalls, hasLength(1)),
    );
  });

  blocTest<PostDetailCubit, PostDetailState>(
    'a failed like or bookmark says so (the repository rolled it back)',
    setUp: () => posts = FakePostRepository(cached: p1)
      ..likeResult = const Err(NetworkException())
      ..bookmarkResult = const Err(NetworkException()),
    build: buildCubit,
    act: (cubit) async {
      await pumpEventQueue();
      await cubit.toggleLike(p1);
      await cubit.toggleBookmark(p1);
    },
    skip: 1,
    expect: () => [
      PostDetailState.loaded(
        post: p1,
        message: message(1, PostDetailCubit.likeFailedMessage),
      ),
      PostDetailState.loaded(
        post: p1,
        message: message(2, PostDetailCubit.bookmarkFailedMessage),
      ),
    ],
    verify: (_) {
      expect(posts.likeCalls, [(postId: 'p1', liked: true)]);
      expect(posts.bookmarkCalls, [(postId: 'p1', bookmarked: true)]);
    },
  );
}
