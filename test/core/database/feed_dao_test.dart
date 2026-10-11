import 'package:async/async.dart' show StreamQueue;
import 'package:connect_hub/core/database/app_database.dart';
import 'package:connect_hub/core/database/daos/feed_dao.dart';
import 'package:connect_hub/core/database/daos/posts_dao.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/backend.dart';
import '../../helpers/database_rows.dart';
import '../../helpers/stream_helpers.dart';

void main() {
  late AppDatabase database;
  late FeedDao dao;

  setUp(() {
    database = newTestDatabase();
    dao = database.feedDao;
  });

  tearDown(() => database.close());

  List<String> ids(List<CachedPost> posts) => [
    for (final entry in posts) entry.post.id,
  ];

  test('the feed is newest first, with ties broken by id', () async {
    await dao.replaceFeed([
      cachedPost('p1', minutesAgo: 30),
      cachedPost('p2', minutesAgo: 5),
      cachedPost('p3', minutesAgo: 30),
    ]);

    expect(ids(await dao.watchFeed().first), ['p2', 'p3', 'p1']);
  });

  test('each post comes with its author and the viewer\'s bookmark', () async {
    final noon = DateTime.utc(2026, 10, 11, 12);
    await dao.replaceFeed([
      cachedPost('p1', authorId: 'u_grace', bookmarkedAt: noon),
    ]);

    final post = (await dao.watchFeed().first).single;

    expect(post.author.id, 'u_grace');
    expect(post.bookmarkedAt, noon);
  });

  test('a refresh replaces the window', () async {
    await dao.replaceFeed([cachedPost('p1'), cachedPost('p2')]);

    await dao.replaceFeed([cachedPost('p3')]);

    expect(ids(await dao.watchFeed().first), ['p3']);
  });

  test('load more appends, and never lists a post twice', () async {
    await dao.replaceFeed([cachedPost('p1'), cachedPost('p2', minutesAgo: 1)]);

    await dao.addToFeed([
      cachedPost('p2', minutesAgo: 1),
      cachedPost('p3', minutesAgo: 2),
    ]);

    expect(ids(await dao.watchFeed().first), ['p1', 'p2', 'p3']);
  });

  test('posts cached by other screens stay out of the feed', () async {
    await dao.replaceFeed([cachedPost('p1')]);

    // e.g. a search result (Phase 5): cached, but not part of the feed.
    await database.postsDao.upsertPosts([cachedPost('p9')]);

    expect(ids(await dao.watchFeed().first), ['p1']);
  });

  test('a replaced window is announced once: never empty in between', () async {
    final windows = StreamQueue(dao.watchFeed().map(ids));
    addTearDown(windows.cancel);
    expect(await nextEvent(windows), isEmpty);

    await dao.replaceFeed([cachedPost('p1')]);
    expect(await nextEvent(windows), ['p1']);

    await dao.replaceFeed([cachedPost('p2')]);
    expect(await nextEvent(windows), ['p2']);
  });

  test('a renamed author is renamed on every post (the JOIN)', () async {
    await dao.replaceFeed([cachedPost('p1'), cachedPost('p2', minutesAgo: 1)]);

    await database
        .into(database.users)
        .insertOnConflictUpdate(userRow('u_ada', name: 'Countess Lovelace'));

    final names = [
      for (final post in await dao.watchFeed().first) post.author.name,
    ];
    expect(names, ['Countess Lovelace', 'Countess Lovelace']);
  });
}
