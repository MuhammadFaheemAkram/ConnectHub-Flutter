import 'package:connect_hub/core/design_system/design_system.dart';
import 'package:connect_hub/domain/model/message.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../../../helpers/fixtures.dart';
import '../../../helpers/pump_app.dart';

void main() {
  group('MessageBubble', () {
    Future<void> pumpBubble(
      WidgetTester tester,
      Message message, {
      VoidCallback? onRetry,
    }) async {
      tester.usePhoneSurface();
      await tester.pumpThemed(
        ListView(
          children: [MessageBubble(message: message, onRetry: onRetry)],
        ),
      );
    }

    double centerX(WidgetTester tester, String text) =>
        tester.getCenter(find.text(text)).dx;

    testWidgets('mine sits on the right, theirs on the left, each with its '
        'time', (tester) async {
      await pumpBubble(tester, sampleMessage('m1'));
      expect(centerX(tester, 'Message m1'), lessThan(195));
      // The local time, e.g. "5:00 PM" (the zone depends on the machine).
      expect(find.textContaining(RegExp(r'^\d{1,2}:\d{2}')), findsOneWidget);

      await pumpBubble(tester, sampleMessage('m2', isMine: true));
      expect(centerX(tester, 'Message m2'), greaterThan(195));
    });

    testWidgets('a message on its way says "Sending…"', (tester) async {
      await pumpBubble(
        tester,
        sampleMessage('m1', isMine: true, status: MessageStatus.sending),
      );

      expect(find.text('Sending…'), findsOneWidget);
    });

    testWidgets('a failed message says so; tapping it retries', (tester) async {
      var retries = 0;
      await pumpBubble(
        tester,
        sampleMessage('m1', isMine: true, status: MessageStatus.failed),
        onRetry: () => retries++,
      );

      expect(find.text(MessageBubble.failedLabel), findsOneWidget);
      await tester.tap(find.text('Message m1'));
      expect(retries, 1);
    });
  });

  group('TypingIndicator', () {
    testWidgets('three dots that keep moving, read as "Typing"', (
      tester,
    ) async {
      await tester.pumpThemed(const TypingIndicator());
      await tester.pump(const Duration(milliseconds: 100));

      expect(tester.hasRunningAnimations, isTrue);
      expect(find.bySemanticsLabel('Typing'), findsOneWidget);
    });

    testWidgets('they stay still when the system asks for no animations', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: MediaQuery(
            data: MediaQueryData(disableAnimations: true),
            child: Scaffold(body: TypingIndicator()),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));

      expect(tester.hasRunningAnimations, isFalse);
    });
  });

  group('ConversationTile', () {
    testWidgets('the person, the last message, and an unread badge read as '
        '"2 unread"; tapping opens it', (tester) async {
      var taps = 0;
      await tester.pumpThemed(
        ConversationTile(
          conversation: sampleConversation(
            'c1',
            lastMessage: 'See you soon',
            unreadCount: 2,
          ),
          onTap: () => taps++,
        ),
      );

      expect(find.text('Grace Hopper'), findsOneWidget);
      expect(find.text('See you soon'), findsOneWidget);
      // A list tile reads as one node: the badge is part of its label.
      expect(find.bySemanticsLabel(RegExp('2 unread')), findsOneWidget);
      await tester.tap(find.text('Grace Hopper'));
      expect(taps, 1);
    });

    testWidgets('nothing unread: no badge', (tester) async {
      await tester.pumpThemed(
        ConversationTile(conversation: sampleConversation('c1'), onTap: () {}),
      );

      expect(find.byType(Badge), findsNothing);
    });
  });

  group('NotificationTile', () {
    testWidgets('an unread one is announced as unread, with a dot', (
      tester,
    ) async {
      await tester.pumpThemed(
        NotificationTile(notification: sampleNotification('n1')),
      );

      expect(
        find.bySemanticsLabel(RegExp(r'^Unread\. Like\.')),
        findsOneWidget,
      );
      expect(find.text('Notification n1'), findsOneWidget);
    });

    testWidgets('a read one is not; tapping it calls back', (tester) async {
      var taps = 0;
      await tester.pumpThemed(
        NotificationTile(
          notification: sampleNotification('n1', isRead: true),
          onTap: () => taps++,
        ),
      );

      expect(find.bySemanticsLabel(RegExp('Unread')), findsNothing);
      await tester.tap(find.text('Notification n1'));
      expect(taps, 1);
    });
  });

  group('UnreadBadge', () {
    testWidgets('shows the count, read as "3 unread"; hidden at zero', (
      tester,
    ) async {
      await tester.pumpThemed(
        const Row(
          children: [
            UnreadBadge(count: 3, child: Icon(Icons.chat)),
            UnreadBadge(count: 0, child: Icon(Icons.home)),
          ],
        ),
      );

      expect(find.text('3'), findsOneWidget);
      expect(find.text('0'), findsNothing);
      final handle = tester.ensureSemantics();
      expect(
        tester.getSemantics(find.byType(UnreadBadge).first),
        matchesSemantics(value: '3 unread'),
      );
      handle.dispose();
    });
  });
}
