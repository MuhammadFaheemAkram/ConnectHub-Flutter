import 'package:connect_hub/core/navigation/app_routes.dart';
import 'package:connect_hub/core/navigation/auth_redirect.dart';
import 'package:connect_hub/domain/model/session_state.dart';
import 'package:connect_hub/features/auth/bloc/auth_state.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fixtures.dart';

void main() {
  String? redirect(AuthState auth, String location) =>
      authRedirect(auth, Uri.parse(location));

  const unknown = AuthState.unknown();
  const signedOut = AuthState.unauthenticated();
  const loggedOut = AuthState.unauthenticated(reason: SignOutReason.loggedOut);
  const expired = AuthState.unauthenticated(reason: SignOutReason.expired);
  const signedIn = AuthState.authenticated(demoSession);

  String login({String? from}) => LoginRoute(from: from).location;
  String splash({String? from}) => SplashRoute(from: from).location;

  group('while the session is being restored', () {
    test('everything waits on the splash', () {
      expect(redirect(unknown, '/feed'), splash());
      expect(redirect(unknown, '/'), splash());
      expect(redirect(unknown, '/splash'), isNull);
    });

    test('a deep link is remembered as the return address', () {
      expect(redirect(unknown, '/posts/p3'), splash(from: '/posts/p3'));
      expect(
        redirect(unknown, '/login?from=%2Fchats%2Fc1'),
        splash(from: '/chats/c1'),
      );
    });
  });

  group('signed out', () {
    test('only the auth routes are reachable', () {
      expect(redirect(signedOut, '/login'), isNull);
      expect(redirect(signedOut, '/login/signup?from=%2Fposts%2Fp3'), isNull);
      expect(redirect(signedOut, '/feed'), login());
    });

    test('a deep link goes to Login with its return address', () {
      expect(redirect(signedOut, '/posts/p3'), login(from: '/posts/p3'));
      expect(
        redirect(signedOut, '/splash?from=%2Fposts%2Fp3'),
        login(from: '/posts/p3'),
      );
    });

    test('after an expired session, Login remembers where the user was', () {
      expect(redirect(expired, '/chats/c1'), login(from: '/chats/c1'));
    });

    test('after a deliberate logout, nothing is remembered', () {
      expect(redirect(loggedOut, '/settings'), login());
    });

    test('a path that merely starts with "login" is not an auth route', () {
      expect(redirect(signedOut, '/loginx'), login(from: '/loginx'));
    });
  });

  group('signed in', () {
    test('the gate screens lead to the Feed', () {
      expect(redirect(signedIn, '/login'), '/feed');
      expect(redirect(signedIn, '/login/signup'), '/feed');
      expect(redirect(signedIn, '/splash'), '/feed');
      expect(redirect(signedIn, '/'), '/feed');
    });

    test('...or to the return address, query included', () {
      expect(redirect(signedIn, '/login?from=%2Fposts%2Fp3'), '/posts/p3');
      expect(
        redirect(signedIn, '/login/signup?from=%2Fchats%2Fc1'),
        '/chats/c1',
      );
      expect(
        redirect(signedIn, '/splash?from=%2Fposts%2Fp3%3Ftab%3D2'),
        '/posts/p3?tab=2',
      );
    });

    test('everything else is allowed', () {
      expect(redirect(signedIn, '/feed'), isNull);
      expect(redirect(signedIn, '/posts/p1/comments'), isNull);
      expect(redirect(signedIn, '/settings'), isNull);
    });
  });

  group('only safe, in-app return addresses are followed', () {
    for (final from in [
      'https://evil.example/steal',
      '//evil.example/steal',
      'posts/p1',
      '/login',
      '/login/signup',
      '/splash',
      '/',
      '/feed',
    ]) {
      test('"$from" is ignored', () {
        expect(
          redirect(signedIn, '/login?from=${Uri.encodeComponent(from)}'),
          '/feed',
        );
      });
    }
  });
}
