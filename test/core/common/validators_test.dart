import 'package:connect_hub/core/common/validators.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('email', () {
    test('is required (whitespace counts as empty)', () {
      expect(Validators.email(''), 'Email is required.');
      expect(Validators.email('   '), 'Email is required.');
    });

    for (final valid in ['ada@example.com', ' Ada.L+1@mail.co.uk ']) {
      test('accepts "$valid"', () => expect(Validators.email(valid), isNull));
    }

    for (final invalid in [
      'ada',
      'ada@',
      '@example.com',
      'ada@example',
      'a@b.c',
    ]) {
      test('rejects "$invalid"', () {
        expect(Validators.email(invalid), 'Enter a valid email address.');
      });
    }
  });

  group('password', () {
    test('is required', () {
      expect(Validators.password(''), 'Password is required.');
    });

    test('needs at least 6 characters', () {
      expect(
        Validators.password('12345'),
        'Password must be at least 6 characters.',
      );
      expect(Validators.password('123456'), isNull);
    });

    test('is not trimmed: spaces are legal password characters', () {
      expect(Validators.password('      '), isNull);
    });
  });

  group('confirm password', () {
    test('is required', () {
      expect(
        Validators.confirmPassword('secret1', ''),
        'Please confirm your password.',
      );
    });

    test('must match the password', () {
      expect(
        Validators.confirmPassword('secret1', 'secret2'),
        "Passwords don't match.",
      );
      expect(Validators.confirmPassword('secret1', 'secret1'), isNull);
    });
  });

  group('name', () {
    test('is required (whitespace counts as empty)', () {
      expect(Validators.name(' '), 'Name is required.');
    });

    test('is 2 to 50 characters, after trimming', () {
      expect(Validators.name(' A '), 'Name must be at least 2 characters.');
      expect(Validators.name('Al'), isNull);
      expect(Validators.name('a' * 50), isNull);
      expect(Validators.name('a' * 51), 'Name must be 50 characters or fewer.');
    });
  });
}
