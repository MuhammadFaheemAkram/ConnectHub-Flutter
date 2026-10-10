import 'package:connect_hub/core/common/result.dart';
import 'package:connect_hub/domain/model/session.dart';
import 'package:connect_hub/domain/repository/auth_repository.dart';
import 'package:injectable/injectable.dart';

/// Signs in. On success the session is saved, and the app reacts to it.
@injectable
class LoginUseCase {
  const LoginUseCase(this._auth);

  final AuthRepository _auth;

  Future<Result<Session>> call({
    required String email,
    required String password,
  }) => _auth.login(email: email, password: password);
}
