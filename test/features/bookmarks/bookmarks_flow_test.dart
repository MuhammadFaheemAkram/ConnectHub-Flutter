import 'package:connect_hub/core/network/fake_server/network_simulator.dart';
import 'package:connect_hub/di/injection.dart';
import 'package:connect_hub/features/bookmarks/cubit/bookmarks_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../../helpers/app_harness.dart';

// Bookmarks end to end, on the real stack.
void main() {
  tearDown(getIt.reset);

  Finder destination(String label) => find.descendant(
    of: find.byType(NavigationBar),
    matching: find.text(label),
  );

  // p1, the newest post in the seed.
  final firstPost = find.textContaining('analytical engine scheduler');

  Finder onFirstCard(Finder target) => find.descendant(
    of: find.ancestor(of: firstPost, matching: find.byType(Card)),
    matching: target,
  );

  Future<void> bookmarkFirstPost(WidgetTester tester) async {
    await pumpConnectHub(tester, signedIn: true);
    await tester.tapAndSettle(onFirstCard(find.byTooltip('Bookmark')));
  }

  testWidgets('a post bookmarked on the Feed is in Bookmarks; removing it '
      'offers Undo, which brings it back', (tester) async {
    await bookmarkFirstPost(tester);

    await tester.tapAndSettle(destination('Bookmarks'));
    expect(firstPost, findsOneWidget);

    await tester.tapAndSettle(onFirstCard(find.byTooltip('Remove bookmark')));
    expect(firstPost, findsNothing);
    expect(find.text('No bookmarks yet'), findsOneWidget);
    expect(find.text('Removed from bookmarks'), findsOneWidget);

    await tester.tapAndSettle(find.widgetWithText(SnackBarAction, 'Undo'));
    expect(firstPost, findsOneWidget);
  });

  testWidgets('offline, the saved bookmarks still show, and the failed '
      'refresh says so', (tester) async {
    await bookmarkFirstPost(tester);
    getIt<NetworkSimulator>().failRequests = true;

    await tester.tapAndSettle(destination('Bookmarks'));

    expect(firstPost, findsOneWidget);
    expect(find.text(BookmarksCubit.refreshFailedMessage), findsOneWidget);
  });
}
