import 'package:connect_hub/core/common/form_status.dart';
import 'package:connect_hub/core/common/validators.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'sign_up_state.freezed.dart';

@freezed
abstract class SignUpState with _$SignUpState {
  const SignUpState._();

  const factory SignUpState({
    @Default('') String name,
    @Default('') String email,
    @Default('') String password,
    @Default('') String confirmPassword,

    /// As on Login: quiet until the first submit, then live.
    @Default(false) bool showErrors,
    @Default(FormStatus.idle) FormStatus status,

    /// The server's answer, e.g. "An account with this email already exists.".
    String? errorMessage,
  }) = _SignUpState;

  String? get nameError => showErrors ? Validators.name(name) : null;

  String? get emailError => showErrors ? Validators.email(email) : null;

  String? get passwordError =>
      showErrors ? Validators.password(password) : null;

  String? get confirmPasswordError =>
      showErrors ? Validators.confirmPassword(password, confirmPassword) : null;

  bool get isValid =>
      Validators.name(name) == null &&
      Validators.email(email) == null &&
      Validators.password(password) == null &&
      Validators.confirmPassword(password, confirmPassword) == null;

  bool get isBusy =>
      status == FormStatus.submitting || status == FormStatus.success;
}
