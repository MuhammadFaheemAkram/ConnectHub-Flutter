import 'package:connect_hub/core/network/dto/auth_response_dto.dart';

/// The authentication endpoints, Retrofit-style: one method per request.
///
/// Callers depend on this interface only. Today the implementation is
/// [FakeAuthApiService]; a `dio` client would implement the same methods.
abstract interface class AuthApiService {
  /// `POST /auth/login`
  Future<AuthResponseDto> login({
    required String email,
    required String password,
  });

  /// `POST /auth/signup`
  Future<AuthResponseDto> signUp({
    required String name,
    required String email,
    required String password,
  });
}
