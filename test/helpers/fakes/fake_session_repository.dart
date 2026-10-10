import 'dart:async';

import 'package:connect_hub/domain/model/session.dart';
import 'package:connect_hub/domain/model/session_state.dart';
import 'package:connect_hub/domain/repository/session_repository.dart';

/// An in-memory [SessionRepository] for Bloc and repository tests. Like the
/// real one, `watchSession()` emits the current state, then every change.
class FakeSessionRepository implements SessionRepository {
  FakeSessionRepository({SessionState initial = const SessionState.signedOut()})
    : _state = initial;

  SessionState _state;
  final _changes = StreamController<SessionState>.broadcast(sync: true);

  final saved = <Session>[];
  int clearCalls = 0;
  int expireCalls = 0;

  @override
  Session? get currentSession => switch (_state) {
    SignedIn(:final session) => session,
    _ => null,
  };

  @override
  Stream<SessionState> watchSession() => Stream.multi((watcher) {
    final subscription = _changes.stream.listen(watcher.add);
    watcher
      ..onCancel = subscription.cancel
      ..add(_state);
  });

  @override
  Future<void> save(Session session) async {
    saved.add(session);
    _emit(SessionState.signedIn(session));
  }

  @override
  Future<void> clear() async {
    clearCalls++;
    _emit(const SessionState.signedOut(reason: SignOutReason.loggedOut));
  }

  @override
  Future<void> expire() async {
    expireCalls++;
    _emit(const SessionState.signedOut(reason: SignOutReason.expired));
  }

  void _emit(SessionState state) {
    _state = state;
    _changes.add(state);
  }

  Future<void> dispose() => _changes.close();
}
