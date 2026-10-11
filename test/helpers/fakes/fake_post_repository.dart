import 'dart:async';

import 'package:connect_hub/core/common/app_exception.dart';
import 'package:connect_hub/core/common/result.dart';
import 'package:connect_hub/domain/model/post.dart';
import 'package:connect_hub/domain/repository/post_repository.dart';

/// A scriptable [PostRepository]: set the results, read back the calls.
///
/// Like drift, `watchPost()` emits the cached post (or `null`) now, then
/// after every change, announced asynchronously.
class FakePostRepository implements PostRepository {
  FakePostRepository({Post? cached}) {
    if (cached != null) _posts[cached.id] = cached;
  }

  final _posts = <String, Post>{};
  final _changes = StreamController<String>.broadcast();

  /// What `refreshPost` answers. A success caches [refreshedPost] (if set);
  /// `NotFoundException` removes the cached copy, like the real one.
  Result<void> refreshResult = const Ok(null);
  Post? refreshedPost;

  /// While set and not completed, `refreshPost` waits for it.
  Completer<void>? refreshGate;
  int refreshCalls = 0;

  Result<void> createResult = const Ok(null);
  final createCalls = <({String content, String? imageUrl})>[];

  /// While set and not completed, `createPost` waits for it.
  Completer<void>? createGate;

  Result<void> likeResult = const Ok(null);
  Result<void> bookmarkResult = const Ok(null);

  /// While set and not completed, `setBookmarked` waits for it.
  Completer<void>? bookmarkGate;

  final likeCalls = <({String postId, bool liked})>[];
  final bookmarkCalls = <({String postId, bool bookmarked})>[];

  @override
  Stream<Post?> watchPost(String postId) => Stream.multi((watcher) {
    final subscription = _changes.stream
        .where((id) => id == postId)
        .listen((_) => watcher.add(_posts[postId]));
    watcher
      ..onCancel = subscription.cancel
      ..add(_posts[postId]);
  });

  @override
  Future<Result<void>> refreshPost(String postId) async {
    refreshCalls++;
    await refreshGate?.future;
    switch (refreshResult) {
      case Ok():
        if (refreshedPost case final post?) _write(post);
      case Err(exception: NotFoundException()):
        _posts.remove(postId);
        _changes.add(postId);
      case Err():
    }
    return refreshResult;
  }

  @override
  Future<Result<void>> createPost({
    required String content,
    String? imageUrl,
  }) async {
    createCalls.add((content: content, imageUrl: imageUrl));
    await createGate?.future;
    return createResult;
  }

  @override
  Future<Result<void>> setLiked(String postId, {required bool liked}) async {
    likeCalls.add((postId: postId, liked: liked));
    return likeResult;
  }

  @override
  Future<Result<void>> setBookmarked(
    String postId, {
    required bool bookmarked,
  }) async {
    bookmarkCalls.add((postId: postId, bookmarked: bookmarked));
    await bookmarkGate?.future;
    return bookmarkResult;
  }

  /// Changes a cached post, as another screen (or a like) would.
  void replacePost(Post post) => _write(post);

  void _write(Post post) {
    _posts[post.id] = post;
    _changes.add(post.id);
  }

  Future<void> dispose() => _changes.close();
}
