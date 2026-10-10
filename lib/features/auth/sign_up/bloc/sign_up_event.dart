/// What the user does on the Sign Up form.
sealed class SignUpEvent {
  const SignUpEvent();
}

final class SignUpNameChanged extends SignUpEvent {
  const SignUpNameChanged(this.name);

  final String name;
}

final class SignUpEmailChanged extends SignUpEvent {
  const SignUpEmailChanged(this.email);

  final String email;
}

final class SignUpPasswordChanged extends SignUpEvent {
  const SignUpPasswordChanged(this.password);

  final String password;
}

final class SignUpConfirmPasswordChanged extends SignUpEvent {
  const SignUpConfirmPasswordChanged(this.confirmPassword);

  final String confirmPassword;
}

final class SignUpSubmitted extends SignUpEvent {
  const SignUpSubmitted();
}
