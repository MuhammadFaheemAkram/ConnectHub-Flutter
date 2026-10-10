import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:connect_hub/core/common/app_exception.dart';
import 'package:connect_hub/core/common/form_status.dart';
import 'package:connect_hub/core/common/result.dart';
import 'package:connect_hub/domain/usecase/sign_up_use_case.dart';
import 'package:connect_hub/features/auth/sign_up/bloc/sign_up_bloc.dart';
import 'package:connect_hub/features/auth/sign_up/bloc/sign_up_event.dart';
import 'package:connect_hub/features/auth/sign_up/bloc/sign_up_state.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fakes/fake_auth_repository.dart';

void main() {
  late FakeAuthRepository auth;

  setUp(() => auth = FakeAuthRepository());

  SignUpBloc buildBloc() => SignUpBloc(SignUpUseCase(auth));

  const valid = SignUpState(
    name: ' Ada Lovelace ',
    email: ' ada@example.com ',
    password: 'engines',
    confirmPassword: 'engines',
  );

  blocTest<SignUpBloc, SignUpState>(
    'stores every field as it is typed',
    build: buildBloc,
    act: (bloc) => bloc
      ..add(const SignUpNameChanged(' Ada Lovelace '))
      ..add(const SignUpEmailChanged(' ada@example.com '))
      ..add(const SignUpPasswordChanged('engines'))
      ..add(const SignUpConfirmPasswordChanged('engines')),
    skip: 3,
    expect: () => [valid],
  );

  test('field errors appear only after the first submit', () {
    const blank = SignUpState();
    expect(blank.nameError, isNull);

    final shown = blank.copyWith(showErrors: true, password: 'engines');
    expect(shown.nameError, 'Name is required.');
    expect(shown.emailError, 'Email is required.');
    expect(shown.passwordError, isNull);
    expect(shown.confirmPasswordError, 'Please confirm your password.');
    expect(
      shown.copyWith(confirmPassword: 'other').confirmPasswordError,
      "Passwords don't match.",
    );
  });

  blocTest<SignUpBloc, SignUpState>(
    'an invalid form shows its errors and sends nothing',
    build: buildBloc,
    seed: () => valid.copyWith(confirmPassword: 'different'),
    act: (bloc) => bloc.add(const SignUpSubmitted()),
    expect: () => [
      valid.copyWith(confirmPassword: 'different', showErrors: true),
    ],
    verify: (_) => expect(auth.signUpCalls, isEmpty),
  );

  blocTest<SignUpBloc, SignUpState>(
    'a valid form signs up with the trimmed name and email',
    build: buildBloc,
    seed: () => valid,
    act: (bloc) => bloc.add(const SignUpSubmitted()),
    expect: () => [
      valid.copyWith(showErrors: true, status: FormStatus.submitting),
      valid.copyWith(showErrors: true, status: FormStatus.success),
    ],
    verify: (_) => expect(auth.signUpCalls, [
      (name: 'Ada Lovelace', email: 'ada@example.com', password: 'engines'),
    ]),
  );

  blocTest<SignUpBloc, SignUpState>(
    'a taken email shows the server\'s message',
    setUp: () => auth.result = const Err(EmailTakenException()),
    build: buildBloc,
    seed: () => valid,
    act: (bloc) => bloc.add(const SignUpSubmitted()),
    expect: () => [
      valid.copyWith(showErrors: true, status: FormStatus.submitting),
      valid.copyWith(
        showErrors: true,
        status: FormStatus.failure,
        errorMessage: 'An account with this email already exists.',
      ),
    ],
  );

  blocTest<SignUpBloc, SignUpState>(
    'a double tap creates one account (droppable)',
    setUp: () => auth.gate = Completer<void>(),
    build: buildBloc,
    seed: () => valid,
    act: (bloc) async {
      bloc
        ..add(const SignUpSubmitted())
        ..add(const SignUpSubmitted());
      await pumpEventQueue();
      auth.gate!.complete();
    },
    skip: 1,
    expect: () => [
      valid.copyWith(showErrors: true, status: FormStatus.success),
    ],
    verify: (_) => expect(auth.signUpCalls, hasLength(1)),
  );
}
