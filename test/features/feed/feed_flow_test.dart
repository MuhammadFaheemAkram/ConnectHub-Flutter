import 'package:connect_hub/core/database/app_database.dart';
import 'package:connect_hub/core/network/fake_server/fake_server.dart';
import 'package:connect_hub/core/network/fake_server/network_simulator.dart';
import 'package:connect_hub/di/injection.dart';
import 'package:connect_hub/features/feed/cubit/feed_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../../helpers/app_harness.dart';
import '../../helpers/fixtures.dart';

// The Feed end to end, on the real stack: fake server, API services, drift
// (in memory) and repositories. Only the latency (zero) and the secure store
// (a mock) are swapped.
void main() {
  tearDown(getIt.reset);

  // p1, the newest post in the seed: Ada Lovelace's, with 142 likes.
  final firstPost = find.textContaining('analytical engine scheduler');

  Finder onCard(Finder post, Finder target) => find.descendant(
    of: find.ancestor(of: post, matching: find.byType(Card)),
    matching: target,
  );

  Future<void> pullToRefresh(WidgetTester tester) async {
    await tester.fling(firstPost, const Offset(0, 400), 1000);
    await tester.pumpAndSettle();
  }

  testWidgets('the feed shows the newest posts from the fake server', (
    tester,
  ) async {
    await pumpConnectHub(tester, signedIn: true);

    expect(firstPost, findsOneWidget);
    expect(onCard(firstPost, find.text('Ada Lovelace')), findsOneWidget);
    expect(onCard(firstPost, find.text('142')), findsOneWidget);
  });

  testWidgets('a like shows at once, and the server keeps it', (tester) async {
    await pumpConnectHub(tester, signedIn: true);

    await tester.tapAndSettle(onCard(firstPost, find.byTooltip('Like')));

    expect(onCard(firstPost, find.byTooltip('Unlike')), findsOneWidget);
    expect(onCard(firstPost, find.text('143')), findsOneWidget);
    final serverView = await getIt<FakeServer>().getFeed('u_demo', limit: 1);
    expect(serverView.posts.single.isLiked, isTrue);
  });

  testWidgets('offline, a refresh keeps the saved posts and says so', (
    tester,
  ) async {
    await pumpConnectHub(tester, signedIn: true);
    getIt<NetworkSimulator>().failRequests = true;

    await pullToRefresh(tester);

    expect(find.text(FeedCubit.refreshFailedMessage), findsOneWidget);
    expect(firstPost, findsOneWidget);
  });

  testWidgets('a token the server rejects ends the session: Login explains '
      'why, and the cache is wiped', (tester) async {
    await pumpConnectHub(tester, signedIn: true);
    // What "Expire session" (Settings → Developer, Phase 6) will do.
    getIt<FakeServer>().revoke(demoSession.token);

    await pullToRefresh(tester);

    expect(
      find.text('Your session has expired. Please sign in again.'),
      findsOneWidget,
    );
    final database = getIt<AppDatabase>();
    expect(await database.select(database.posts).get(), isEmpty);
  });

  testWidgets('logging out wipes the cache; signing in again restores the '
      'user\'s data from the server', (tester) async {
    await pumpConnectHub(tester, signedIn: true);
    await tester.tapAndSettle(onCard(firstPost, find.byTooltip('Bookmark')));
    final database = getIt<AppDatabase>();
    expect(await database.select(database.bookmarks).get(), hasLength(1));

    await tester.tapAndSettle(find.text('Profile'));
    await tester.tapAndSettle(find.text('Log out'));
    await tester.tapAndSettle(find.widgetWithText(FilledButton, 'Log out'));
    expect(await database.select(database.posts).get(), isEmpty);
    expect(await database.select(database.bookmarks).get(), isEmpty);

    await tester.tapAndSettle(find.text('Use demo account'));
    await tester.tapAndSettle(find.text('Sign in'));
    expect(
      onCard(firstPost, find.byTooltip('Remove bookmark')),
      findsOneWidget,
    );
  });
}
