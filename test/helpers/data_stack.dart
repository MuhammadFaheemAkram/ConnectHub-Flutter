import 'package:clock/clock.dart';
import 'package:connect_hub/core/database/app_database.dart';
import 'package:connect_hub/core/network/api/fake_api_client.dart';
import 'package:connect_hub/core/network/api/fake_comment_api_service.dart';
import 'package:connect_hub/core/network/api/fake_feed_api_service.dart';
import 'package:connect_hub/core/network/fake_server/fake_server.dart';
import 'package:connect_hub/core/network/fake_server/network_simulator.dart';
import 'package:connect_hub/core/storage/session_storage.dart';
import 'package:connect_hub/data/repository/api_guard.dart';
import 'package:connect_hub/data/repository/comment_repository_impl.dart';
import 'package:connect_hub/data/repository/feed_repository_impl.dart';
import 'package:connect_hub/data/repository/post_repository_impl.dart';
import 'package:connect_hub/domain/model/session_state.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'backend.dart';
import 'fakes/fake_session_repository.dart';
import 'fakes/gated_comment_api.dart';
import 'fakes/gated_feed_api.dart';
import 'fixtures.dart';
import 'test_dependencies.dart';

/// The app's real data stack for repository tests: the fake server, its API
/// services and an in-memory database, signed in as the demo user. Only the
/// network latency (zero) and the session repository (a fake) are swapped,
/// and the API services are wrapped so requests can be held in flight.
///
/// Call [dispose] in `tearDown`.
class DataStack {
  DataStack({Clock? clientClock}) {
    FlutterSecureStorage.setMockInitialValues(storedDemoSession());
    final client = FakeApiClient(
      const SessionStorage(FlutterSecureStorage()),
      network,
      server,
    );
    api = GatedFeedApi(FakeFeedApiService(client, server));
    commentApi = GatedCommentApi(FakeCommentApiService(client, server));
    guard = ApiGuard(sessions);
    feed = FeedRepositoryImpl(api, database.feedDao, guard);
    posts = PostRepositoryImpl(
      api,
      database.postsDao,
      database.feedDao,
      guard,
      clientClock ?? Clock.fixed(testNow),
    );
    comments = CommentRepositoryImpl(
      commentApi,
      database.commentsDao,
      database.postsDao,
      posts,
      sessions,
      guard,
    );
  }

  final FakeServer server = newFakeServer();
  final NetworkSimulator network = NetworkSimulator(latencyFactor: 0);
  final AppDatabase database = newTestDatabase();
  final FakeSessionRepository sessions = FakeSessionRepository(
    initial: const SessionState.signedIn(demoSession),
  );
  late final GatedFeedApi api;
  late final GatedCommentApi commentApi;
  late final ApiGuard guard;
  late final FeedRepositoryImpl feed;
  late final PostRepositoryImpl posts;
  late final CommentRepositoryImpl comments;

  /// The ids in the cached feed window, in order.
  Future<List<String>> feedIds() async => [
    for (final post in await feed.watchFeed().first) post.id,
  ];

  Future<void> dispose() async {
    await sessions.dispose();
    await database.close();
  }
}
