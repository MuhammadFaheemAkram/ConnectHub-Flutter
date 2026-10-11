import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:connect_hub/core/common/app_exception.dart';
import 'package:connect_hub/core/common/result.dart';
import 'package:connect_hub/core/common/ui_message.dart';
import 'package:connect_hub/domain/usecase/bookmark_post_use_case.dart';
import 'package:connect_hub/domain/usecase/like_post_use_case.dart';
import 'package:connect_hub/domain/usecase/refresh_user_posts_use_case.dart';
import 'package:connect_hub/domain/usecase/refresh_user_use_case.dart';
import 'package:connect_hub/domain/usecase/watch_user_posts_use_case.dart';
import 'package:connect_hub/domain/usecase/watch_user_use_case.dart';
import 'package:connect_hub/features/profile/cubit/profile_cubit.dart';
import 'package:connect_hub/features/profile/cubit/profile_state.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fakes/fake_post_repository.dart';
import '../../../helpers/fakes/fake_profile_repository.dart';
import '../../../helpers/fixtures.dart';

void main() {
  late FakeProfileRepository profiles;
  late FakePostRepository posts;

  final p1 = samplePost('p1');
  final p6 = samplePost('p6');
  final networkError = const NetworkException().message;

  setUp(() {
    profiles = FakeProfileRepository();
    posts = FakePostRepository();
  });

  tearDown(() async {
    await profiles.dispose();
    await posts.dispose();
  });

  ProfileCubit buildCubit({String userId = 'u_ada'}) => ProfileCubit(
    userId,
    WatchUserUseCase(profiles),
    RefreshUserUseCase(profiles),
    WatchUserPostsUseCase(profiles),
    RefreshUserPostsUseCase(profiles),
    LikePostUseCase(posts),
    BookmarkPostUseCase(posts),
  );

  group('loading', () {
    blocTest<ProfileCubit, ProfileState>(
      'a cached profile shows at once, then the posts the server has',
      setUp: () {
        profiles = FakeProfileRepository(cachedUsers: [ada])
          ..refreshUserGate = Completer<void>()
          ..refreshedPosts = [p1, p6];
      },
      build: buildCubit,
      act: (cubit) async {
        unawaited(cubit.load());
        await pumpEventQueue();
        profiles.refreshUserGate!.complete();
      },
      expect: () => [
        const ProfileState.loaded(user: ada, isLoadingPosts: true),
        ProfileState.loaded(user: ada, posts: [p1, p6]),
      ],
    );

    blocTest<ProfileCubit, ProfileState>(
      'nothing cached: loading, then the profile (its posts still loading), '
      'then the posts',
      setUp: () => profiles
        ..refreshedUser = ada
        ..refreshedPosts = [p1],
      build: buildCubit,
      act: (cubit) => cubit.load(),
      expect: () => [
        const ProfileState.loaded(user: ada, isLoadingPosts: true),
        ProfileState.loaded(user: ada, posts: [p1]),
      ],
    );

    test('regression: a profile never shows "no posts" before its posts '
        'are read', () async {
      profiles
        ..refreshedUser = ada
        ..refreshedPosts = [p1];
      final cubit = buildCubit();
      addTearDown(cubit.close);
      final states = <ProfileState>[];
      final subscription = cubit.stream.listen(states.add);
      addTearDown(subscription.cancel);

      await cubit.load();
      await pumpEventQueue();

      expect(
        states.whereType<ProfileLoaded>().where(
          (state) => state.posts.isEmpty && !state.isLoadingPosts,
        ),
        isEmpty,
      );
      expect(states.last, ProfileState.loaded(user: ada, posts: [p1]));
    });

    blocTest<ProfileCubit, ProfileState>(
      'someone with no posts: loaded, with none once they are fetched',
      setUp: () => profiles.refreshedUser = ada,
      build: buildCubit,
      act: (cubit) => cubit.load(),
      expect: () => [
        const ProfileState.loaded(user: ada, isLoadingPosts: true),
        const ProfileState.loaded(user: ada),
      ],
    );

    blocTest<ProfileCubit, ProfileState>(
      'an unknown user is "not available", never an endless spinner',
      setUp: () => profiles.refreshUserResult = const Err(NotFoundException()),
      build: buildCubit,
      act: (cubit) => cubit.load(),
      expect: () => [const ProfileState.notFound()],
    );

    blocTest<ProfileCubit, ProfileState>(
      "the server's not-found wins over a stale cached copy",
      setUp: () =>
          profiles = FakeProfileRepository(cachedUsers: [ada])
            ..refreshUserResult = const Err(NotFoundException()),
      build: buildCubit,
      act: (cubit) => cubit.load(),
      expect: () => [
        const ProfileState.loaded(user: ada, isLoadingPosts: true),
        const ProfileState.notFound(),
      ],
    );

    blocTest<ProfileCubit, ProfileState>(
      'nothing cached and the refresh fails: the error; Try again loads',
      setUp: () => profiles.refreshUserResult = const Err(NetworkException()),
      build: buildCubit,
      act: (cubit) async {
        await cubit.load();
        profiles
          ..refreshUserResult = const Ok(null)
          ..refreshedUser = ada;
        await cubit.load();
      },
      expect: () => [
        ProfileState.error(networkError),
        const ProfileState.loading(),
        const ProfileState.loaded(user: ada),
      ],
    );

    blocTest<ProfileCubit, ProfileState>(
      'a cached profile stays when the refresh fails, and a message says so',
      setUp: () => profiles = FakeProfileRepository(
        cachedUsers: [ada],
        cachedPosts: {
          'u_ada': [p1],
        },
      )..refreshUserResult = const Err(NetworkException()),
      build: buildCubit,
      act: (cubit) => cubit.load(),
      expect: () => [
        ProfileState.loaded(user: ada, posts: [p1]),
        ProfileState.loaded(
          user: ada,
          posts: [p1],
          message: const UiMessage(
            id: 1,
            text: ProfileCubit.refreshFailedMessage,
          ),
        ),
      ],
    );

    blocTest<ProfileCubit, ProfileState>(
      'the profile loads but its posts fail: the profile shows, with a '
      'message',
      setUp: () => profiles
        ..refreshedUser = ada
        ..refreshPostsResult = const Err(NetworkException()),
      build: buildCubit,
      act: (cubit) => cubit.load(),
      expect: () => [
        const ProfileState.loaded(user: ada, isLoadingPosts: true),
        const ProfileState.loaded(
          user: ada,
          message: UiMessage(id: 1, text: ProfileCubit.postsFailedMessage),
        ),
      ],
    );
  });

  test('an edit shows at once: the header follows the cache', () async {
    profiles = FakeProfileRepository(cachedUsers: [ada]);
    final cubit = buildCubit();
    addTearDown(cubit.close);
    await cubit.load();

    profiles.replaceUser(ada.copyWith(name: 'Ada King'));
    await pumpEventQueue();

    expect(
      cubit.state,
      isA<ProfileLoaded>().having((s) => s.user.name, 'name', 'Ada King'),
    );
  });

  blocTest<ProfileCubit, ProfileState>(
    'a like that fails says so',
    setUp: () {
      profiles = FakeProfileRepository(
        cachedUsers: [ada],
        cachedPosts: {
          'u_ada': [p1],
        },
      );
      posts.likeResult = const Err(NetworkException());
    },
    build: buildCubit,
    act: (cubit) async {
      await pumpEventQueue();
      await cubit.toggleLike(p1);
    },
    expect: () => [
      ProfileState.loaded(user: ada, posts: [p1]),
      ProfileState.loaded(
        user: ada,
        posts: [p1],
        message: const UiMessage(id: 1, text: ProfileCubit.likeFailedMessage),
      ),
    ],
    verify: (_) => expect(posts.likeCalls, [(postId: 'p1', liked: true)]),
  );
}
