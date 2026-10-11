import 'package:connect_hub/domain/repository/demo_tools_repository.dart';
import 'package:injectable/injectable.dart';

/// Makes the current session invalid: the next request ends it.
@injectable
class ExpireSessionUseCase {
  const ExpireSessionUseCase(this._tools);

  final DemoToolsRepository _tools;

  Future<void> call() => _tools.expireSession();
}
