import 'package:connect_hub/di/injection.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../../helpers/app_harness.dart';

// Post Detail, Comments and Create Post end to end, on the real stack: fake
// server, API services, drift (in memory) and repositories.
void main() {
  tearDown(getIt.reset);

  // p1, the newest post in the seed: Ada Lovelace's, with 3 comments.
  final firstPost = find.textContaining('analytical engine scheduler');
  final commentField = find.widgetWithText(TextField, 'Add a comment…');

  Finder onFirstCard(Finder target) => find.descendant(
    of: find.ancestor(of: firstPost, matching: find.byType(Card)),
    matching: target,
  );

  Future<void> send(WidgetTester tester, String text) async {
    await tester.enterText(commentField, text);
    await tester.pump();
    await tester.tapAndSettle(find.byTooltip('Send'));
  }

  testWidgets('a post opens with its latest comments, and "View all" lists '
      'every one', (tester) async {
    await pumpConnectHub(tester, signedIn: true);

    await tester.tapAndSettle(firstPost);
    expect(appBarTitled('Post'), findsOneWidget);
    expect(firstPost, findsOneWidget);
    expect(find.textContaining('second-hardest problem'), findsOneWidget);

    await tester.scrollToAndTap(find.text('View all 3 comments'));
    expect(appBarTitled('Comments'), findsOneWidget);
    expect(find.textContaining('second-hardest problem'), findsOneWidget);
    expect(find.textContaining('loop names'), findsOneWidget);
    expect(find.textContaining('stunning'), findsOneWidget);
  });

  testWidgets('a comment sent on a post shows there as mine, and the count '
      'moves on the Feed too', (tester) async {
    await pumpConnectHub(tester, signedIn: true);
    await tester.tapAndSettle(firstPost);

    await send(tester, 'Great work!');

    expect(find.text('Great work!'), findsOneWidget);
    expect(find.text('You'), findsOneWidget);
    expect(find.text('View all 4 comments'), findsOneWidget);
    await tester.tapAndSettle(find.byType(BackButton));
    expect(onFirstCard(find.byTooltip('4 comments')), findsOneWidget);
  });

  testWidgets('deleting my comment asks first, then removes it', (
    tester,
  ) async {
    await pumpConnectHub(tester, signedIn: true);
    // The comment button on the first card opens its comments.
    await tester.tapAndSettle(onFirstCard(find.byTooltip('3 comments')));
    await send(tester, 'Oops, wrong post');
    expect(find.text('Oops, wrong post'), findsOneWidget);

    await tester.tapAndSettle(find.byTooltip('Comment options'));
    await tester.tapAndSettle(find.text('Delete'));
    expect(find.text('Delete comment?'), findsOneWidget);
    await tester.tapAndSettle(find.widgetWithText(FilledButton, 'Delete'));

    expect(find.text('Oops, wrong post'), findsNothing);
    await tester.tapAndSettle(find.byType(BackButton));
    expect(onFirstCard(find.byTooltip('3 comments')), findsOneWidget);
  });

  testWidgets('a new post appears at the top of the Feed, as mine', (
    tester,
  ) async {
    await pumpConnectHub(tester, signedIn: true);

    await tester.tapAndSettle(find.byTooltip('New post'));
    await tester.enterText(find.byType(TextField).first, 'Hello from Flutter');
    await tester.pump();
    await tester.tapAndSettle(find.text('Post'));

    expect(appBarTitled('ConnectHub'), findsOneWidget);
    final top = find.byType(Card).first;
    expect(
      find.descendant(of: top, matching: find.text('Hello from Flutter')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: top, matching: find.text('Demo User')),
      findsOneWidget,
    );
  });

  testWidgets('leaving a draft asks first: Cancel stays, Discard leaves', (
    tester,
  ) async {
    await pumpConnectHub(tester, signedIn: true);
    await tester.tapAndSettle(find.byTooltip('New post'));
    await tester.enterText(find.byType(TextField).first, 'Half a thought');
    await tester.pump();

    await tester.tapAndSettle(find.byType(CloseButton));
    expect(find.text('Discard post?'), findsOneWidget);
    await tester.tapAndSettle(find.text('Cancel'));
    expect(appBarTitled('New post'), findsOneWidget);

    await tester.tapAndSettle(find.byType(CloseButton));
    await tester.tapAndSettle(find.widgetWithText(FilledButton, 'Discard'));
    expect(appBarTitled('ConnectHub'), findsOneWidget);
    expect(find.text('Half a thought'), findsNothing);
  });

  testWidgets('a post that no longer exists says so', (tester) async {
    await pumpConnectHub(
      tester,
      signedIn: true,
      initialLocation: '/posts/p999',
    );

    expect(find.text('This post is no longer available.'), findsOneWidget);
  });
}
