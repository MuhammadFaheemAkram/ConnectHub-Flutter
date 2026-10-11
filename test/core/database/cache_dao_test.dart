import 'package:connect_hub/core/database/app_database.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/backend.dart';
import '../../helpers/database_rows.dart';

void main() {
  late AppDatabase database;

  setUp(() => database = newTestDatabase());

  tearDown(() => database.close());

  test('clearAll leaves every table empty, recent searches included', () async {
    await database.feedDao.replaceFeed([
      cachedPost('p1', bookmarkedAt: testNow),
      cachedPost('p2', authorId: 'u_grace'),
    ]);
    await database.commentsDao.addComment(cachedComment('c1'));
    await database.searchDao.saveRecentSearch('ada', at: testNow);

    await database.cacheDao.clearAll();

    // Every table, so one added by a later schema version without being
    // cleared here fails this test.
    for (final table in database.allTables) {
      final rows = await database.select(table).get();
      expect(rows, isEmpty, reason: table.actualTableName);
    }
  });
}
