import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:connect_hub/core/common/app_exception.dart';
import 'package:connect_hub/core/common/result.dart';
import 'package:connect_hub/core/common/ui_message.dart';
import 'package:connect_hub/domain/model/post.dart';
import 'package:connect_hub/domain/usecase/bookmark_post_use_case.dart';
import 'package:connect_hub/domain/usecase/like_post_use_case.dart';
import 'package:connect_hub/domain/usecase/refresh_bookmarks_use_case.dart';
import 'package:connect_hub/domain/usecase/watch_bookmarks_use_case.dart';
import 'package:connect_hub/features/bookmarks/cubit/bookmarks_cubit.dart';
import 'package:connect_hub/features/bookmarks/cubit/bookmarks_state.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fakes/fake_bookmark_repository.dart';
import '../../../helpers/fakes/fake_post_repository.dart';
import '../../../helpers/fixtures.dart';

void main() {
  late FakeBookmarkRepository bookmarks;
  late FakePostRepository posts;

  final p1 = samplePost('p1', isBookmarked: true);
  final p2 = samplePost('p2', isBookmarked: true);
  final networkError = const NetworkException().message;

  setUp(() {
    bookmarks = FakeBookmarkRepository();
    posts = FakePostRepository();
  });

  tearDown(() async {
    await bookmarks.dispose();
    await posts.dispose();
  });

  BookmarksCubit buildCubit() => BookmarksCubit(
    WatchBookmarksUseCase(bookmarks),
    RefreshBookmarksUseCase(bookmarks),
    BookmarkPostUseCase(posts),
    LikePostUseCase(posts),
  );

  BookmarksState loaded(List<Post> list, {UiMessage? message}) =>
      BookmarksState(
        status: BookmarksStatus.loaded,
        posts: list,
        message: message,
      );

  const removed = UiMessage(
    id: 1,
    text: BookmarksCubit.removedMessage,
    action: UiMessageAction.undo,
  );

  group('loading', () {
    blocTest<BookmarksCubit, BookmarksState>(
      'cached bookmarks show at once, offline, before the server answers',
      setUp: () =>
          bookmarks = FakeBookmarkRepository(cached: [p1, p2])
            ..refreshGate = Completer<void>(),
      build: buildCubit,
      act: (cubit) => unawaited(cubit.load()),
      expect: () => [
        loaded([p1, p2]),
      ],
    );

    blocTest<BookmarksCubit, BookmarksState>(
      'nothing cached: loading, then what the server has',
      setUp: () => bookmarks.refreshedBookmarks = [p1],
      build: buildCubit,
      act: (cubit) => cubit.load(),
      expect: () => [
        loaded([p1]),
      ],
    );

    blocTest<BookmarksCubit, BookmarksState>(
      'no bookmarks at all: loaded, with none (the empty state)',
      build: buildCubit,
      act: (cubit) => cubit.load(),
      expect: () => [loaded(const [])],
    );

    blocTest<BookmarksCubit, BookmarksState>(
      'nothing cached and the refresh fails: the error; Try again loads',
      setUp: () => bookmarks.refreshResult = const Err(NetworkException()),
      build: buildCubit,
      act: (cubit) async {
        await cubit.load();
        bookmarks
          ..refreshResult = const Ok(null)
          ..refreshedBookmarks = [p1];
        await cubit.load();
      },
      expect: () => [
        BookmarksState(
          status: BookmarksStatus.failure,
          errorMessage: networkError,
        ),
        const BookmarksState(),
        loaded([p1]),
      ],
    );

    blocTest<BookmarksCubit, BookmarksState>(
      'cached bookmarks stay when the refresh fails, and a message says so',
      setUp: () =>
          bookmarks = FakeBookmarkRepository(cached: [p1])
            ..refreshResult = const Err(NetworkException()),
      build: buildCubit,
      act: (cubit) => cubit.load(),
      expect: () => [
        loaded([p1]),
        loaded(
          [p1],
          message: const UiMessage(
            id: 1,
            text: BookmarksCubit.refreshFailedMessage,
          ),
        ),
      ],
    );
  });

  group('remove + Undo', () {
    blocTest<BookmarksCubit, BookmarksState>(
      'removing offers Undo at once; the list follows the cache',
      setUp: () => bookmarks = FakeBookmarkRepository(cached: [p1, p2]),
      build: buildCubit,
      act: (cubit) async {
        await pumpEventQueue();
        await cubit.remove(p1);
        // The repository's optimistic write, as drift would report it.
        bookmarks.replaceBookmarks([p2]);
      },
      expect: () => [
        loaded([p1, p2]),
        loaded([p1, p2], message: removed),
        loaded([p2], message: removed),
      ],
      verify: (_) =>
          expect(posts.bookmarkCalls, [(postId: 'p1', bookmarked: false)]),
    );

    blocTest<BookmarksCubit, BookmarksState>(
      'Undo bookmarks the post again',
      build: buildCubit,
      act: (cubit) async {
        await cubit.remove(p1);
        await cubit.undoRemove();
      },
      verify: (_) => expect(posts.bookmarkCalls, [
        (postId: 'p1', bookmarked: false),
        (postId: 'p1', bookmarked: true),
      ]),
    );

    test('Undo waits for a removal still in flight, so the bookmark is sent '
        'after it (one request per post at a time)', () async {
      final cubit = buildCubit();
      addTearDown(cubit.close);
      posts.bookmarkGate = Completer<void>();

      unawaited(cubit.remove(p1));
      final undo = cubit.undoRemove();
      await pumpEventQueue();
      expect(posts.bookmarkCalls, [(postId: 'p1', bookmarked: false)]);

      posts.bookmarkGate!.complete();
      await undo;
      expect(posts.bookmarkCalls.last, (postId: 'p1', bookmarked: true));
    });

    test('Undo does nothing a second time', () async {
      final cubit = buildCubit();
      addTearDown(cubit.close);

      await cubit.remove(p1);
      await cubit.undoRemove();
      await cubit.undoRemove();

      expect(posts.bookmarkCalls, hasLength(2));
    });

    blocTest<BookmarksCubit, BookmarksState>(
      'a removal that fails says so, and leaves nothing to undo (the '
      'repository has put it back)',
      setUp: () {
        bookmarks = FakeBookmarkRepository(cached: [p1]);
        posts.bookmarkResult = const Err(NetworkException());
      },
      build: buildCubit,
      act: (cubit) async {
        await pumpEventQueue();
        await cubit.remove(p1);
        await cubit.undoRemove();
      },
      expect: () => [
        loaded([p1]),
        loaded([p1], message: removed),
        loaded(
          [p1],
          message: const UiMessage(
            id: 2,
            text: BookmarksCubit.bookmarkFailedMessage,
          ),
        ),
      ],
      verify: (_) => expect(posts.bookmarkCalls, hasLength(1)),
    );
  });

  blocTest<BookmarksCubit, BookmarksState>(
    'a like that fails says so',
    setUp: () {
      bookmarks = FakeBookmarkRepository(cached: [p1]);
      posts.likeResult = const Err(NetworkException());
    },
    build: buildCubit,
    act: (cubit) async {
      await pumpEventQueue();
      await cubit.toggleLike(p1);
    },
    expect: () => [
      loaded([p1]),
      loaded(
        [p1],
        message: const UiMessage(id: 1, text: BookmarksCubit.likeFailedMessage),
      ),
    ],
    verify: (_) => expect(posts.likeCalls, [(postId: 'p1', liked: true)]),
  );
}
