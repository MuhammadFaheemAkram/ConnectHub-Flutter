import 'package:connect_hub/core/common/app_exception.dart';
import 'package:connect_hub/core/common/result.dart';
import 'package:connect_hub/data/repository/api_guard.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fakes/fake_session_repository.dart';

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

  test('programming errors are not swallowed', () {
    expect(
      guard.run<int>(() async => throw StateError('bug')),
      throwsStateError,
    );
  });
}
