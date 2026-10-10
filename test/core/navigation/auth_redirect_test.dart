import 'package:connect_hub/core/navigation/auth_redirect.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  String? redirect(String location, {required bool signedIn}) =>
      authRedirect(isSignedIn: signedIn, location: Uri.parse(location));

  group('signed out', () {
    test('a tab goes to Login', () {
      expect(redirect('/feed', signedIn: false), '/login');
    });

    test('a root-level screen (a deep link) goes to Login', () {
      expect(redirect('/posts/p1', signedIn: false), '/login');
      expect(redirect('/chats/c1', signedIn: false), '/login');
    });

    test('the splash and "/" go to Login', () {
      expect(redirect('/splash', signedIn: false), '/login');
      expect(redirect('/', signedIn: false), '/login');
    });

    test('Login and Sign Up are allowed', () {
      expect(redirect('/login', signedIn: false), isNull);
      expect(redirect('/login/signup', signedIn: false), isNull);
    });

    test('a path that merely starts with "login" is not an auth route', () {
      expect(redirect('/loginx', signedIn: false), '/login');
    });
  });

  group('signed in', () {
    test('Login, Sign Up, the splash and "/" go to the Feed', () {
      expect(redirect('/login', signedIn: true), '/feed');
      expect(redirect('/login/signup', signedIn: true), '/feed');
      expect(redirect('/splash', signedIn: true), '/feed');
      expect(redirect('/', signedIn: true), '/feed');
    });

    test('tabs and root-level screens are allowed', () {
      expect(redirect('/feed', signedIn: true), isNull);
      expect(redirect('/profile', signedIn: true), isNull);
      expect(redirect('/posts/p1/comments', signedIn: true), isNull);
      expect(redirect('/settings', signedIn: true), isNull);
    });
  });
}
