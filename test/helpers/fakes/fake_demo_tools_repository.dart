import 'package:connect_hub/domain/repository/demo_tools_repository.dart';

/// An in-memory [DemoToolsRepository] that records what was asked of it.
class FakeDemoToolsRepository implements DemoToolsRepository {
  @override
  bool failsRequests = false;

  int expireCalls = 0;

  @override
  void setFailsRequests({required bool fail}) => failsRequests = fail;

  @override
  Future<void> expireSession() async => expireCalls++;
}
