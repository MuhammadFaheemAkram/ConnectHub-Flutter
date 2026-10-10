import 'dart:developer' as developer;

import 'package:connect_hub/core/common/app_exception.dart';
import 'package:connect_hub/core/common/result.dart';
import 'package:connect_hub/domain/repository/session_repository.dart';
import 'package:injectable/injectable.dart';

/// Runs API calls for the repositories and turns their outcome into a
/// [Result].
///
/// It is also the one place that ties requests to the session:
/// - When the server answers 401 ([UnauthorizedException]), the session is
///   expired here once, for every repository, instead of each screen checking
///   for it. Expiring the session moves the app back to Login through the
///   router's gate. This is the role an HTTP interceptor plays in a `dio`
///   setup.
/// - A request belongs to the session that sent it. An answer that arrives
///   after that session ended belongs to a user who is gone, so it is
///   dropped instead of being cached for the next one.
@lazySingleton
class ApiGuard {
  const ApiGuard(this._sessions);

  final SessionRepository _sessions;

  Future<Result<T>> run<T>(Future<T> Function() call) async {
    final session = _sessions.currentSession;
    final T value;
    try {
      value = await call();
    } on UnauthorizedException catch (exception) {
      // Only the session that sent the request has expired. A late 401 for
      // an earlier session must not sign out whoever is signed in now.
      if (_sessions.currentSession == session) await _sessions.expire();
      return Err(exception);
    } on AppException catch (exception) {
      return Err(exception);
    } on Exception catch (error, stackTrace) {
      // Anything else is a bug or an unexpected failure: log it, and show a
      // generic message rather than leaking the raw exception to the UI.
      // Errors (programming mistakes) are not caught, so tests still see them.
      developer.log(
        'Unexpected exception in an API call',
        error: error,
        stackTrace: stackTrace,
        name: 'ApiGuard',
      );
      return const Err(UnknownException());
    }
    if (_sessions.currentSession != session) {
      return const Err(UnauthorizedException());
    }
    return Ok(value);
  }
}
