import 'package:connect_hub/domain/model/session.dart';
import 'package:connect_hub/domain/model/session_state.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_state.freezed.dart';

/// The session as the app sees it. The router's sign-in gate reads this.
@freezed
sealed class AuthState with _$AuthState {
  /// The saved session is still being read, so the router shows the splash.
  const factory AuthState.unknown() = AuthUnknown;

  const factory AuthState.authenticated(Session session) = AuthAuthenticated;

  /// Signed out. The [reason] lets Login explain an expired session, and lets
  /// the gate skip the return address after a deliberate logout.
  const factory AuthState.unauthenticated({
    @Default(SignOutReason.none) SignOutReason reason,
  }) = AuthUnauthenticated;
}
