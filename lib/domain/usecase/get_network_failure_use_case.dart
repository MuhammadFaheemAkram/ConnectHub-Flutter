import 'package:connect_hub/domain/repository/demo_tools_repository.dart';
import 'package:injectable/injectable.dart';

/// Whether "Simulate network failure" is on right now.
@injectable
class GetNetworkFailureUseCase {
  const GetNetworkFailureUseCase(this._tools);

  final DemoToolsRepository _tools;

  bool call() => _tools.failsRequests;
}
