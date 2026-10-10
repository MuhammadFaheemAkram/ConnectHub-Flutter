import 'package:bloc_test/bloc_test.dart';
import 'package:connect_hub/domain/model/session_state.dart';
import 'package:connect_hub/domain/usecase/logout_use_case.dart';
import 'package:connect_hub/domain/usecase/watch_session_use_case.dart';
import 'package:connect_hub/features/auth/bloc/auth_bloc.dart';
import 'package:connect_hub/features/auth/bloc/auth_event.dart';
import 'package:connect_hub/features/auth/bloc/auth_state.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fakes/fake_auth_repository.dart';
import '../../../helpers/fakes/fake_session_repository.dart';
import '../../../helpers/fixtures.dart';

void main() {
  late FakeSessionRepository sessions;
  late FakeAuthRepository auth;

  setUp(() {
    sessions = FakeSessionRepository();
    auth = FakeAuthRepository(onLogout: () => sessions.clear());
  });

  tearDown(() => sessions.dispose());

  AuthBloc buildBloc() =>
      AuthBloc(WatchSessionUseCase(sessions), LogoutUseCase(auth));

  test('starts unknown, until the session is restored', () {
    expect(buildBloc().state, const AuthState.unknown());
  });

  blocTest<AuthBloc, AuthState>(
    'a restored session is authenticated',
    setUp: () => sessions = FakeSessionRepository(
      initial: const SessionState.signedIn(demoSession),
    ),
    build: buildBloc,
    act: (bloc) => bloc.add(const AuthSubscriptionRequested()),
    expect: () => [const AuthState.authenticated(demoSession)],
  );

  blocTest<AuthBloc, AuthState>(
    'no saved session is unauthenticated, for no particular reason',
    build: buildBloc,
    act: (bloc) => bloc.add(const AuthSubscriptionRequested()),
    expect: () => [const AuthState.unauthenticated()],
  );

  blocTest<AuthBloc, AuthState>(
    'follows every later change of the session',
    build: buildBloc,
    act: (bloc) async {
      bloc.add(const AuthSubscriptionRequested());
      await pumpEventQueue();
      await sessions.save(demoSession);
      await sessions.expire();
    },
    expect: () => [
      const AuthState.unauthenticated(),
      const AuthState.authenticated(demoSession),
      const AuthState.unauthenticated(reason: SignOutReason.expired),
    ],
  );

  blocTest<AuthBloc, AuthState>(
    'logging out clears the session; the new state comes from the stream',
    setUp: () => sessions = FakeSessionRepository(
      initial: const SessionState.signedIn(demoSession),
    ),
    build: buildBloc,
    act: (bloc) async {
      bloc.add(const AuthSubscriptionRequested());
      await pumpEventQueue();
      bloc.add(const AuthLogoutRequested());
    },
    expect: () => [
      const AuthState.authenticated(demoSession),
      const AuthState.unauthenticated(reason: SignOutReason.loggedOut),
    ],
    verify: (_) => expect(auth.logoutCalls, 1),
  );
}
