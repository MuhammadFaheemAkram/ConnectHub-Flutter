import 'dart:async';

import 'package:connect_hub/core/network/api/comment_api_service.dart';
import 'package:connect_hub/core/network/dto/comment_dto.dart';

/// Wraps a real [CommentApiService], records every request, and can hold
/// requests "in flight" until the test opens the [gate].
class GatedCommentApi implements CommentApiService {
  GatedCommentApi(this._inner);

  final CommentApiService _inner;

  /// Requests as `comments:<postId>`, `add:<postId>`, `delete:<commentId>`.
  final requests = <String>[];

  /// While set and not completed, requests wait for it.
  Completer<void>? gate;

  @override
  Future<List<CommentDto>> getComments(String postId) async {
    requests.add('comments:$postId');
    await gate?.future;
    return _inner.getComments(postId);
  }

  @override
  Future<CommentDto> addComment(String postId, String text) async {
    requests.add('add:$postId');
    await gate?.future;
    return _inner.addComment(postId, text);
  }

  @override
  Future<void> deleteComment(String commentId) async {
    requests.add('delete:$commentId');
    await gate?.future;
    return _inner.deleteComment(commentId);
  }
}
