/// The demo account that always exists in the fake server.
///
/// Shared by the fake server (which seeds it) and the Login screen's "Use demo
/// account" button, so the two can't drift apart. The email must match
/// `assets/json/auth_user.json` (a test checks it).
abstract final class DemoAccount {
  static const email = 'demo@connecthub.app';

  /// A fake backend can keep a plain password. A real one never stores
  /// passwords at all, only a slow salted hash (bcrypt, scrypt, Argon2).
  static const password = 'connecthub';
}
