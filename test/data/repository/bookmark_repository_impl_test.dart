import 'package:clock/clock.dart';
import 'package:connect_hub/core/common/app_exception.dart';
import 'package:connect_hub/core/common/result.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/backend.dart';
import '../../helpers/data_stack.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late DataStack backend;
  var now = testNow;

  setUp(() {
    now = testNow;
    // A clock the test moves, shared by both sides.
    final clock = Clock(() => now);
    backend = DataStack(clientClock: clock, serverClock: clock);
  });

  tearDown(() => backend.dispose());

  Future<List<String>> bookmarkedIds() async => [
    for (final post in await backend.bookmarks.watchBookmarks().first) post.id,
  ];

  test("refresh caches the server's bookmarks, the most recently "
      'bookmarked first', () async {
    // Bookmarked on the server, e.g. on another device: p2 first, then p1.
    await backend.server.setBookmarked('u_demo', 'p2', bookmarked: true);
    now = now.add(const Duration(minutes: 1));
    await backend.server.setBookmarked('u_demo', 'p1', bookmarked: true);

    expect(await backend.bookmarks.refreshBookmarks(), isA<Ok<void>>());

    final bookmarks = await backend.bookmarks.watchBookmarks().first;
    expect(bookmarks.map((post) => post.id), ['p1', 'p2']);
    expect(bookmarks.every((post) => post.isBookmarked), isTrue);
  });

  test('a bookmark made on any screen shows at once, before the server '
      'answers', () async {
    await backend.feed.refresh();

    final bookmarking = backend.posts.setBookmarked('p3', bookmarked: true);
    expect(await bookmarkedIds(), ['p3']);
    await bookmarking;
  });

  test('refresh mirrors the server: a bookmark removed elsewhere goes, and '
      'the post stays in the feed', () async {
    await backend.feed.refresh();
    await backend.posts.setBookmarked('p3', bookmarked: true);
    await backend.server.setBookmarked('u_demo', 'p3', bookmarked: false);

    await backend.bookmarks.refreshBookmarks();

    expect(await bookmarkedIds(), isEmpty);
    expect(await backend.feedIds(), contains('p3'));
  });

  test('a failed refresh keeps the cached bookmarks', () async {
    await backend.feed.refresh();
    await backend.posts.setBookmarked('p3', bookmarked: true);
    backend.network.failRequests = true;

    final result = await backend.bookmarks.refreshBookmarks();

    expect(
      result,
      isA<Err<void>>().having(
        (err) => err.exception,
        'exception',
        isA<NetworkException>(),
      ),
    );
    expect(await bookmarkedIds(), ['p3']);
  });
}
