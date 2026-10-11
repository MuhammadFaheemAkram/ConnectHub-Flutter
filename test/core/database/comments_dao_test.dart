import 'package:async/async.dart' show StreamQueue;
import 'package:connect_hub/core/database/app_database.dart';
import 'package:connect_hub/core/database/daos/comments_dao.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/backend.dart';
import '../../helpers/database_rows.dart';
import '../../helpers/stream_helpers.dart';

void main() {
  late AppDatabase database;
  late CommentsDao dao;

  setUp(() async {
    database = newTestDatabase();
    dao = database.commentsDao;
    // Comments need their post.
    await database.postsDao.upsertPosts([cachedPost('p1'), cachedPost('p2')]);
  });

  tearDown(() => database.close());

  Future<List<String>> ids(String postId) async => [
    for (final entry in await dao.watchComments(postId).first) entry.comment.id,
  ];

  Future<int> countOf(String postId) async => (await (database.select(
    database.posts,
  )..where((post) => post.id.equals(postId))).getSingle()).commentCount;

  test(
    'comments come oldest first (ties by id), each with its author',
    () async {
      await dao.replaceComments('p1', [
        cachedComment('c2', minutesAgo: 10),
        cachedComment('c1', minutesAgo: 30, authorId: 'u_ada'),
        cachedComment('c3', minutesAgo: 10),
      ]);

      final comments = await dao.watchComments('p1').first;

      expect([for (final e in comments) e.comment.id], ['c1', 'c2', 'c3']);
      expect(comments.first.author.id, 'u_ada');
    },
  );

  test('a refresh mirrors the server: new ones in, deleted ones out, and '
      'the count matches', () async {
    await dao.replaceComments('p1', [cachedComment('c1'), cachedComment('c2')]);

    await dao.replaceComments('p1', [cachedComment('c2'), cachedComment('c3')]);

    expect(await ids('p1'), ['c2', 'c3']);
    expect(await countOf('p1'), 2);
  });

  test("a refresh only touches its own post's comments", () async {
    await dao.replaceComments('p2', [cachedComment('c9', postId: 'p2')]);

    await dao.replaceComments('p1', [cachedComment('c1')]);

    expect(await ids('p2'), ['c9']);
  });

  test(
    'adding counts the comment; removing uncounts it and returns it',
    () async {
      await dao.replaceComments('p1', [cachedComment('c1')]);

      await dao.addComment(cachedComment('c2'));
      expect(await countOf('p1'), 2);

      final removed = await dao.removeComment('c2');
      expect(removed?.comment.id, 'c2');
      expect(await ids('p1'), ['c1']);
      expect(await countOf('p1'), 1);
    },
  );

  test('restoring puts a removed comment back, counted', () async {
    await dao.replaceComments('p1', [cachedComment('c1')]);
    final removed = await dao.removeComment('c1');

    await dao.restoreComment(removed!);

    expect(await ids('p1'), ['c1']);
    expect(await countOf('p1'), 1);
  });

  test('the count never goes below zero', () async {
    await dao.addComment(cachedComment('c1'));
    await database.postsDao.upsertPosts([cachedPost('p1')]); // count: 0

    await dao.removeComment('c1');

    expect(await countOf('p1'), 0);
  });

  test('writes for a post that left the cache do nothing (no foreign-key '
      'error, nothing brought back)', () async {
    await dao.addComment(cachedComment('c1', postId: 'p404'));
    await dao.replaceComments('p404', [cachedComment('c2', postId: 'p404')]);

    expect(await database.select(database.comments).get(), isEmpty);
  });

  test(
    'deleting a post takes its comments with it (ON DELETE CASCADE)',
    () async {
      await dao.replaceComments('p1', [cachedComment('c1')]);

      await database.postsDao.deletePost('p1');

      expect(await database.select(database.comments).get(), isEmpty);
    },
  );

  test('watchComments emits the list again on every change', () async {
    final lists = StreamQueue(
      dao.watchComments('p1').map((e) => [for (final c in e) c.comment.id]),
    );
    addTearDown(lists.cancel);

    expect(await nextEvent(lists), isEmpty);
    await dao.addComment(cachedComment('c1'));
    expect(await nextEvent(lists), ['c1']);
  });
}
