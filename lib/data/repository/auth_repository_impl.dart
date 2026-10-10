import 'package:connect_hub/core/common/result.dart';
import 'package:connect_hub/core/network/api/auth_api_service.dart';
import 'package:connect_hub/core/network/dto/auth_response_dto.dart';
import 'package:connect_hub/data/mapper/auth_mappers.dart';
import 'package:connect_hub/data/repository/api_guard.dart';
import 'package:connect_hub/domain/model/session.dart';
import 'package:connect_hub/domain/repository/auth_repository.dart';
import 'package:connect_hub/domain/repository/session_repository.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: AuthRepository)
class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl(this._api, this._sessions, this._guard);

  final AuthApiService _api;
  final SessionRepository _sessions;
  final ApiGuard _guard;

  @override
  Future<Result<Session>> login({
    required String email,
    required String password,
  }) => _signIn(
    () => _api.login(email: email, password: password),
    email: email,
  );

  @override
  Future<Result<Session>> signUp({
    required String name,
    required String email,
    required String password,
  }) => _signIn(
    () => _api.signUp(name: name, email: email, password: password),
    email: email,
  );

  @override
  Future<void> logout() => _sessions.clear();

  /// Runs a sign-in request and, on success, saves the session it grants.
  /// Saving is what moves the app forward: the session stream changes, and
  /// the router's gate sends the user to the Feed.
  Future<Result<Session>> _signIn(
    Future<AuthResponseDto> Function() request, {
    required String email,
  }) async {
    switch (await _guard.run(request)) {
      case Ok(:final value):
        final session = value.toSession(fallbackEmail: email);
        await _sessions.save(session);
        return Ok(session);
      case Err(:final exception):
        return Err(exception);
    }
  }
}
