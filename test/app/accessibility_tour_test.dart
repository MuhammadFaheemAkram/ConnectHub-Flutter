import 'package:connect_hub/core/design_system/design_system.dart';
import 'package:connect_hub/core/network/fake_server/network_simulator.dart';
import 'package:connect_hub/di/injection.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../helpers/app_harness.dart';

// Every screen, in light and dark, with text at 200%: no layout overflows
// (an overflow fails the test), tap targets of at least 48 × 48, and a label
// on everything tappable.
void main() {
  tearDown(getIt.reset);

  for (final brightness in Brightness.values) {
    group('${brightness.name} theme, text at 200%', () {
      Future<void> open(
        WidgetTester tester, {
        String? at,
        bool signedIn = true,
      }) async {
        tester.platformDispatcher
          ..textScaleFactorTestValue = 2
          ..platformBrightnessTestValue = brightness;
        addTearDown(tester.platformDispatcher.clearAllTestValues);
        await pumpConnectHub(tester, signedIn: signedIn, initialLocation: at);
        // Phone width, but tall enough to lay out every item of a long list:
        // the checks below see only what is built.
        tester.view.physicalSize = const Size(390 * 3, 6000 * 3);
        await tester.pumpAndSettle();
        final context = tester.element(find.byType(Scaffold).first);
        expect(MediaQuery.textScalerOf(context).scale(10), 20);
        expect(Theme.of(context).brightness, brightness);
      }

      Future<void> expectAccessible(WidgetTester tester) async {
        final handle = tester.ensureSemantics();
        await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
        await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
        await expectLater(tester, meetsGuideline(textContrastGuideline));
        handle.dispose();
      }

      for (final (name, location) in [
        ('Feed', '/feed'),
        ('Post Detail', '/posts/p1'),
        ('Comments', '/posts/p1/comments'),
        ('Create Post', '/compose'),
        ('Search', '/search'),
        ('Bookmarks', '/bookmarks'),
        ('Activity', '/activity'),
        ('Profile', '/profile'),
        ("Someone else's profile", '/users/u_ada'),
        ('Edit Profile', '/edit-profile'),
        ('Settings', '/settings'),
        ('Chats', '/chats'),
        ('Chat', '/chats/c1'),
      ]) {
        testWidgets(name, (tester) async {
          await open(tester, at: location);
          await expectAccessible(tester);
        });
      }

      testWidgets('Search results', (tester) async {
        await open(tester, at: '/search');
        await tester.enterText(find.byType(AppSearchField), 'a');
        // The 300 ms debounce, then the request.
        await tester.pump(const Duration(milliseconds: 400));
        await tester.pumpAndSettle();

        expect(find.byType(PostCard), findsWidgets);
        await expectAccessible(tester);
      });

      testWidgets('Chat, with a message that failed', (tester) async {
        await open(tester, at: '/chats/c1');
        getIt<NetworkSimulator>().failRequests = true;
        await tester.enterText(find.byType(TextField), 'Hello there');
        await tester.pump();
        await tester.tap(find.byTooltip('Send'));
        await tester.pumpAndSettle();

        expect(find.text(MessageBubble.failedLabel), findsOneWidget);
        await expectAccessible(tester);
      });

      testWidgets('Chat, while the other person types', (tester) async {
        await open(tester, at: '/chats/c1');
        await tester.enterText(find.byType(TextField), 'Hello there');
        await tester.pump();
        await tester.tap(find.byTooltip('Send'));
        // Sent, then typing starts 400 ms later. (The dots keep animating,
        // so nothing settles until the reply is in.)
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        expect(find.byType(TypingIndicator), findsOneWidget);
        await expectAccessible(tester);
        await tester.pump(const Duration(seconds: 2));
      });

      testWidgets('a confirmation dialog (Clear cache?)', (tester) async {
        await open(tester, at: '/settings');
        await tester.tap(find.text('Clear cache'));
        await tester.pumpAndSettle();

        expect(find.text('Clear cache?'), findsOneWidget);
        await expectAccessible(tester);
      });

      testWidgets('Login', (tester) async {
        await open(tester, signedIn: false);
        await expectAccessible(tester);
      });

      testWidgets('Sign Up', (tester) async {
        await open(tester, signedIn: false, at: '/login/signup');
        await expectAccessible(tester);
      });
    });
  }

  testWidgets('the tab labels keep their size at any text setting (a long '
      'press shows each one); the badges stop growing at 130 %', (
    tester,
  ) async {
    tester.platformDispatcher.textScaleFactorTestValue = 3;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await pumpConnectHub(tester, signedIn: true);

    double scaleOf(Finder text) =>
        MediaQuery.textScalerOf(tester.element(text)).scale(10) / 10;

    expect(scaleOf(destination('Bookmarks')), 1);
    // A long press shows the label above the bar.
    final inBar = destination('Bookmarks').evaluate().single;
    await tester.longPress(destination('Bookmarks'));
    await tester.pumpAndSettle();
    final labels = find.text('Bookmarks').evaluate();
    expect(labels.where((label) => label != inBar), hasLength(1));
    // Let the tooltip go away.
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
    // The Feed's Chats button: 3 unread.
    final chatsBadge = find.descendant(
      of: find.byTooltip('Chats'),
      matching: find.text('3'),
    );
    expect(scaleOf(chatsBadge), closeTo(1.3, 0.001));
  });
}
