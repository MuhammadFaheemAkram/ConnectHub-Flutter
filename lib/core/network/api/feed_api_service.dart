import 'package:connect_hub/core/network/dto/create_post_request_dto.dart';
import 'package:connect_hub/core/network/dto/post_dto.dart';
import 'package:connect_hub/core/network/dto/post_page_dto.dart';

/// The feed and post endpoints, Retrofit-style: one method per request.
///
/// Every call is authenticated: the server answers for the signed-in user,
/// so `isLiked` and `bookmarkedAt` are that user's own. Phase 5 adds the
/// bookmarks list.
abstract interface class FeedApiService {
  /// `GET /feed?cursor=…&limit=…`: newest first, [limit] posts per page.
  /// Pass the previous page's `nextCursor` to get the page after it.
  Future<PostPageDto> getFeed({String? cursor, int limit = 6});

  /// `GET /posts/{postId}`
  Future<PostDto> getPost(String postId);

  /// `POST /posts`: the new post, authored by the signed-in user.
  Future<PostDto> createPost(CreatePostRequestDto request);

  /// `PUT` / `DELETE /posts/{postId}/like`
  Future<PostDto> setLiked(String postId, {required bool liked});

  /// `PUT` / `DELETE /posts/{postId}/bookmark`
  Future<PostDto> setBookmarked(String postId, {required bool bookmarked});
}
