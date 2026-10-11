import 'package:connect_hub/core/common/app_exception.dart';
import 'package:connect_hub/core/common/result.dart';
import 'package:connect_hub/core/database/daos/comments_dao.dart';
import 'package:connect_hub/core/database/daos/posts_dao.dart';
import 'package:connect_hub/core/network/api/comment_api_service.dart';
import 'package:connect_hub/data/mapper/comment_mappers.dart';
import 'package:connect_hub/data/repository/api_guard.dart';
import 'package:connect_hub/domain/model/comment.dart';
import 'package:connect_hub/domain/repository/comment_repository.dart';
import 'package:connect_hub/domain/repository/post_repository.dart';
import 'package:connect_hub/domain/repository/session_repository.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: CommentRepository)
class CommentRepositoryImpl implements CommentRepository {
  CommentRepositoryImpl(
    this._api,
    this._comments,
    this._cachedPosts,
    this._posts,
    this._sessions,
    this._guard,
  );

  final CommentApiService _api;
  final CommentsDao _comments;
  final PostsDao _cachedPosts;
  final PostRepository _posts;
  final SessionRepository _sessions;
  final ApiGuard _guard;

  @override
  Stream<List<Comment>> watchComments(String postId) {
    return _comments.watchComments(postId).map((entries) {
      final me = _sessions.currentSession?.userId;
      return [for (final entry in entries) entry.toDomain(signedInUserId: me)];
    });
  }

  @override
  Future<Result<void>> refreshComments(String postId) async {
    final result = await _guard.run(() => _api.getComments(postId));
    switch (result) {
      case Ok(value: final comments):
        final entries = [for (final comment in comments) comment.toCached()];
        // A comment row needs its post (a foreign key), and a deep link can
        // open the comments of a post that isn't cached yet. Fetch the post
        // first in that case.
        if (!await _cachedPosts.isCached(postId)) {
          final post = await _posts.refreshPost(postId);
          if (post case Err(:final exception)) return Err(exception);
        }
        await _comments.replaceComments(postId, entries);
        return const Ok(null);
      case Err(:final exception):
        // No post, no comments: the cached copy goes too (Rule 1).
        if (exception is NotFoundException) {
          await _cachedPosts.deletePost(postId);
        }
        return Err(exception);
    }
  }

  /// Not optimistic: a comment is cached once the server has accepted it.
  /// Meanwhile the send button shows progress, and on failure the text stays
  /// in the field, ready to send again.
  @override
  Future<Result<void>> addComment(String postId, String text) async {
    final result = await _guard.run(() => _api.addComment(postId, text));
    switch (result) {
      case Ok(value: final comment):
        await _comments.addComment(comment.toCached());
        return const Ok(null);
      case Err(:final exception):
        return Err(exception);
    }
  }

  /// Optimistic: the comment disappears (and the count drops) at once. If
  /// the server refuses, it comes back where it was.
  @override
  Future<Result<void>> deleteComment(String commentId) async {
    final removed = await _comments.removeComment(commentId);
    final result = await _guard.run(() => _api.deleteComment(commentId));
    if (result case Err(:final exception)) {
      if (removed != null) await _comments.restoreComment(removed);
      return Err(exception);
    }
    return const Ok(null);
  }
}
