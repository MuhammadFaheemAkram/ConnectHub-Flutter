import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:connect_hub/core/common/demo_account.dart';
import 'package:connect_hub/core/common/form_status.dart';
import 'package:connect_hub/core/common/result.dart';
import 'package:connect_hub/domain/usecase/login_use_case.dart';
import 'package:connect_hub/features/auth/login/bloc/login_event.dart';
import 'package:connect_hub/features/auth/login/bloc/login_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

/// The Login form.
///
/// A Bloc rather than a Cubit, following the project's rule for auth flows.
/// The concrete payoff is [droppable] on [LoginSubmitted]: while a sign-in is
/// running, further submits (a double tap, Enter pressed twice) are dropped
/// instead of starting a second request. With a Cubit that guard would be a
/// hand-written `if (isSubmitting) return;`.
///
/// On success it does nothing else: the session is saved, the `AuthBloc`
/// sees it, and the router's gate leaves this screen.
@injectable
class LoginBloc extends Bloc<LoginEvent, LoginState> {
  LoginBloc(this._login) : super(const LoginState()) {
    on<LoginEmailChanged>(
      (event, emit) => emit(_edited(state.copyWith(email: event.email))),
    );
    on<LoginPasswordChanged>(
      (event, emit) => emit(_edited(state.copyWith(password: event.password))),
    );
    on<LoginDemoAccountRequested>(
      (event, emit) => emit(
        _edited(
          state.copyWith(
            email: DemoAccount.email,
            password: DemoAccount.password,
          ),
        ),
      ),
    );
    on<LoginSubmitted>(_onSubmitted, transformer: droppable());
  }

  final LoginUseCase _login;

  /// Editing clears the server's error: it described the previous attempt.
  LoginState _edited(LoginState state) =>
      state.copyWith(status: FormStatus.idle, errorMessage: null);

  Future<void> _onSubmitted(
    LoginSubmitted event,
    Emitter<LoginState> emit,
  ) async {
    final attempt = state.copyWith(showErrors: true, errorMessage: null);
    if (!attempt.isValid) {
      emit(attempt.copyWith(status: FormStatus.idle));
      return;
    }
    emit(attempt.copyWith(status: FormStatus.submitting));

    final result = await _login(
      email: state.email.trim(),
      password: state.password,
    );

    // No `isClosed` check: a closed Bloc's emitter ignores further emits
    // (unlike a Cubit's `emit`, which throws after close).
    emit(switch (result) {
      Ok() => state.copyWith(status: FormStatus.success),
      Err(:final exception) => state.copyWith(
        status: FormStatus.failure,
        errorMessage: exception.message,
      ),
    });
  }
}
