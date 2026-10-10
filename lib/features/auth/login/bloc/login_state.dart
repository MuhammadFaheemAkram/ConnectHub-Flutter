import 'package:connect_hub/core/common/form_status.dart';
import 'package:connect_hub/core/common/validators.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'login_state.freezed.dart';

@freezed
abstract class LoginState with _$LoginState {
  const LoginState._();

  const factory LoginState({
    @Default('') String email,
    @Default('') String password,

    /// Turns on at the first submit. Before that the form stays quiet (no
    /// "Email is required." while the user hasn't typed yet); after it, the
    /// errors update live as the user types.
    @Default(false) bool showErrors,
    @Default(FormStatus.idle) FormStatus status,

    /// The server's answer, e.g. "Incorrect email or password.".
    String? errorMessage,
  }) = _LoginState;

  // The field errors are *derived*, not stored: they can never disagree with
  // the values they describe.
  String? get emailError => showErrors ? Validators.email(email) : null;

  String? get passwordError =>
      showErrors ? Validators.password(password) : null;

  bool get isValid =>
      Validators.email(email) == null && Validators.password(password) == null;

  /// Fields and buttons are disabled while signing in, and after success (the
  /// router is about to replace this screen).
  bool get isBusy =>
      status == FormStatus.submitting || status == FormStatus.success;
}
