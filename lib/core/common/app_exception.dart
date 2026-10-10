/// The app's error vocabulary.
///
/// Every failure that can reach the UI is one of these types, and each carries
/// a user-facing [message], so screens render a small, stable set of error
/// states instead of raw exceptions. The messages follow the iOS edition's
/// `AppError`.
///
/// `sealed` lets the compiler check that a `switch` over an [AppException]
/// handles every subtype.
sealed class AppException implements Exception {
  const AppException(this.message);

  /// Copy that is safe to show to the user.
  final String message;

  @override
  String toString() => '$runtimeType: $message';
}

/// The (fake) network call failed.
final class NetworkException extends AppException {
  const NetworkException()
    : super('Something went wrong with your connection. Please try again.');
}

/// The requested item does not exist.
final class NotFoundException extends AppException {
  const NotFoundException()
    : super("We couldn't find what you were looking for.");
}

/// The server no longer accepts the session's token (HTTP 401). Repositories
/// never show this one directly: `ApiGuard` turns it into a session expiry.
final class UnauthorizedException extends AppException {
  const UnauthorizedException()
    : super('Your session has expired. Please sign in again.');
}

/// Sign-in with an unknown email or a wrong password. Deliberately one message
/// for both, so the screen doesn't reveal which emails have accounts.
final class InvalidCredentialsException extends AppException {
  const InvalidCredentialsException() : super('Incorrect email or password.');
}

/// Sign-up with an email that already has an account.
final class EmailTakenException extends AppException {
  const EmailTakenException()
    : super('An account with this email already exists.');
}

/// The data could not be decoded (malformed JSON or unexpected types).
final class DataFormatException extends AppException {
  const DataFormatException()
    : super('We received an unexpected response. Please try again.');
}

/// Anything unexpected that isn't one of the cases above.
final class UnknownException extends AppException {
  const UnknownException() : super('Something went wrong. Please try again.');
}
