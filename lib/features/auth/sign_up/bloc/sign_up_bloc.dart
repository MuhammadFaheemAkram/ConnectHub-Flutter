import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:connect_hub/core/common/form_status.dart';
import 'package:connect_hub/core/common/result.dart';
import 'package:connect_hub/domain/usecase/sign_up_use_case.dart';
import 'package:connect_hub/features/auth/sign_up/bloc/sign_up_event.dart';
import 'package:connect_hub/features/auth/sign_up/bloc/sign_up_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

/// The Sign Up form. Same shape as `LoginBloc`: one event per field, and a
/// `droppable()` submit so a double tap can't create two accounts.
@injectable
class SignUpBloc extends Bloc<SignUpEvent, SignUpState> {
  SignUpBloc(this._signUp) : super(const SignUpState()) {
    on<SignUpNameChanged>(
      (event, emit) => emit(_edited(state.copyWith(name: event.name))),
    );
    on<SignUpEmailChanged>(
      (event, emit) => emit(_edited(state.copyWith(email: event.email))),
    );
    on<SignUpPasswordChanged>(
      (event, emit) => emit(_edited(state.copyWith(password: event.password))),
    );
    on<SignUpConfirmPasswordChanged>(
      (event, emit) =>
          emit(_edited(state.copyWith(confirmPassword: event.confirmPassword))),
    );
    on<SignUpSubmitted>(_onSubmitted, transformer: droppable());
  }

  final SignUpUseCase _signUp;

  SignUpState _edited(SignUpState state) =>
      state.copyWith(status: FormStatus.idle, errorMessage: null);

  Future<void> _onSubmitted(
    SignUpSubmitted event,
    Emitter<SignUpState> emit,
  ) async {
    final attempt = state.copyWith(showErrors: true, errorMessage: null);
    if (!attempt.isValid) {
      emit(attempt.copyWith(status: FormStatus.idle));
      return;
    }
    emit(attempt.copyWith(status: FormStatus.submitting));

    final result = await _signUp(
      name: state.name.trim(),
      email: state.email.trim(),
      password: state.password,
    );

    emit(switch (result) {
      Ok() => state.copyWith(status: FormStatus.success),
      Err(:final exception) => state.copyWith(
        status: FormStatus.failure,
        errorMessage: exception.message,
      ),
    });
  }
}
