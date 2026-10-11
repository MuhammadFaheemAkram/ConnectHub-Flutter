import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:connect_hub/core/common/app_exception.dart';
import 'package:connect_hub/core/common/form_status.dart';
import 'package:connect_hub/core/common/result.dart';
import 'package:connect_hub/domain/model/user.dart';
import 'package:connect_hub/domain/usecase/refresh_user_use_case.dart';
import 'package:connect_hub/domain/usecase/update_profile_use_case.dart';
import 'package:connect_hub/domain/usecase/watch_user_use_case.dart';
import 'package:connect_hub/features/edit_profile/cubit/edit_profile_cubit.dart';
import 'package:connect_hub/features/edit_profile/cubit/edit_profile_state.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fakes/fake_profile_repository.dart';

void main() {
  late FakeProfileRepository profiles;

  const me = User(
    id: 'u_demo',
    name: 'Demo User',
    bio: 'Exploring ConnectHub.',
    avatarUrl: 'https://example.com/me.png',
  );

  /// The form as it starts, filled from [me].
  const filled = EditProfileState(
    original: me,
    name: 'Demo User',
    bio: 'Exploring ConnectHub.',
    avatarUrl: 'https://example.com/me.png',
  );

  setUp(() => profiles = FakeProfileRepository(cachedUsers: [me]));

  tearDown(() => profiles.dispose());

  EditProfileCubit buildCubit() => EditProfileCubit(
    'u_demo',
    WatchUserUseCase(profiles),
    RefreshUserUseCase(profiles),
    UpdateProfileUseCase(profiles),
  );

  /// A cubit with the form loaded.
  Future<EditProfileCubit> loaded() async {
    final cubit = buildCubit();
    addTearDown(cubit.close);
    await cubit.load();
    return cubit;
  }

  group('loading', () {
    blocTest<EditProfileCubit, EditProfileState>(
      'fills the form from the cached profile, without a request',
      build: buildCubit,
      act: (cubit) => cubit.load(),
      expect: () => [filled],
      verify: (_) => expect(profiles.refreshUserCalls, isEmpty),
    );

    blocTest<EditProfileCubit, EditProfileState>(
      'not cached (e.g. after signing in again): fetches it first',
      setUp: () => profiles = FakeProfileRepository()..refreshedUser = me,
      build: buildCubit,
      act: (cubit) => cubit.load(),
      expect: () => [filled],
      verify: (_) => expect(profiles.refreshUserCalls, ['u_demo']),
    );

    blocTest<EditProfileCubit, EditProfileState>(
      'a failed fetch says why; Try again loads it',
      setUp: () =>
          profiles = FakeProfileRepository()
            ..refreshUserResult = const Err(NetworkException()),
      build: buildCubit,
      act: (cubit) async {
        await cubit.load();
        profiles
          ..refreshUserResult = const Ok(null)
          ..refreshedUser = me;
        await cubit.load();
      },
      expect: () => [
        EditProfileState(loadError: const NetworkException().message),
        const EditProfileState(),
        filled,
      ],
    );
  });

  group('validation', () {
    test('a loaded, untouched form is valid but has nothing to save', () async {
      final cubit = await loaded();

      expect(cubit.state.isValid, isTrue);
      expect(cubit.state.hasChanges, isFalse);
      expect(cubit.state.canSave, isFalse);
    });

    test('errors show the moment an edit breaks a rule', () async {
      final cubit = await loaded();

      cubit
        ..nameChanged('')
        ..bioChanged('a' * 161)
        ..avatarUrlChanged('not a url');

      expect(cubit.state.nameError, 'Name is required.');
      expect(cubit.state.bioError, 'Bio must be 160 characters or fewer.');
      expect(
        cubit.state.avatarUrlError,
        'Enter a valid image URL, or leave it empty.',
      );
      expect(cubit.state.bioLength, 161);
      expect(cubit.state.canSave, isFalse);
    });

    test('changes are compared as they would be saved (trimmed)', () async {
      final cubit = await loaded();

      cubit.nameChanged('  Demo User ');
      expect(cubit.state.hasChanges, isFalse);

      cubit.nameChanged('Demo Person');
      expect(cubit.state.hasChanges, isTrue);
      expect(cubit.state.canSave, isTrue);
    });

    test('clearing the avatar URL is a valid change', () async {
      final cubit = await loaded();

      cubit.avatarUrlChanged('');

      expect(cubit.state.avatarUrlError, isNull);
      expect(cubit.state.canSave, isTrue);
    });
  });

  group('saving', () {
    test('sends the trimmed values, then reports success (the View '
        'closes)', () async {
      final cubit = await loaded();
      cubit
        ..nameChanged(' Demo Person ')
        ..bioChanged(' Testing time. ')
        ..avatarUrlChanged('');

      await cubit.save();

      expect(profiles.updateCalls, [
        (name: 'Demo Person', bio: 'Testing time.', avatarUrl: null),
      ]);
      expect(cubit.state.status, FormStatus.success);
    });

    test('shows progress while saving, and a second save is ignored', () async {
      final cubit = await loaded();
      profiles.updateGate = Completer<void>();
      cubit.nameChanged('Demo Person');

      final saving = cubit.save();
      expect(cubit.state.status, FormStatus.submitting);
      expect(cubit.state.canSave, isFalse);
      await cubit.save();

      profiles.updateGate!.complete();
      await saving;
      expect(profiles.updateCalls, hasLength(1));
    });

    test('a failure keeps the input and says why; editing clears the '
        'error', () async {
      final cubit = await loaded();
      profiles.updateResult = const Err(NetworkException());
      cubit.nameChanged('Demo Person');

      await cubit.save();

      expect(cubit.state.status, FormStatus.failure);
      expect(cubit.state.errorMessage, const NetworkException().message);
      expect(cubit.state.name, 'Demo Person');

      cubit.nameChanged('Demo Person!');
      expect(cubit.state.status, FormStatus.idle);
      expect(cubit.state.errorMessage, isNull);
    });

    test('an invalid form never reaches the repository', () async {
      final cubit = await loaded();
      cubit.nameChanged('D');

      await cubit.save();

      expect(profiles.updateCalls, isEmpty);
    });
  });
}
