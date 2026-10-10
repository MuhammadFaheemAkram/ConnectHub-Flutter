/// Form validation rules. Each returns an error message, or `null` when the
/// value is valid.
///
/// Pure functions, shared by every form and tested rule by rule. Emails and
/// names are trimmed before they are checked (and before they are sent).
/// Passwords are never trimmed: spaces are legal password characters.
abstract final class Validators {
  // The iOS edition's pattern: a local part, "@", a domain and a 2+ letter TLD.
  static final _email = RegExp(
    r'^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}$',
    caseSensitive: false,
  );

  static const passwordMinLength = 6;
  static const nameMinLength = 2;
  static const nameMaxLength = 50;

  static String? email(String value) {
    final email = value.trim();
    if (email.isEmpty) return 'Email is required.';
    if (!_email.hasMatch(email)) return 'Enter a valid email address.';
    return null;
  }

  static String? password(String value) {
    if (value.isEmpty) return 'Password is required.';
    if (value.length < passwordMinLength) {
      return 'Password must be at least $passwordMinLength characters.';
    }
    return null;
  }

  static String? confirmPassword(String password, String confirmation) {
    if (confirmation.isEmpty) return 'Please confirm your password.';
    if (confirmation != password) return "Passwords don't match.";
    return null;
  }

  static String? name(String value) {
    final name = value.trim();
    if (name.isEmpty) return 'Name is required.';
    if (name.length < nameMinLength) {
      return 'Name must be at least $nameMinLength characters.';
    }
    if (name.length > nameMaxLength) {
      return 'Name must be $nameMaxLength characters or fewer.';
    }
    return null;
  }
}
