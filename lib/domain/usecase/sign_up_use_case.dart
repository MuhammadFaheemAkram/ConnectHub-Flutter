import 'package:connect_hub/core/common/result.dart';
import 'package:connect_hub/domain/model/session.dart';
import 'package:connect_hub/domain/repository/auth_repository.dart';
import 'package:injectable/injectable.dart';

/// Creates an account and signs it in.
@injectable
class SignUpUseCase {
  const SignUpUseCase(this._auth);

  final AuthRepository _auth;

  Future<Result<Session>> call({
    required String name,
    required String email,
    required String password,
  }) => _auth.signUp(name: name, email: email, password: password);
}
