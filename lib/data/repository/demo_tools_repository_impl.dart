import 'package:connect_hub/core/network/api/developer_tools_service.dart';
import 'package:connect_hub/domain/repository/demo_tools_repository.dart';
import 'package:injectable/injectable.dart';

/// Settings → Developer, through the network layer's [DeveloperToolsService]
/// (only `core/network/` may touch the fake backend).
@LazySingleton(as: DemoToolsRepository)
class DemoToolsRepositoryImpl implements DemoToolsRepository {
  const DemoToolsRepositoryImpl(this._tools);

  final DeveloperToolsService _tools;

  @override
  bool get failsRequests => _tools.failsRequests;

  @override
  void setFailsRequests({required bool fail}) => _tools.failsRequests = fail;

  @override
  Future<void> expireSession() => _tools.expireSession();
}
