import 'package:connect_hub/core/database/app_database.dart';
import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift_dev/api/migrations_native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'generated/schema.dart';
import 'generated/schema_v1.dart' as v1;
import 'generated/schema_v2.dart' as v2;
import 'generated/schema_v3.dart' as v3;
import 'generated/schema_v4.dart' as v4;

// Migration tests, set up by `drift_dev make-migrations`. The `generated/`
// folder holds a snapshot of every exported schema version
// (`drift_schemas/`), so each test can build a database exactly as an older
// app version left it, run today's migration on it, and compare the result
// with the expected schema.
void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  late SchemaVerifier verifier;

  setUpAll(() => verifier = SchemaVerifier(GeneratedHelper()));

  group('every upgrade path ends in the current schema', () {
    // From each exported version to every later one. A new version adds its
    // paths here automatically.
    const versions = GeneratedHelper.versions;
    for (final (i, fromVersion) in versions.indexed) {
      group('from v$fromVersion', () {
        for (final toVersion in versions.skip(i + 1)) {
          test('to v$toVersion', () async {
            final schema = await verifier.schemaAt(fromVersion);
            final database = AppDatabase(schema.newConnection());
            await verifier.migrateAndValidate(database, toVersion);
            await database.close();
          });
        }
      });
    }
  });

  test('v1 → v2 keeps every cached author, post, feed item and bookmark, '
      'and starts with no comments', () async {
    // The snapshots store values as SQLite does: dates as ISO-8601 text,
    // booleans as 0 / 1.
    const createdAt = '2026-10-11T09:40:00.000Z';
    const bookmarkedAt = '2026-10-11T10:00:00.000Z';

    await verifier.testWithDataIntegrity(
      oldVersion: 1,
      newVersion: 2,
      createOld: v1.DatabaseAtV1.new,
      createNew: v2.DatabaseAtV2.new,
      openTestedDatabase: AppDatabase.new,
      createItems: (batch, oldDb) {
        batch
          ..insertAll(oldDb.users, const [
            v1.UsersData(
              id: 'u_ada',
              name: 'Ada Lovelace',
              bio: 'Enchantress of numbers.',
              followersCount: 4820,
              followingCount: 312,
            ),
          ])
          ..insertAll(oldDb.posts, const [
            v1.PostsData(
              id: 'p1',
              authorId: 'u_ada',
              content: 'Just shipped the scheduler.',
              createdAt: createdAt,
              likeCount: 142,
              commentCount: 3,
              isLiked: 1,
            ),
          ])
          ..insertAll(oldDb.feedItems, const [v1.FeedItemsData(postId: 'p1')])
          ..insertAll(oldDb.bookmarks, const [
            v1.BookmarksData(postId: 'p1', bookmarkedAt: bookmarkedAt),
          ]);
      },
      validateItems: (newDb) async {
        expect(await newDb.select(newDb.users).get(), const [
          v2.UsersData(
            id: 'u_ada',
            name: 'Ada Lovelace',
            bio: 'Enchantress of numbers.',
            followersCount: 4820,
            followingCount: 312,
          ),
        ]);
        expect(await newDb.select(newDb.posts).get(), const [
          v2.PostsData(
            id: 'p1',
            authorId: 'u_ada',
            content: 'Just shipped the scheduler.',
            createdAt: createdAt,
            likeCount: 142,
            commentCount: 3,
            isLiked: 1,
          ),
        ]);
        expect(await newDb.select(newDb.feedItems).get(), const [
          v2.FeedItemsData(postId: 'p1'),
        ]);
        expect(await newDb.select(newDb.bookmarks).get(), const [
          v2.BookmarksData(postId: 'p1', bookmarkedAt: bookmarkedAt),
        ]);
        expect(await newDb.select(newDb.comments).get(), isEmpty);
      },
    );
  });

  test('v2 → v3 keeps every cached author, post, feed item, bookmark and '
      'comment, and starts with no recent searches', () async {
    const createdAt = '2026-10-11T09:40:00.000Z';
    const bookmarkedAt = '2026-10-11T10:00:00.000Z';
    const commentedAt = '2026-10-11T10:30:00.000Z';

    await verifier.testWithDataIntegrity(
      oldVersion: 2,
      newVersion: 3,
      createOld: v2.DatabaseAtV2.new,
      createNew: v3.DatabaseAtV3.new,
      openTestedDatabase: AppDatabase.new,
      createItems: (batch, oldDb) {
        batch
          ..insertAll(oldDb.users, const [
            v2.UsersData(
              id: 'u_ada',
              name: 'Ada Lovelace',
              bio: 'Enchantress of numbers.',
              followersCount: 4820,
              followingCount: 312,
            ),
            v2.UsersData(
              id: 'u_grace',
              name: 'Grace Hopper',
              bio: '',
              followersCount: 9120,
              followingCount: 87,
            ),
          ])
          ..insertAll(oldDb.posts, const [
            v2.PostsData(
              id: 'p1',
              authorId: 'u_ada',
              content: 'Just shipped the scheduler.',
              createdAt: createdAt,
              likeCount: 142,
              commentCount: 1,
              isLiked: 0,
            ),
          ])
          ..insertAll(oldDb.feedItems, const [v2.FeedItemsData(postId: 'p1')])
          ..insertAll(oldDb.bookmarks, const [
            v2.BookmarksData(postId: 'p1', bookmarkedAt: bookmarkedAt),
          ])
          ..insertAll(oldDb.comments, const [
            v2.CommentsData(
              id: 'c1',
              postId: 'p1',
              authorId: 'u_grace',
              content: 'Lovely work.',
              createdAt: commentedAt,
            ),
          ]);
      },
      validateItems: (newDb) async {
        expect(await newDb.select(newDb.users).get(), const [
          v3.UsersData(
            id: 'u_ada',
            name: 'Ada Lovelace',
            bio: 'Enchantress of numbers.',
            followersCount: 4820,
            followingCount: 312,
          ),
          v3.UsersData(
            id: 'u_grace',
            name: 'Grace Hopper',
            bio: '',
            followersCount: 9120,
            followingCount: 87,
          ),
        ]);
        expect(await newDb.select(newDb.posts).get(), const [
          v3.PostsData(
            id: 'p1',
            authorId: 'u_ada',
            content: 'Just shipped the scheduler.',
            createdAt: createdAt,
            likeCount: 142,
            commentCount: 1,
            isLiked: 0,
          ),
        ]);
        expect(await newDb.select(newDb.feedItems).get(), const [
          v3.FeedItemsData(postId: 'p1'),
        ]);
        expect(await newDb.select(newDb.bookmarks).get(), const [
          v3.BookmarksData(postId: 'p1', bookmarkedAt: bookmarkedAt),
        ]);
        expect(await newDb.select(newDb.comments).get(), const [
          v3.CommentsData(
            id: 'c1',
            postId: 'p1',
            authorId: 'u_grace',
            content: 'Lovely work.',
            createdAt: commentedAt,
          ),
        ]);
        expect(await newDb.select(newDb.recentSearches).get(), isEmpty);
      },
    );
  });

  test('v3 → v4 keeps every cached row and the recent searches, and starts '
      'with no conversations, messages or notifications', () async {
    const createdAt = '2026-10-11T09:40:00.000Z';
    const bookmarkedAt = '2026-10-11T10:00:00.000Z';
    const commentedAt = '2026-10-11T10:30:00.000Z';
    const searchedAt = '2026-10-11T11:00:00.000Z';

    await verifier.testWithDataIntegrity(
      oldVersion: 3,
      newVersion: 4,
      createOld: v3.DatabaseAtV3.new,
      createNew: v4.DatabaseAtV4.new,
      openTestedDatabase: AppDatabase.new,
      createItems: (batch, oldDb) {
        batch
          ..insertAll(oldDb.users, const [
            v3.UsersData(
              id: 'u_ada',
              name: 'Ada Lovelace',
              bio: 'Enchantress of numbers.',
              followersCount: 4820,
              followingCount: 312,
            ),
          ])
          ..insertAll(oldDb.posts, const [
            v3.PostsData(
              id: 'p1',
              authorId: 'u_ada',
              content: 'Just shipped the scheduler.',
              createdAt: createdAt,
              likeCount: 142,
              commentCount: 1,
              isLiked: 1,
            ),
          ])
          ..insertAll(oldDb.feedItems, const [v3.FeedItemsData(postId: 'p1')])
          ..insertAll(oldDb.bookmarks, const [
            v3.BookmarksData(postId: 'p1', bookmarkedAt: bookmarkedAt),
          ])
          ..insertAll(oldDb.comments, const [
            v3.CommentsData(
              id: 'c1',
              postId: 'p1',
              authorId: 'u_ada',
              content: 'Thanks, all.',
              createdAt: commentedAt,
            ),
          ])
          ..insertAll(oldDb.recentSearches, const [
            v3.RecentSearchesData(
              normalizedQuery: 'ada',
              displayText: 'Ada',
              searchedAt: searchedAt,
            ),
          ]);
      },
      validateItems: (newDb) async {
        expect(await newDb.select(newDb.users).get(), const [
          v4.UsersData(
            id: 'u_ada',
            name: 'Ada Lovelace',
            bio: 'Enchantress of numbers.',
            followersCount: 4820,
            followingCount: 312,
          ),
        ]);
        expect(await newDb.select(newDb.posts).get(), const [
          v4.PostsData(
            id: 'p1',
            authorId: 'u_ada',
            content: 'Just shipped the scheduler.',
            createdAt: createdAt,
            likeCount: 142,
            commentCount: 1,
            isLiked: 1,
          ),
        ]);
        expect(await newDb.select(newDb.feedItems).get(), const [
          v4.FeedItemsData(postId: 'p1'),
        ]);
        expect(await newDb.select(newDb.bookmarks).get(), const [
          v4.BookmarksData(postId: 'p1', bookmarkedAt: bookmarkedAt),
        ]);
        expect(await newDb.select(newDb.comments).get(), const [
          v4.CommentsData(
            id: 'c1',
            postId: 'p1',
            authorId: 'u_ada',
            content: 'Thanks, all.',
            createdAt: commentedAt,
          ),
        ]);
        expect(await newDb.select(newDb.recentSearches).get(), const [
          v4.RecentSearchesData(
            normalizedQuery: 'ada',
            displayText: 'Ada',
            searchedAt: searchedAt,
          ),
        ]);
        expect(await newDb.select(newDb.conversations).get(), isEmpty);
        expect(await newDb.select(newDb.messages).get(), isEmpty);
        expect(await newDb.select(newDb.notifications).get(), isEmpty);
      },
    );
  });
}
