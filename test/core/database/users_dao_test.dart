import 'package:connect_hub/core/database/app_database.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/backend.dart';
import '../../helpers/database_rows.dart';

void main() {
  late AppDatabase database;

  setUp(() => database = newTestDatabase());

  tearDown(() => database.close());

  test(
    'watchUser is null until the profile is cached, then follows it',
    () async {
      final dao = database.usersDao;
      expect(await dao.watchUser('u_ada').first, isNull);

      await dao.upsertUser(userRow('u_ada', name: 'Ada Lovelace'));

      expect((await dao.watchUser('u_ada').first)?.name, 'Ada Lovelace');
    },
  );

  test('one upsert renames the author on every cached post and comment '
      '(they JOIN the row)', () async {
    await database.postsDao.upsertPosts([cachedPost('p1'), cachedPost('p2')]);
    await database.commentsDao.addComment(
      cachedComment('c1', authorId: 'u_ada'),
    );

    await database.usersDao.upsertUser(userRow('u_ada', name: 'Ada King'));

    final posts = await database.postsDao.watchPostsByAuthor('u_ada').first;
    expect(posts.map((entry) => entry.author.name), ['Ada King', 'Ada King']);
    final comments = await database.commentsDao.watchComments('p1').first;
    expect(comments.single.author.name, 'Ada King');
  });
}
