import 'dart:async';

import 'package:connect_hub/core/storage/session_storage.dart';
import 'package:connect_hub/data/mapper/auth_mappers.dart';
import 'package:connect_hub/domain/model/session.dart';
import 'package:connect_hub/domain/model/session_state.dart';
import 'package:connect_hub/domain/repository/session_repository.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: SessionRepository)
class SessionRepositoryImpl implements SessionRepository {
  SessionRepositoryImpl(this._storage);

  final SessionStorage _storage;

  /// Every change, for every watcher. `sync: true` delivers each change to
  /// the watchers' queues the moment it happens, which keeps them in order.
  final _changes = StreamController<SessionState>.broadcast(sync: true);

  /// The latest state, or `null` until the first restore finishes.
  SessionState? _current;
  Future<void>? _restoring;

  @override
  Session? get currentSession => switch (_current) {
    SignedIn(:final session) => session,
    _ => null,
  };

  /// A "behavior subject" without RxDart: each watcher gets the current state
  /// first, then every change.
  ///
  /// The watcher subscribes to [_changes] *before* anything else happens, so
  /// even a change made while storage is still being read can't be missed:
  /// the restore itself is announced through [_changes] too.
  @override
  Stream<SessionState> watchSession() {
    return Stream<SessionState>.multi((watcher) {
      final subscription = _changes.stream.listen(watcher.add);
      watcher.onCancel = subscription.cancel;
      final current = _current;
      if (current != null) {
        watcher.add(current);
      } else {
        unawaited(_restore());
      }
    });
  }

  @override
  Future<void> save(Session session) async {
    await _storage.write(session.toStored());
    _publish(SessionState.signedIn(session));
  }

  @override
  Future<void> clear() => _end(SignOutReason.loggedOut);

  @override
  Future<void> expire() => _end(SignOutReason.expired);

  Future<void> _end(SignOutReason reason) async {
    await _storage.delete();
    _publish(SessionState.signedOut(reason: reason));
  }

  Future<void> _restore() => _restoring ??= () async {
    final stored = await _storage.read();
    // A sign-in that finished while storage was being read is newer than
    // what was stored: keep it.
    if (_current != null) return;
    _publish(
      stored == null
          ? const SessionState.signedOut()
          : SessionState.signedIn(stored.toSession()),
    );
  }();

  void _publish(SessionState state) {
    _current = state;
    _changes.add(state);
  }

  /// Closes the change stream (for tests). The app keeps one repository for
  /// its whole lifetime. Not `@disposeMethod`: on an `as:` registration,
  /// injectable would call `dispose()` on the interface (conventions §11.15).
  Future<void> dispose() => _changes.close();
}
