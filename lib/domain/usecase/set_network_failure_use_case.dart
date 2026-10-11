import 'package:connect_hub/domain/repository/demo_tools_repository.dart';
import 'package:injectable/injectable.dart';

/// Turns "Simulate network failure" on or off.
@injectable
class SetNetworkFailureUseCase {
  const SetNetworkFailureUseCase(this._tools);

  final DemoToolsRepository _tools;

  void call({required bool fail}) => _tools.setFailsRequests(fail: fail);
}
