import 'package:connect_hub/core/network/api/auth_api_service.dart';
import 'package:connect_hub/core/network/dto/auth_response_dto.dart';
import 'package:connect_hub/core/network/fake_server/fake_server.dart';
import 'package:connect_hub/core/network/fake_server/network_simulator.dart';
import 'package:injectable/injectable.dart';

/// [AuthApiService] backed by the in-memory [FakeServer].
///
/// Each call first crosses the simulated network (latency, optional failure),
/// then asks the server, just as an HTTP client would.
@LazySingleton(as: AuthApiService)
class FakeAuthApiService implements AuthApiService {
  const FakeAuthApiService(this._server, this._network);

  final FakeServer _server;
  final NetworkSimulator _network;

  static const _latency = Duration(milliseconds: 800);

  @override
  Future<AuthResponseDto> login({
    required String email,
    required String password,
  }) async {
    await _network.run(_latency);
    return _server.login(email: email, password: password);
  }

  @override
  Future<AuthResponseDto> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    await _network.run(_latency);
    return _server.signUp(name: name, email: email, password: password);
  }
}
