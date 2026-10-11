import 'dart:async';

import 'package:connect_hub/core/network/api/feed_api_service.dart';
import 'package:connect_hub/core/network/dto/create_post_request_dto.dart';
import 'package:connect_hub/core/network/dto/post_dto.dart';
import 'package:connect_hub/core/network/dto/post_page_dto.dart';

/// Wraps a real [FeedApiService], records every request, and can hold
/// requests "in flight" until the test opens the [gate]. That makes the
/// moment between an optimistic write and the server's answer observable.
class GatedFeedApi implements FeedApiService {
  GatedFeedApi(this._inner);

  final FeedApiService _inner;

  /// Requests as `feed:<cursor or top>`, `post:<postId>`, `create`,
  /// `like:<postId>`, `bookmark:<postId>`.
  final requests = <String>[];

  /// While set and not completed, requests wait for it.
  Completer<void>? gate;

  @override
  Future<PostPageDto> getFeed({String? cursor, int limit = 6}) async {
    requests.add('feed:${cursor ?? 'top'}');
    await gate?.future;
    return _inner.getFeed(cursor: cursor, limit: limit);
  }

  @override
  Future<PostDto> getPost(String postId) async {
    requests.add('post:$postId');
    await gate?.future;
    return _inner.getPost(postId);
  }

  @override
  Future<PostDto> createPost(CreatePostRequestDto request) async {
    requests.add('create');
    await gate?.future;
    return _inner.createPost(request);
  }

  @override
  Future<PostDto> setLiked(String postId, {required bool liked}) async {
    requests.add('like:$postId');
    await gate?.future;
    return _inner.setLiked(postId, liked: liked);
  }

  @override
  Future<PostDto> setBookmarked(
    String postId, {
    required bool bookmarked,
  }) async {
    requests.add('bookmark:$postId');
    await gate?.future;
    return _inner.setBookmarked(postId, bookmarked: bookmarked);
  }
}
