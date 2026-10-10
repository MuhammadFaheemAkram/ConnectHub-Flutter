import 'package:connect_hub/core/common/app_exception.dart';
import 'package:connect_hub/core/network/fake_server/fake_server.dart';
import 'package:connect_hub/core/network/fake_server/network_simulator.dart';
import 'package:connect_hub/core/storage/session_storage.dart';
import 'package:injectable/injectable.dart';

/// The fake counterpart of an HTTP client with an auth interceptor.
///
/// Every authenticated fake call starts with [authenticate]: it attaches the
/// saved token (as a `dio` interceptor would add `Authorization: Bearer …`),
/// crosses the simulated network, and lets the server resolve the token to a
/// user. Only then does the fake service run the actual request.
@lazySingleton
class FakeApiClient {
  const FakeApiClient(this._storage, this._network, this._server);

  final SessionStorage _storage;
  final NetworkSimulator _network;
  final FakeServer _server;

  /// Starts an authenticated request that takes [latency] on the wire, and
  /// returns the id of the user the token belongs to.
  ///
  /// Throws [NetworkException] if the simulated network fails, and
  /// [UnauthorizedException] (a 401) if the token is missing, unknown or
  /// revoked.
  Future<String> authenticate(Duration latency) async {
    // The token is read when the request is sent, like a header. If the user
    // logs out while it is in flight, it still arrives with the old token.
    final token = (await _storage.read())?.token;
    await _network.run(latency);
    return _server.authenticate(token);
  }
}
