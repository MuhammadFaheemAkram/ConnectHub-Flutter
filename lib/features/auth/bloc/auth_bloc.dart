import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:connect_hub/domain/model/session_state.dart';
import 'package:connect_hub/domain/usecase/logout_use_case.dart';
import 'package:connect_hub/domain/usecase/watch_session_use_case.dart';
import 'package:connect_hub/features/auth/bloc/auth_event.dart';
import 'package:connect_hub/features/auth/bloc/auth_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

/// The app-wide session, as an event-driven Bloc.
///
/// Why a Bloc rather than a Cubit: two very different inputs drive it, a
/// long-lived subscription (the session stream) and a user intent (log out).
/// Events make each one explicit and observable: a `BlocObserver` can log
/// `AuthLogoutRequested` like any other action, and each event gets its own
/// concurrency rule.
///
/// It doesn't navigate. The router reads its state for the sign-in gate and
/// re-checks it on every change, so signing in or out moves the user without
/// any navigation code.
@injectable
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc(this._watchSession, this._logout)
    : super(const AuthState.unknown()) {
    // restartable(): if subscribing were ever requested twice, the old
    // subscription is cancelled instead of two running side by side.
    on<AuthSubscriptionRequested>(
      _onSubscriptionRequested,
      transformer: restartable(),
    );
    // droppable(): a second tap on "Log out" while one is running is ignored.
    on<AuthLogoutRequested>(_onLogoutRequested, transformer: droppable());
  }

  final WatchSessionUseCase _watchSession;
  final LogoutUseCase _logout;

  /// `emit.forEach` keeps this handler running for as long as the session
  /// stream does, maps each value to a state, and cancels the subscription
  /// when the Bloc closes. There is no manual `StreamSubscription` to manage.
  Future<void> _onSubscriptionRequested(
    AuthSubscriptionRequested event,
    Emitter<AuthState> emit,
  ) {
    return emit.forEach<SessionState>(
      _watchSession(),
      onData: (session) => switch (session) {
        SignedIn(:final session) => AuthState.authenticated(session),
        SignedOut(:final reason) => AuthState.unauthenticated(reason: reason),
      },
    );
  }

  /// Logging out only clears the session. The new state then arrives through
  /// the session stream, like every other change.
  Future<void> _onLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) => _logout();
}
