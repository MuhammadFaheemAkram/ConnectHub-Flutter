import 'dart:async';

import 'package:connect_hub/core/common/app_exception.dart';
import 'package:connect_hub/core/common/result.dart';
import 'package:connect_hub/domain/model/comment.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/data_stack.dart';
import '../../helpers/database_rows.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late DataStack backend;

  setUp(() async {
    backend = DataStack();
    await backend.feed.refresh(); // caches page 1: p1, p2, p3, p16, p4, p5
  });

  tearDown(() => backend.dispose());

  Future<List<Comment>> commentsOn(String postId) =>
      backend.comments.watchComments(postId).first;

  Future<List<String>> idsOn(String postId) async => [
    for (final comment in await commentsOn(postId)) comment.id,
  ];

  Future<int?> countOn(String postId) async =>
      (await backend.posts.watchPost(postId).first)?.commentCount;

  Matcher isErr(Matcher exception) =>
      isA<Err<void>>().having((err) => err.exception, 'exception', exception);

  group('refresh', () {
    test(
      "caches the post's comments, oldest first, none of them mine",
      () async {
        expect(await backend.comments.refreshComments('p1'), isA<Ok<void>>());

        final comments = await commentsOn('p1');
        expect([for (final c in comments) c.id], ['c1', 'c2', 'c3']);
        expect(comments.map((c) => c.isMine), everyElement(isFalse));
        expect(await countOn('p1'), 3);
      },
    );

    test('mirrors the server: a comment it no longer has goes', () async {
      await backend.database.commentsDao.addComment(cachedComment('c_stale'));

      await backend.comments.refreshComments('p1');

      expect(await idsOn('p1'), ['c1', 'c2', 'c3']);
    });

    test('for a post that is not cached yet (a deep link), the post is '
        'fetched first, so its comments have somewhere to go', () async {
      // p10 is on page 2, so it isn't cached.
      expect(await backend.comments.refreshComments('p10'), isA<Ok<void>>());

      expect(backend.commentApi.requests, contains('comments:p10'));
      expect(backend.api.requests, contains('post:p10'));
      expect(await idsOn('p10'), ['c11']);
    });

    test('a post the server no longer has: not found, and the cached copy '
        'goes', () async {
      await backend.database.postsDao.upsertPosts([cachedPost('p_gone')]);

      final result = await backend.comments.refreshComments('p_gone');

      expect(result, isErr(isA<NotFoundException>()));
      expect(await backend.posts.watchPost('p_gone').first, isNull);
    });
  });

  group('add', () {
    test('caches the accepted comment as mine, and counts it', () async {
      final result = await backend.comments.addComment('p4', 'Nice one');

      expect(result, isA<Ok<void>>());
      final comment = (await commentsOn('p4')).single;
      expect(comment.text, 'Nice one');
      expect(comment.isMine, isTrue);
      expect(comment.author.name, 'Demo User');
      expect(await countOn('p4'), 1);
    });

    test('a failure caches nothing', () async {
      backend.network.failRequests = true;

      final result = await backend.comments.addComment('p4', 'Nice one');

      expect(result, isErr(isA<NetworkException>()));
      expect(await commentsOn('p4'), isEmpty);
      expect(await countOn('p4'), 0);
    });
  });

  group('delete', () {
    test('my comment goes at once, the count drops, and the server '
        'confirms', () async {
      await backend.comments.addComment('p4', 'Mine');
      final mine = (await commentsOn('p4')).single;
      backend.commentApi.gate = Completer<void>();

      final deleting = backend.comments.deleteComment(mine.id);
      await pumpEventQueue();
      // Optimistic: the server hasn't answered yet.
      expect(await commentsOn('p4'), isEmpty);
      expect(await countOn('p4'), 0);

      backend.commentApi.gate!.complete();
      expect(await deleting, isA<Ok<void>>());
      expect(await backend.server.getComments('p4'), isEmpty);
    });

    test(
      "someone else's comment is refused by the server, and comes back",
      () async {
        await backend.comments.refreshComments('p1');

        final result = await backend.comments.deleteComment('c1');

        expect(result, isErr(isA<NotFoundException>()));
        expect(await idsOn('p1'), ['c1', 'c2', 'c3']);
        expect(await countOn('p1'), 3);
      },
    );

    test('offline, my comment comes back where it was', () async {
      await backend.comments.refreshComments('p1');
      await backend.comments.addComment('p1', 'Mine');
      final mine = (await commentsOn('p1')).last;
      backend.network.failRequests = true;

      final result = await backend.comments.deleteComment(mine.id);

      expect(result, isErr(isA<NetworkException>()));
      expect(await idsOn('p1'), ['c1', 'c2', 'c3', mine.id]);
      expect(await countOn('p1'), 4);
    });
  });
}
