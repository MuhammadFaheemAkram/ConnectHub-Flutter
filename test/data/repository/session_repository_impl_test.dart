import 'dart:async';
import 'dart:convert';

import 'package:async/async.dart' show StreamQueue;
import 'package:connect_hub/core/storage/session_storage.dart';
import 'package:connect_hub/data/repository/session_repository_impl.dart';
import 'package:connect_hub/domain/model/session_state.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fixtures.dart';
import '../../helpers/stream_helpers.dart';

void main() {
  late SessionRepositoryImpl repository;

  SessionRepositoryImpl newRepository() =>
      SessionRepositoryImpl(const SessionStorage(FlutterSecureStorage()));

  Map<String, String> stored() => {
    'session': jsonEncode({
      'token': demoSession.token,
      'userId': demoSession.userId,
      'email': demoSession.email,
    }),
  };

  tearDown(() => repository.dispose());

  test('restores "signed out" when nothing is stored', () async {
    FlutterSecureStorage.setMockInitialValues({});
    repository = newRepository();

    expect(
      await repository.watchSession().first,
      const SessionState.signedOut(),
    );
    expect(repository.currentSession, isNull);
  });

  test('restores a stored session', () async {
    FlutterSecureStorage.setMockInitialValues(stored());
    repository = newRepository();

    expect(
      await repository.watchSession().first,
      const SessionState.signedIn(demoSession),
    );
    expect(repository.currentSession, demoSession);
  });

  test('emits the current state first, then every change, with the reason '
      'for each sign-out', () async {
    FlutterSecureStorage.setMockInitialValues({});
    repository = newRepository();
    final states = StreamQueue(repository.watchSession());

    expect(await nextEvent(states), const SessionState.signedOut());

    await repository.save(demoSession);
    expect(await nextEvent(states), const SessionState.signedIn(demoSession));

    await repository.expire();
    expect(
      await nextEvent(states),
      const SessionState.signedOut(reason: SignOutReason.expired),
    );

    await repository.save(demoSession);
    await repository.clear();
    expect(await nextEvent(states), const SessionState.signedIn(demoSession));
    expect(
      await nextEvent(states),
      const SessionState.signedOut(reason: SignOutReason.loggedOut),
    );
    await states.cancel();
  });

  test(
    'saving persists, and logging out deletes, the stored session',
    () async {
      FlutterSecureStorage.setMockInitialValues({});
      repository = newRepository();

      await repository.save(demoSession);
      expect(
        await newRepository().watchSession().first,
        const SessionState.signedIn(demoSession),
      );

      await repository.clear();
      expect(
        await newRepository().watchSession().first,
        const SessionState.signedOut(),
      );
    },
  );

  test('a later watcher gets the current state straight away', () async {
    FlutterSecureStorage.setMockInitialValues({});
    repository = newRepository();
    await repository.watchSession().first;
    await repository.save(demoSession);

    expect(
      await repository.watchSession().first,
      const SessionState.signedIn(demoSession),
    );
  });

  test('a sign-in that finishes while storage is still being read wins over '
      'the (older) stored value', () async {
    final storage = _GatedStorage();
    repository = SessionRepositoryImpl(storage);
    final states = <SessionState>[];
    final subscription = repository.watchSession().listen(states.add);
    await pumpEventQueue(); // the restore is now waiting on storage

    await repository.save(demoSession);
    storage.readGate.complete(null); // storage finally answers: nothing stored
    await pumpEventQueue();

    expect(states, [const SessionState.signedIn(demoSession)]);
    await subscription.cancel();
  });
}

/// Storage whose read only answers when the test says so.
class _GatedStorage implements SessionStorage {
  final readGate = Completer<StoredSession?>();

  @override
  Future<StoredSession?> read() => readGate.future;

  @override
  Future<void> write(StoredSession session) async {}

  @override
  Future<void> delete() async {}
}
