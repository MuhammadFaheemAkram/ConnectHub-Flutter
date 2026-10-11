import 'package:async/async.dart' show StreamQueue;
import 'package:connect_hub/data/repository/cache_repository_impl.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/data_stack.dart';
import '../../helpers/stream_helpers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late DataStack backend;
  CacheRepositoryImpl cache() => backend.cache;

  setUp(() => backend = DataStack());

  tearDown(() async {
    await cache().dispose();
    await backend.dispose();
  });

  test("clearing deletes the server's data, keeps the bookmarks, and tells "
      'the screens', () async {
    await backend.feed.refresh();
    await backend.posts.setBookmarked('p3', bookmarked: true);
    await backend.notifications.refresh();
    final cleared = StreamQueue(cache().watchCleared());
    addTearDown(cleared.cancel);

    await cache().clearCache();

    await nextEvent(cleared);
    expect(await backend.feedIds(), isEmpty);
    expect(await backend.notifications.watchNotifications().first, isEmpty);
    final bookmarks = await backend.bookmarks.watchBookmarks().first;
    expect(bookmarks.map((post) => post.id), ['p3']);
  });

  test('signed out, there is nothing to clear', () async {
    await backend.feed.refresh();
    await backend.sessions.clear();
    var signalled = false;
    final subscription = cache().watchCleared().listen((_) => signalled = true);
    addTearDown(subscription.cancel);

    await cache().clearCache();
    await pumpEventQueue();

    expect(signalled, isFalse);
    expect(await backend.feedIds(), isNotEmpty);
  });
}
