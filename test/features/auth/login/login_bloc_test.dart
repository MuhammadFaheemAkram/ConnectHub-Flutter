import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:connect_hub/core/common/app_exception.dart';
import 'package:connect_hub/core/common/demo_account.dart';
import 'package:connect_hub/core/common/form_status.dart';
import 'package:connect_hub/core/common/result.dart';
import 'package:connect_hub/domain/usecase/login_use_case.dart';
import 'package:connect_hub/features/auth/login/bloc/login_bloc.dart';
import 'package:connect_hub/features/auth/login/bloc/login_event.dart';
import 'package:connect_hub/features/auth/login/bloc/login_state.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fakes/fake_auth_repository.dart';

void main() {
  late FakeAuthRepository auth;

  setUp(() => auth = FakeAuthRepository());

  LoginBloc buildBloc() => LoginBloc(LoginUseCase(auth));

  const valid = LoginState(email: 'ada@example.com', password: 'engines');

  group('editing', () {
    blocTest<LoginBloc, LoginState>(
      'stores what is typed',
      build: buildBloc,
      act: (bloc) => bloc
        ..add(const LoginEmailChanged('ada@example.com'))
        ..add(const LoginPasswordChanged('engines')),
      expect: () => [const LoginState(email: 'ada@example.com'), valid],
    );

    test('stays quiet about errors until the first submit', () {
      const state = LoginState(email: 'not-an-email');

      expect(state.emailError, isNull);
      expect(state.passwordError, isNull);
    });

    test('after a submit, the errors follow the values live', () {
      const state = LoginState(email: 'not-an-email', showErrors: true);

      expect(state.emailError, 'Enter a valid email address.');
      expect(state.passwordError, 'Password is required.');
      expect(state.copyWith(email: 'ada@example.com').emailError, isNull);
    });

    blocTest<LoginBloc, LoginState>(
      'typing clears the previous server error',
      build: buildBloc,
      seed: () => valid.copyWith(
        status: FormStatus.failure,
        errorMessage: 'Incorrect email or password.',
      ),
      act: (bloc) => bloc.add(const LoginPasswordChanged('engines2')),
      expect: () => [valid.copyWith(password: 'engines2')],
    );

    blocTest<LoginBloc, LoginState>(
      '"Use demo account" fills in the demo credentials',
      build: buildBloc,
      act: (bloc) => bloc.add(const LoginDemoAccountRequested()),
      expect: () => [
        const LoginState(
          email: DemoAccount.email,
          password: DemoAccount.password,
        ),
      ],
    );
  });

  group('submitting', () {
    blocTest<LoginBloc, LoginState>(
      'an invalid form shows its errors and sends nothing',
      build: buildBloc,
      act: (bloc) => bloc.add(const LoginSubmitted()),
      expect: () => [const LoginState(showErrors: true)],
      verify: (_) => expect(auth.loginCalls, isEmpty),
    );

    blocTest<LoginBloc, LoginState>(
      'a valid form signs in with the trimmed email',
      build: buildBloc,
      seed: () => valid.copyWith(email: '  ada@example.com '),
      act: (bloc) => bloc.add(const LoginSubmitted()),
      expect: () => [
        valid.copyWith(
          email: '  ada@example.com ',
          showErrors: true,
          status: FormStatus.submitting,
        ),
        valid.copyWith(
          email: '  ada@example.com ',
          showErrors: true,
          status: FormStatus.success,
        ),
      ],
      verify: (_) => expect(auth.loginCalls, [
        (email: 'ada@example.com', password: 'engines'),
      ]),
    );

    blocTest<LoginBloc, LoginState>(
      'a rejected sign-in shows the server\'s message',
      setUp: () => auth.result = const Err(InvalidCredentialsException()),
      build: buildBloc,
      seed: () => valid,
      act: (bloc) => bloc.add(const LoginSubmitted()),
      expect: () => [
        valid.copyWith(showErrors: true, status: FormStatus.submitting),
        valid.copyWith(
          showErrors: true,
          status: FormStatus.failure,
          errorMessage: 'Incorrect email or password.',
        ),
      ],
    );

    blocTest<LoginBloc, LoginState>(
      'a second submit while signing in is dropped (droppable)',
      setUp: () => auth.gate = Completer<void>(),
      build: buildBloc,
      seed: () => valid,
      act: (bloc) async {
        bloc
          ..add(const LoginSubmitted())
          ..add(const LoginSubmitted());
        await pumpEventQueue();
        auth.gate!.complete();
      },
      expect: () => [
        valid.copyWith(showErrors: true, status: FormStatus.submitting),
        valid.copyWith(showErrors: true, status: FormStatus.success),
      ],
      verify: (_) => expect(auth.loginCalls, hasLength(1)),
    );
  });
}
