import 'package:connect_hub/core/network/api/fake_api_client.dart';
import 'package:connect_hub/core/network/api/search_api_service.dart';
import 'package:connect_hub/core/network/dto/search_response_dto.dart';
import 'package:connect_hub/core/network/fake_server/fake_server.dart';
import 'package:injectable/injectable.dart';

/// [SearchApiService] backed by the in-memory [FakeServer].
@LazySingleton(as: SearchApiService)
class FakeSearchApiService implements SearchApiService {
  const FakeSearchApiService(this._client, this._server);

  final FakeApiClient _client;
  final FakeServer _server;

  static const _latency = Duration(milliseconds: 400);

  @override
  Future<SearchResponseDto> search(String query) async {
    final userId = await _client.authenticate(_latency);
    return _server.search(userId, query);
  }
}
