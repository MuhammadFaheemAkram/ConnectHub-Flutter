import 'package:connect_hub/core/network/api/comment_api_service.dart';
import 'package:connect_hub/core/network/api/fake_api_client.dart';
import 'package:connect_hub/core/network/dto/comment_dto.dart';
import 'package:connect_hub/core/network/fake_server/fake_server.dart';
import 'package:injectable/injectable.dart';

/// [CommentApiService] backed by the in-memory [FakeServer].
@LazySingleton(as: CommentApiService)
class FakeCommentApiService implements CommentApiService {
  const FakeCommentApiService(this._client, this._server);

  final FakeApiClient _client;
  final FakeServer _server;

  static const _readLatency = Duration(milliseconds: 500);
  static const _writeLatency = Duration(milliseconds: 350);

  @override
  Future<List<CommentDto>> getComments(String postId) async {
    await _client.authenticate(_readLatency);
    return _server.getComments(postId);
  }

  @override
  Future<CommentDto> addComment(String postId, String text) async {
    final userId = await _client.authenticate(_writeLatency);
    return _server.addComment(userId, postId, text);
  }

  @override
  Future<void> deleteComment(String commentId) async {
    final userId = await _client.authenticate(_writeLatency);
    return _server.deleteComment(userId, commentId);
  }
}
