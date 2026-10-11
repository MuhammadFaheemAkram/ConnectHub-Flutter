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

  group('post content', () {
    test('is required (whitespace counts as empty)', () {
      expect(Validators.postContent(''), 'Write something to share.');
      expect(Validators.postContent('  \n '), 'Write something to share.');
    });

    test('is at most 280 characters, counted on the raw text', () {
      expect(Validators.postContent('a' * 280), isNull);
      expect(
        Validators.postContent('a' * 281),
        'Posts are limited to 280 characters.',
      );
      // Surrounding spaces count, exactly as the counter shows them.
      expect(
        Validators.postContent(' ${'a' * 279} '),
        'Posts are limited to 280 characters.',
      );
    });

    test('counts characters as people see them: an emoji is one', () {
      expect(Validators.lengthOf('👍🏽'), 1);
      expect('👍🏽'.length, 4);
      expect(Validators.postContent('👍🏽' * 280), isNull);
    });
  });

  group('bio', () {
    test('is optional', () => expect(Validators.bio(''), isNull));

    test('is at most 160 characters, as people count them', () {
      const message = 'Bio must be 160 characters or fewer.';
      expect(Validators.bio('a' * 160), isNull);
      expect(Validators.bio('a' * 161), message);
      expect(Validators.bio('👋' * 160), isNull);
    });
  });

  group('image URL', () {
    test('is optional', () {
      expect(Validators.imageUrl(''), isNull);
      expect(Validators.imageUrl('   '), isNull);
    });

    test('must be an http or https URL with a host (avatars too)', () {
      const message = 'Enter a valid image URL, or leave it empty.';
      expect(Validators.imageUrl('https://picsum.photos/600/400'), isNull);
      expect(Validators.imageUrl(' http://example.com/a.png '), isNull);
      expect(Validators.imageUrl('picsum.photos/600'), message);
      expect(Validators.imageUrl('ftp://example.com/a.png'), message);
      expect(Validators.imageUrl('https://'), message);
      expect(Validators.imageUrl('not a url'), message);
    });
  });
}
