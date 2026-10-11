import 'package:connect_hub/core/database/app_database.dart';
import 'package:connect_hub/core/database/daos/bookmarks_dao.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/backend.dart';
import '../../helpers/database_rows.dart';

void main() {
  late AppDatabase database;
  late BookmarksDao dao;

  setUp(() {
    database = newTestDatabase();
    dao = database.bookmarksDao;
  });

  tearDown(() => database.close());

  DateTime minutesAgo(int minutes) =>
      testNow.subtract(Duration(minutes: minutes));

  Future<List<String>> bookmarkedIds() async => [
    for (final entry in await dao.watchBookmarks().first) entry.post.id,
  ];

  test('lists only bookmarked posts, the most recently bookmarked first, '
      'with their authors', () async {
    await database.postsDao.upsertPosts([
      cachedPost('p1', bookmarkedAt: minutesAgo(30)),
      cachedPost('p2'),
      cachedPost('p3', authorId: 'u_grace', bookmarkedAt: minutesAgo(5)),
    ]);

    final bookmarks = await dao.watchBookmarks().first;

    expect([for (final entry in bookmarks) entry.post.id], ['p3', 'p1']);
    expect(bookmarks.first.author.id, 'u_grace');
    expect(bookmarks.first.bookmarkedAt, minutesAgo(5));
  });

  test('replaceBookmarks mirrors the server: a bookmark it no longer has '
      'goes, the post itself stays cached (and in the feed)', () async {
    await database.feedDao.replaceFeed([
      cachedPost('p1', bookmarkedAt: minutesAgo(30)),
      cachedPost('p2', bookmarkedAt: minutesAgo(20)),
    ]);

    await dao.replaceBookmarks([
      cachedPost('p2', bookmarkedAt: minutesAgo(20)),
      cachedPost('p3', bookmarkedAt: minutesAgo(1)),
    ]);

    expect(await bookmarkedIds(), ['p3', 'p2']);
    final feed = await database.feedDao.watchFeed().first;
    final p1 = feed.singleWhere((entry) => entry.post.id == 'p1');
    expect(feed, hasLength(2));
    expect(p1.bookmarkedAt, isNull);
  });

  test('an empty answer removes every bookmark', () async {
    await database.postsDao.upsertPosts([
      cachedPost('p1', bookmarkedAt: minutesAgo(30)),
    ]);

    await dao.replaceBookmarks(const []);

    expect(await bookmarkedIds(), isEmpty);
  });
}
