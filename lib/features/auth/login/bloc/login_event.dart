/// What the user does on the Login form.
sealed class LoginEvent {
  const LoginEvent();
}

final class LoginEmailChanged extends LoginEvent {
  const LoginEmailChanged(this.email);

  final String email;
}

final class LoginPasswordChanged extends LoginEvent {
  const LoginPasswordChanged(this.password);

  final String password;
}

/// "Use demo account": fill in the credentials of the demo account.
final class LoginDemoAccountRequested extends LoginEvent {
  const LoginDemoAccountRequested();
}

/// "Sign in", or the keyboard's done action.
final class LoginSubmitted extends LoginEvent {
  const LoginSubmitted();
}
