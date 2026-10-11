import 'package:connect_hub/core/network/api/developer_tools_service.dart';
import 'package:connect_hub/core/network/fake_server/fake_server.dart';
import 'package:connect_hub/core/network/fake_server/network_simulator.dart';
import 'package:connect_hub/core/storage/session_storage.dart';
import 'package:injectable/injectable.dart';

/// [DeveloperToolsService] for the fake backend: the [NetworkSimulator]'s
/// failure switch (kept in memory, so it resets on restart) and the
/// [FakeServer]'s token revocation.
@LazySingleton(as: DeveloperToolsService)
class FakeDeveloperToolsService implements DeveloperToolsService {
  const FakeDeveloperToolsService(this._network, this._server, this._storage);

  final NetworkSimulator _network;
  final FakeServer _server;
  final SessionStorage _storage;

  @override
  bool get failsRequests => _network.failRequests;

  @override
  set failsRequests(bool value) => _network.failRequests = value;

  @override
  Future<void> expireSession() async {
    final token = (await _storage.read())?.token;
    if (token != null) _server.revoke(token);
  }
}
