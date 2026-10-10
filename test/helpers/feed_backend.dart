import 'package:clock/clock.dart';
import 'package:connect_hub/core/database/app_database.dart';
import 'package:connect_hub/core/network/api/fake_api_client.dart';
import 'package:connect_hub/core/network/api/fake_feed_api_service.dart';
import 'package:connect_hub/core/network/fake_server/fake_server.dart';
import 'package:connect_hub/core/network/fake_server/network_simulator.dart';
import 'package:connect_hub/core/storage/session_storage.dart';
import 'package:connect_hub/data/repository/api_guard.dart';
import 'package:connect_hub/data/repository/feed_repository_impl.dart';
import 'package:connect_hub/data/repository/post_repository_impl.dart';
import 'package:connect_hub/domain/model/session_state.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'backend.dart';
import 'fakes/fake_session_repository.dart';
import 'fakes/gated_feed_api.dart';
import 'fixtures.dart';
import 'test_dependencies.dart';

/// The feed's real data stack for repository tests: the fake server, its API
/// service and an in-memory database, signed in as the demo user. Only the
/// network latency (zero) and the session repository (a fake) are swapped.
///
/// Call [dispose] in `tearDown`.
class FeedBackend {
  FeedBackend({Clock? clientClock}) {
    FlutterSecureStorage.setMockInitialValues(storedDemoSession());
    api = GatedFeedApi(
      FakeFeedApiService(
        FakeApiClient(
          const SessionStorage(FlutterSecureStorage()),
          network,
          server,
        ),
        server,
      ),
    );
    guard = ApiGuard(sessions);
    feed = FeedRepositoryImpl(api, database.feedDao, guard);
    posts = PostRepositoryImpl(
      api,
      database.postsDao,
      guard,
      clientClock ?? Clock.fixed(testNow),
    );
  }

  final FakeServer server = newFakeServer();
  final NetworkSimulator network = NetworkSimulator(latencyFactor: 0);
  final AppDatabase database = newTestDatabase();
  final FakeSessionRepository sessions = FakeSessionRepository(
    initial: const SessionState.signedIn(demoSession),
  );
  late final GatedFeedApi api;
  late final ApiGuard guard;
  late final FeedRepositoryImpl feed;
  late final PostRepositoryImpl posts;

  /// The ids in the cached feed window, in order.
  Future<List<String>> feedIds() async => [
    for (final post in await feed.watchFeed().first) post.id,
  ];

  Future<void> dispose() async {
    await sessions.dispose();
    await database.close();
  }
}
