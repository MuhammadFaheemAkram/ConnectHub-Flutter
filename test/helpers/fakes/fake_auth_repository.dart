import 'dart:async';

import 'package:connect_hub/core/common/result.dart';
import 'package:connect_hub/domain/model/session.dart';
import 'package:connect_hub/domain/repository/auth_repository.dart';

import '../fixtures.dart';

/// A scriptable [AuthRepository] for the auth Blocs' tests.
///
/// Set [result] to choose the answer, and [gate] to hold a request in flight
/// (to prove a second submit is dropped). Every call is recorded.
class FakeAuthRepository implements AuthRepository {
  FakeAuthRepository({this.onLogout});

  Result<Session> result = const Ok(demoSession);
  Completer<void>? gate;

  /// Runs on logout, e.g. to clear a fake session repository.
  final Future<void> Function()? onLogout;

  final loginCalls = <({String email, String password})>[];
  final signUpCalls = <({String name, String email, String password})>[];
  int logoutCalls = 0;

  @override
  Future<Result<Session>> login({
    required String email,
    required String password,
  }) async {
    loginCalls.add((email: email, password: password));
    await gate?.future;
    return result;
  }

  @override
  Future<Result<Session>> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    signUpCalls.add((name: name, email: email, password: password));
    await gate?.future;
    return result;
  }

  @override
  Future<void> logout() async {
    logoutCalls++;
    await onLogout?.call();
  }
}
