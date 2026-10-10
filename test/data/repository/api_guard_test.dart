import 'package:connect_hub/core/common/app_exception.dart';
import 'package:connect_hub/core/common/result.dart';
import 'package:connect_hub/data/repository/api_guard.dart';
import 'package:connect_hub/domain/model/session.dart';
import 'package:connect_hub/domain/model/session_state.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fakes/fake_session_repository.dart';
import '../../helpers/fixtures.dart';

const otherSession = Session(
  userId: 'u_other',
  email: 'other@example.com',
  token: 'fake.u_other.0000',
);

void main() {
  late FakeSessionRepository sessions;
  late ApiGuard guard;

  setUp(() {
    sessions = FakeSessionRepository();
    guard = ApiGuard(sessions);
  });

  tearDown(() => sessions.dispose());

  test('wraps a value in Ok', () async {
    final result = await guard.run(() async => 42);

    expect(result, isA<Ok<int>>().having((ok) => ok.value, 'value', 42));
  });

  test('turns an AppException into Err', () async {
    final result = await guard.run<int>(
      () async => throw const NetworkException(),
    );

    expect(
      result,
      isA<Err<int>>().having(
        (e) => e.exception,
        'exception',
        isA<NetworkException>(),
      ),
    );
    expect(sessions.expireCalls, 0);
  });

  test('a 401 expires the session, once, for every caller', () async {
    final result = await guard.run<int>(
      () async => throw const UnauthorizedException(),
    );

    expect(result, isA<Err<int>>());
    expect(sessions.expireCalls, 1);
  });

  test('an unexpected exception becomes a generic UnknownException', () async {
    final result = await guard.run<int>(
      () async => throw const FormatException('boom'),
    );

    expect(
      result,
      isA<Err<int>>().having(
        (e) => e.exception,
        'exception',
        isA<UnknownException>(),
      ),
    );
  });

  group('a request belongs to the session that sent it', () {
    late FakeSessionRepository signedIn;
    late ApiGuard signedInGuard;

    setUp(() {
      signedIn = FakeSessionRepository(
        initial: const SessionState.signedIn(demoSession),
      );
      signedInGuard = ApiGuard(signedIn);
    });

    tearDown(() => signedIn.dispose());

    test('an answer that arrives after logout is dropped, not cached for '
        'the next user', () async {
      final result = await signedInGuard.run(() async {
        await signedIn.clear(); // the user logs out while it is in flight
        return 42;
      });

      expect(
        result,
        isA<Err<int>>().having(
          (e) => e.exception,
          'exception',
          isA<UnauthorizedException>(),
        ),
      );
    });

    test('a late 401 for an earlier session does not sign out the user who '
        'is signed in now', () async {
      await signedInGuard.run<int>(() async {
        await signedIn.clear();
        await signedIn.save(otherSession); // someone else signs in
        throw const UnauthorizedException();
      });

      expect(signedIn.expireCalls, 0);
      expect(signedIn.currentSession, otherSession);
    });
  });

  test('programming errors are not swallowed', () {
    expect(
      guard.run<int>(() async => throw StateError('bug')),
      throwsStateError,
    );
  });
}
