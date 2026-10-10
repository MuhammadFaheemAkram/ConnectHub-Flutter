import 'package:connect_hub/domain/model/session.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'session_state.freezed.dart';

/// Why there is no session.
enum SignOutReason {
  /// Nobody has signed in yet (or the saved session couldn't be read).
  none,

  /// The user logged out.
  loggedOut,

  /// The server rejected the token (401), so the session was dropped.
  expired,
}

/// What `SessionRepository.watchSession()` emits: the current session, then
/// every change.
@freezed
sealed class SessionState with _$SessionState {
  const factory SessionState.signedIn(Session session) = SignedIn;

  const factory SessionState.signedOut({
    @Default(SignOutReason.none) SignOutReason reason,
  }) = SignedOut;
}
