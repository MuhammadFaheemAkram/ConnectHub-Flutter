import 'dart:math';

import 'package:connect_hub/core/common/app_exception.dart';
import 'package:connect_hub/core/common/demo_account.dart';
import 'package:connect_hub/core/common/id_generator.dart';
import 'package:connect_hub/core/network/asset_json_loader.dart';
import 'package:connect_hub/core/network/fake_server/fake_server.dart';
import 'package:connect_hub/core/network/fake_server/seed_loader.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // The real bundled seed JSON, read through the test asset bundle.
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakeServer server;

  FakeServer newServer() => FakeServer(
    SeedLoader(AssetJsonLoader(rootBundle)),
    IdGenerator(random: Random(1)),
  );

  setUp(() => server = newServer());

  group('seed', () {
    test("the demo user's seed email is the demo account's", () async {
      final demo = await SeedLoader(AssetJsonLoader(rootBundle)).loadAuthUser();

      expect(demo.email, DemoAccount.email);
      expect(demo.id, 'u_demo');
      expect(demo.name, 'Demo User');
    });
  });

  group('login', () {
    test('the demo account signs in and gets a token for its user', () async {
      final response = await server.login(
        email: DemoAccount.email,
        password: DemoAccount.password,
      );

      expect(response.user.id, 'u_demo');
      expect(response.user.email, DemoAccount.email);
      expect(response.token, startsWith('fake.u_demo.'));
    });

    test('the email is matched ignoring case and surrounding spaces', () async {
      final response = await server.login(
        email: '  DEMO@ConnectHub.App ',
        password: DemoAccount.password,
      );

      expect(response.user.id, 'u_demo');
    });

    test('a wrong password and an unknown email fail the same way', () {
      expect(
        server.login(email: DemoAccount.email, password: 'wrong-password'),
        throwsA(isA<InvalidCredentialsException>()),
      );
      expect(
        server.login(email: 'nobody@example.com', password: 'whatever'),
        throwsA(isA<InvalidCredentialsException>()),
      );
    });
  });

  group('sign up', () {
    test('creates an account that can then sign in', () async {
      final created = await server.signUp(
        name: '  Ada Lovelace ',
        email: 'Ada@Example.com',
        password: 'engines',
      );

      expect(created.user.name, 'Ada Lovelace');
      expect(created.user.email, 'ada@example.com');
      expect(created.user.bio, 'New to ConnectHub 👋');
      expect(created.user.avatarUrl, isNull);
      expect(created.user.followersCount, 0);
      expect(created.user.followingCount, 0);

      final signedIn = await server.login(
        email: 'ada@example.com',
        password: 'engines',
      );
      expect(signedIn.user.id, created.user.id);
    });

    test('rejects an email that already has an account, in any case', () {
      expect(
        server.signUp(
          name: 'Impostor',
          email: 'Demo@ConnectHub.app',
          password: 'secret1',
        ),
        throwsA(isA<EmailTakenException>()),
      );
    });
  });

  group('tokens', () {
    test('a token it issued resolves to its user', () async {
      final response = await server.login(
        email: DemoAccount.email,
        password: DemoAccount.password,
      );

      expect(await server.authenticate(response.token), 'u_demo');
    });

    test('a missing or malformed token is rejected', () {
      for (final token in [
        null,
        '',
        'garbage',
        'jwt.u_demo.x',
        'fake.u_demo',
      ]) {
        expect(
          server.authenticate(token),
          throwsA(isA<UnauthorizedException>()),
          reason: 'token: $token',
        );
      }
    });

    test('a revoked token is rejected', () async {
      final response = await server.login(
        email: DemoAccount.email,
        password: DemoAccount.password,
      );

      server.revoke(response.token);

      expect(
        server.authenticate(response.token),
        throwsA(isA<UnauthorizedException>()),
      );
    });

    test(
      'the demo session survives a restart, a signed-up one does not',
      () async {
        final demo = await server.login(
          email: DemoAccount.email,
          password: DemoAccount.password,
        );
        final created = await server.signUp(
          name: 'Ada',
          email: 'ada@example.com',
          password: 'engines',
        );

        // A new server instance is what the next app launch sees.
        final restarted = newServer();

        expect(await restarted.authenticate(demo.token), 'u_demo');
        expect(
          restarted.authenticate(created.token),
          throwsA(isA<UnauthorizedException>()),
        );
      },
    );
  });
}
