import 'dart:developer' as developer;

import 'package:connect_hub/core/common/app_exception.dart';
import 'package:connect_hub/core/common/result.dart';
import 'package:connect_hub/domain/repository/session_repository.dart';
import 'package:injectable/injectable.dart';

/// Runs API calls for the repositories and turns their outcome into a
/// [Result].
///
/// It is also the one place that handles an expired session. When the server
/// answers 401 ([UnauthorizedException]), the session is expired here once,
/// for every repository, instead of each screen checking for it. Expiring
/// the session moves the app back to Login through the router's gate. This
/// is the role an HTTP interceptor plays in a `dio` setup.
@lazySingleton
class ApiGuard {
  const ApiGuard(this._sessions);

  final SessionRepository _sessions;

  Future<Result<T>> run<T>(Future<T> Function() call) async {
    try {
      return Ok(await call());
    } on UnauthorizedException catch (exception) {
      await _sessions.expire();
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
  }
}
