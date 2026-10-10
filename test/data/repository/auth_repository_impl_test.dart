import 'dart:math';

import 'package:connect_hub/core/common/app_exception.dart';
import 'package:connect_hub/core/common/demo_account.dart';
import 'package:connect_hub/core/common/id_generator.dart';
import 'package:connect_hub/core/common/result.dart';
import 'package:connect_hub/core/network/api/fake_auth_api_service.dart';
import 'package:connect_hub/core/network/asset_json_loader.dart';
import 'package:connect_hub/core/network/fake_server/fake_server.dart';
import 'package:connect_hub/core/network/fake_server/network_simulator.dart';
import 'package:connect_hub/core/network/fake_server/seed_loader.dart';
import 'package:connect_hub/data/repository/api_guard.dart';
import 'package:connect_hub/data/repository/auth_repository_impl.dart';
import 'package:connect_hub/domain/model/session.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fakes/fake_session_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakeSessionRepository sessions;
  late NetworkSimulator network;
  late AuthRepositoryImpl repository;

  setUp(() {
    sessions = FakeSessionRepository();
    network = NetworkSimulator(latencyFactor: 0);
    // The fake server *is* the backend double here: the real API service
    // and server, with no latency.
    repository = AuthRepositoryImpl(
      FakeAuthApiService(
        FakeServer(
          SeedLoader(AssetJsonLoader(rootBundle)),
          IdGenerator(random: Random(1)),
        ),
        network,
      ),
      sessions,
      ApiGuard(sessions),
    );
  });

  tearDown(() => sessions.dispose());

  test('a successful sign-in returns the session and saves it', () async {
    final result = await repository.login(
      email: DemoAccount.email,
      password: DemoAccount.password,
    );

    final session = (result as Ok<Session>).value;
    expect(session.userId, 'u_demo');
    expect(session.email, DemoAccount.email);
    expect(session.token, startsWith('fake.u_demo.'));
    expect(sessions.saved, [session]);
  });

  test('a rejected sign-in returns the reason and saves nothing', () async {
    final result = await repository.login(
      email: DemoAccount.email,
      password: 'wrong-password',
    );

    expect(
      (result as Err<Session>).exception,
      isA<InvalidCredentialsException>(),
    );
    expect(sessions.saved, isEmpty);
  });

  test('a network failure is an Err, not an exception', () async {
    network.failRequests = true;

    final result = await repository.login(
      email: DemoAccount.email,
      password: DemoAccount.password,
    );

    expect((result as Err<Session>).exception, isA<NetworkException>());
  });

  test('sign-up saves the new account\'s session', () async {
    final result = await repository.signUp(
      name: 'Ada',
      email: 'ada@example.com',
      password: 'engines',
    );

    final session = (result as Ok<Session>).value;
    expect(session.email, 'ada@example.com');
    expect(sessions.saved, [session]);
  });

  test('logout clears the session', () async {
    await repository.logout();

    expect(sessions.clearCalls, 1);
  });
}
