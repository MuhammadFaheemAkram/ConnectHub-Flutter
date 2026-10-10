/// What can happen to the app-wide session.
sealed class AuthEvent {
  const AuthEvent();
}

/// Start following the saved session (sent once, when the app starts).
final class AuthSubscriptionRequested extends AuthEvent {
  const AuthSubscriptionRequested();
}

/// The user asked to log out.
final class AuthLogoutRequested extends AuthEvent {
  const AuthLogoutRequested();
}
