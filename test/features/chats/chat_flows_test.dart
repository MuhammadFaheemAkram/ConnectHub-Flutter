import 'package:connect_hub/core/design_system/design_system.dart';
import 'package:connect_hub/core/network/fake_server/fake_server.dart';
import 'package:connect_hub/di/injection.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../../helpers/app_harness.dart';

// Chats and Chat Detail end to end, on the real stack: the fake server's
// replies run on its real timers, in the test's fake time.
void main() {
  tearDown(getIt.reset);

  final chatsButton = find.byTooltip('Chats');

  Finder chatsBadge(String count) =>
      find.descendant(of: chatsButton, matching: find.text(count));

  testWidgets('a message shows at once; the other person types, then '
      'answers; the chat stays read', (tester) async {
    await pumpConnectHub(tester, signedIn: true);
    await tester.tapAndSettle(chatsButton);
    await tester.tapAndSettle(find.text('Alan Turing'));

    await tester.enterText(find.byType(TextField), 'Hello there');
    await tester.pump();
    await tester.tap(find.byTooltip('Send'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('Hello there'), findsOneWidget);

    // Typing starts 400 ms after the server has the message…
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byType(TypingIndicator), findsOneWidget);

    // …and the reply arrives 1.5 s later.
    await tester.pump(const Duration(milliseconds: 1500));
    await tester.pump();
    expect(find.text(FakeServer.cannedReplies.first), findsOneWidget);
    expect(find.byType(TypingIndicator), findsNothing);

    // Back on Chats, the reply is Alan's last message, and it is read.
    await tester.tapAndSettle(find.byType(BackButton));
    expect(find.text(FakeServer.cannedReplies.first), findsOneWidget);
    expect(find.bySemanticsLabel(RegExp('1 unread')), findsOneWidget);
  });

  testWidgets('the Chats button counts unread messages; reading a chat '
      'lowers it', (tester) async {
    await pumpConnectHub(tester, signedIn: true);
    expect(chatsBadge('3'), findsOneWidget);

    await tester.tapAndSettle(chatsButton);
    await tester.tapAndSettle(find.text('Grace Hopper'));
    await tester.tapAndSettle(find.byType(BackButton));
    await tester.tapAndSettle(find.byType(BackButton));

    expect(chatsBadge('1'), findsOneWidget);
  });

  testWidgets('the search field filters the chats as you type', (tester) async {
    await pumpConnectHub(tester, signedIn: true);
    await tester.tapAndSettle(chatsButton);

    await tester.enterText(find.byType(SearchBar), 'machines');
    await tester.pump();

    expect(find.text('Alan Turing'), findsOneWidget);
    expect(find.text('Grace Hopper'), findsNothing);
  });

  testWidgets("a chat's title opens the other person's profile", (
    tester,
  ) async {
    await pumpConnectHub(tester, signedIn: true, initialLocation: '/chats/c3');

    await tester.tapAndSettle(
      find.descendant(
        of: find.byType(AppBar),
        matching: find.text('Katherine Johnson'),
      ),
    );

    expect(find.widgetWithText(AppBar, 'Profile'), findsOneWidget);
    expect(find.text('Edit profile'), findsNothing);
  });
}
