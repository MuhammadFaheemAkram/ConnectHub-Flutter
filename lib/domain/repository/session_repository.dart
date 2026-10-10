import 'package:connect_hub/domain/model/session.dart';
import 'package:connect_hub/domain/model/session_state.dart';

/// The signed-in session: restored from storage at launch, then saved,
/// cleared or expired as the user signs in and out.
abstract interface class SessionRepository {
  /// The session right now, or `null` while signed out or not yet restored.
  Session? get currentSession;

  /// Emits the current state first (restoring it from storage the first
  /// time), then every change. Never misses a change made while restoring.
  Stream<SessionState> watchSession();

  /// Persists [session] and announces it.
  Future<void> save(Session session);

  /// Logs out: deletes the stored session.
  Future<void> clear();

  /// The server rejected the token: deletes the stored session, and tells
  /// listeners why.
  Future<void> expire();
}
