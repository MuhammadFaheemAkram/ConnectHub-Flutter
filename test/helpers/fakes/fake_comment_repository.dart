import 'dart:async';

import 'package:connect_hub/core/common/result.dart';
import 'package:connect_hub/domain/model/comment.dart';
import 'package:connect_hub/domain/repository/comment_repository.dart';

/// A scriptable [CommentRepository] for one post's comments.
///
/// Like drift, `watchComments()` emits the current list, then every change,
/// announced asynchronously.
class FakeCommentRepository implements CommentRepository {
  FakeCommentRepository({List<Comment> cached = const []}) : _comments = cached;

  List<Comment> _comments;
  final _changes = StreamController<List<Comment>>.broadcast();

  /// What `refreshComments` answers; a success caches [refreshedComments]
  /// (if set).
  Result<void> refreshResult = const Ok(null);
  List<Comment>? refreshedComments;

  /// While set and not completed, `refreshComments` waits for it.
  Completer<void>? refreshGate;
  int refreshCalls = 0;

  /// What `addComment` answers; a success caches [addedComment] (if set).
  Result<void> addResult = const Ok(null);
  Comment? addedComment;
  final addCalls = <({String postId, String text})>[];

  /// While set and not completed, `addComment` waits for it.
  Completer<void>? addGate;

  Result<void> deleteResult = const Ok(null);
  final deleteCalls = <String>[];

  @override
  Stream<List<Comment>> watchComments(String postId) => Stream.multi((watcher) {
    final subscription = _changes.stream.listen(watcher.add);
    watcher
      ..onCancel = subscription.cancel
      ..add(_comments);
  });

  @override
  Future<Result<void>> refreshComments(String postId) async {
    refreshCalls++;
    await refreshGate?.future;
    final comments = refreshedComments;
    if (refreshResult is Ok<void> && comments != null) _write(comments);
    return refreshResult;
  }

  @override
  Future<Result<void>> addComment(String postId, String text) async {
    addCalls.add((postId: postId, text: text));
    await addGate?.future;
    final comment = addedComment;
    if (addResult is Ok<void> && comment != null) {
      _write([..._comments, comment]);
    }
    return addResult;
  }

  @override
  Future<Result<void>> deleteComment(String commentId) async {
    deleteCalls.add(commentId);
    if (deleteResult is Ok<void>) {
      _write([
        for (final comment in _comments)
          if (comment.id != commentId) comment,
      ]);
    }
    return deleteResult;
  }

  void _write(List<Comment> comments) {
    _comments = comments;
    _changes.add(comments);
  }

  Future<void> dispose() => _changes.close();
}
