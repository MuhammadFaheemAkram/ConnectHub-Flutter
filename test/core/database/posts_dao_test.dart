import 'package:connect_hub/core/database/app_database.dart';
import 'package:connect_hub/core/database/daos/posts_dao.dart';
import 'package:drift/drift.dart' show InsertMode;
import 'package:drift/native.dart' show SqliteException;
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/backend.dart';
import '../../helpers/database_rows.dart';

void main() {
  late AppDatabase database;
  late PostsDao dao;

  setUp(() {
    database = newTestDatabase();
    dao = database.postsDao;
  });

  tearDown(() => database.close());

  Future<PostRow?> postRow(String id) => (database.select(
    database.posts,
  )..where((post) => post.id.equals(id))).getSingleOrNull();

  Future<DateTime?> bookmarkOf(String id) async {
    final query = database.select(database.bookmarks)
      ..where((bookmark) => bookmark.postId.equals(id));
    return (await query.getSingleOrNull())?.bookmarkedAt;
  }

  final noon = DateTime.utc(2026, 10, 11, 12);

  group('schema', () {
    test('foreign keys are enforced (the pragma is on)', () async {
      final pragma = await database
          .customSelect('PRAGMA foreign_keys')
          .getSingle();
      expect(pragma.read<int>('foreign_keys'), 1);

      // A bookmark for a post that isn't cached violates its REFERENCES.
      await expectLater(
        database
            .into(database.bookmarks)
            .insert(BookmarkRow(postId: 'missing', bookmarkedAt: noon)),
        throwsA(isA<SqliteException>()),
      );
    });
  });

  group('upsertPosts', () {
    test('stores posts, their authors and the viewer\'s bookmarks', () async {
      await dao.upsertPosts([
        cachedPost('p1', bookmarkedAt: noon),
        cachedPost('p2', authorId: 'u_grace'),
      ]);

      expect((await postRow('p1'))!.authorId, 'u_ada');
      expect(await database.select(database.users).get(), hasLength(2));
      expect(await bookmarkOf('p1'), noon);
      expect(await bookmarkOf('p2'), isNull);
    });

    test('the server\'s answer wins: a bookmark it no longer reports goes, '
        'and one it reports comes back with its time', () async {
      await dao.upsertPosts([cachedPost('p1', bookmarkedAt: noon)]);
      await dao.upsertPosts([
        cachedPost('p1'),
        cachedPost('p2', bookmarkedAt: noon),
      ]);

      expect(await bookmarkOf('p1'), isNull);
      expect(await bookmarkOf('p2'), noon);
    });

    test('regression: re-caching a post keeps what references it (an upsert '
        'never deletes the row)', () async {
      await database.feedDao.replaceFeed([cachedPost('p1')]);

      // The same post arrives again, e.g. from a refresh or another screen.
      await dao.upsertPosts([cachedPost('p1', likeCount: 99)]);

      expect((await postRow('p1'))!.likeCount, 99);
      expect(await database.select(database.feedItems).get(), hasLength(1));
    });

    test('why: REPLACE deletes the old row first, and the delete cascades '
        '(the Android edition lost bookmarks this way)', () async {
      await dao.upsertPosts([cachedPost('p1', bookmarkedAt: noon)]);

      await database
          .into(database.posts)
          .insert(cachedPost('p1').post, mode: InsertMode.insertOrReplace);

      expect(await bookmarkOf('p1'), isNull);
    });
  });

  group('likes', () {
    test('applyLike flips the like at once, moves the count by one, and '
        'returns the state from before', () async {
      await dao.upsertPosts([cachedPost('p1')]);

      final before = await dao.applyLike('p1', liked: true);

      expect(before, (isLiked: false, likeCount: 10));
      final row = (await postRow('p1'))!;
      expect(row.isLiked, isTrue);
      expect(row.likeCount, 11);
    });

    test('applying the same like twice counts it once', () async {
      await dao.upsertPosts([cachedPost('p1')]);

      await dao.applyLike('p1', liked: true);
      await dao.applyLike('p1', liked: true);

      expect((await postRow('p1'))!.likeCount, 11);
    });

    test('an uncached post has nothing to apply or restore', () async {
      expect(await dao.applyLike('p1', liked: true), isNull);
    });

    test(
      'writeLike only updates: it never brings a deleted post back',
      () async {
        await dao.writeLike('p1', (isLiked: true, likeCount: 5));

        expect(await postRow('p1'), isNull);
      },
    );
  });

  group('bookmarks', () {
    test('applyBookmark adds or removes it and returns the time from '
        'before', () async {
      await dao.upsertPosts([cachedPost('p1')]);

      expect(await dao.applyBookmark('p1', at: noon), isNull);
      expect(await bookmarkOf('p1'), noon);

      expect(await dao.applyBookmark('p1', at: null), noon);
      expect(await bookmarkOf('p1'), isNull);
    });

    test('writeBookmark skips a post that isn\'t cached', () async {
      await dao.writeBookmark('p1', at: noon);

      expect(await database.select(database.bookmarks).get(), isEmpty);
    });
  });
}
