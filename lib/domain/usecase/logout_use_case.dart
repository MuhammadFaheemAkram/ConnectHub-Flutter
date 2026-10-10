import 'package:connect_hub/domain/repository/auth_repository.dart';
import 'package:injectable/injectable.dart';

/// Logs out: the session is cleared, and the app returns to Login.
@injectable
class LogoutUseCase {
  const LogoutUseCase(this._auth);

  final AuthRepository _auth;

  Future<void> call() => _auth.logout();
}
