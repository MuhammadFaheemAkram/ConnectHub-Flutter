import 'package:connect_hub/core/network/api/fake_api_client.dart';
import 'package:connect_hub/core/network/api/user_api_service.dart';
import 'package:connect_hub/core/network/dto/post_dto.dart';
import 'package:connect_hub/core/network/dto/update_profile_request_dto.dart';
import 'package:connect_hub/core/network/dto/user_dto.dart';
import 'package:connect_hub/core/network/fake_server/fake_server.dart';
import 'package:injectable/injectable.dart';

/// [UserApiService] backed by the in-memory [FakeServer].
@LazySingleton(as: UserApiService)
class FakeUserApiService implements UserApiService {
  const FakeUserApiService(this._client, this._server);

  final FakeApiClient _client;
  final FakeServer _server;

  static const _readLatency = Duration(milliseconds: 500);
  static const _writeLatency = Duration(milliseconds: 350);

  @override
  Future<UserDto> getUser(String userId) async {
    await _client.authenticate(_readLatency);
    return _server.getUser(userId);
  }

  @override
  Future<List<PostDto>> getUserPosts(String userId) async {
    final viewerId = await _client.authenticate(_readLatency);
    return _server.getUserPosts(viewerId, userId);
  }

  @override
  Future<UserDto> updateMe(UpdateProfileRequestDto request) async {
    final userId = await _client.authenticate(_writeLatency);
    return _server.updateMe(userId, request);
  }
}
