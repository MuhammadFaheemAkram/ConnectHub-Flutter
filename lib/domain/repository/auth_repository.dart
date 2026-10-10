import 'package:connect_hub/core/common/result.dart';
import 'package:connect_hub/domain/model/session.dart';

/// Signing in, signing up and logging out.
///
/// A successful sign-in or sign-up also saves the session, so whoever
/// watches the session (the `AuthBloc`, and through it the router) reacts
/// without the caller doing anything else.
abstract interface class AuthRepository {
  Future<Result<Session>> login({
    required String email,
    required String password,
  });

  Future<Result<Session>> signUp({
    required String name,
    required String email,
    required String password,
  });

  Future<void> logout();
}
