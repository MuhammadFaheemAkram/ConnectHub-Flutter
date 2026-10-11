import 'dart:async';

import 'package:connect_hub/core/common/first_value.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/backend.dart';
import '../../helpers/database_rows.dart';

void main() {
  test('completes with the first value', () async {
    expect(await Stream.fromIterable([1, 2, 3]).firstValue, 1);
  });

  test('passes an error on, and an empty stream is an error', () {
    expect(
      Stream<int>.error(const FormatException('bad')).firstValue,
      throwsFormatException,
    );
    expect(const Stream<int>.empty().firstValue, throwsStateError);
  });

  testWidgets('regression: completes on a drift stream under the fake async '
      'of widget tests, where Stream.first never does', (tester) async {
    final database = newTestDatabase();
    addTearDown(database.close);
    await database.postsDao.upsertPosts([cachedPost('p1')]);

    var value = 0;
    unawaited(
      database.commentsDao
          .watchComments('p1')
          .firstValue
          .then((comments) => value = comments.length + 1),
    );
    await tester.pump(const Duration(seconds: 1));

    expect(value, 1);
  });
}
