import 'package:connect_hub/di/injection.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../../helpers/app_harness.dart';

// The Activity tab end to end, on the real stack.
void main() {
  tearDown(getIt.reset);

  /// The Activity tab's badge.
  Finder tabBadge(String count) => find.descendant(
    of: find.byType(NavigationBar),
    matching: find.text(count),
  );

  testWidgets('the tab badge counts unread activity; a tapped notification '
      'opens its post and is read', (tester) async {
    await pumpConnectHub(tester, signedIn: true);
    expect(tabBadge('3'), findsOneWidget);

    await tester.tapAndSettle(destination('Activity'));
    await tester.tapAndSettle(
      find.textContaining('liked your post about offline-first'),
    );

    expect(find.widgetWithText(AppBar, 'Post'), findsOneWidget);
    expect(find.textContaining('Offline-first tip'), findsOneWidget);

    await tester.tapAndSettle(find.byType(BackButton));
    expect(tabBadge('2'), findsOneWidget);
  });

  testWidgets("a follow opens the follower's profile", (tester) async {
    await pumpConnectHub(tester, signedIn: true);
    await tester.tapAndSettle(destination('Activity'));

    await tester.tapAndSettle(
      find.text('Katherine Johnson started following you.'),
    );

    expect(find.widgetWithText(AppBar, 'Profile'), findsOneWidget);
    expect(find.text('Katherine Johnson'), findsWidgets);
  });

  testWidgets('a filter narrows the list; Mark all read clears the badge', (
    tester,
  ) async {
    await pumpConnectHub(tester, signedIn: true);
    await tester.tapAndSettle(destination('Activity'));

    // The chips scroll sideways: Follows starts out of view.
    await tester.scrollToAndTap(find.widgetWithText(FilterChip, 'Follows'));
    expect(find.textContaining('started following you'), findsNWidgets(2));
    expect(find.textContaining('liked your post'), findsNothing);

    await tester.tapAndSettle(find.text('Mark all read'));
    expect(tabBadge('3'), findsNothing);
    expect(tabBadge('2'), findsNothing);
  });
}
