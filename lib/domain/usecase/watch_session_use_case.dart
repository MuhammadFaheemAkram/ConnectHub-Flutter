import 'package:connect_hub/domain/model/session_state.dart';
import 'package:connect_hub/domain/repository/session_repository.dart';
import 'package:injectable/injectable.dart';

/// The session as a stream: the current state, then every change.
@injectable
class WatchSessionUseCase {
  const WatchSessionUseCase(this._sessions);

  final SessionRepository _sessions;

  Stream<SessionState> call() => _sessions.watchSession();
}
