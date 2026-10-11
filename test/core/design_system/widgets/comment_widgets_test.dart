import 'package:clock/clock.dart';
import 'package:connect_hub/core/design_system/design_system.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../../../helpers/fixtures.dart';
import '../../../helpers/pump_app.dart';

void main() {
  group('CommentTile', () {
    testWidgets('shows the author, the time and the text', (tester) async {
      await withClock(
        Clock.fixed(DateTime.utc(2026, 10, 11, 12, 5)),
        () => tester.pumpThemed(CommentTile(comment: sampleComment('c1'))),
      );

      expect(find.text('Ada Lovelace'), findsOneWidget);
      expect(find.text('5m'), findsOneWidget);
      expect(find.text('Comment c1'), findsOneWidget);
      expect(find.byTooltip('Comment options'), findsNothing);
    });

    testWidgets('my own comment says "You" and offers Delete', (tester) async {
      var deletes = 0;
      await tester.pumpThemed(
        CommentTile(
          comment: sampleComment('c1', isMine: true),
          onDelete: () => deletes++,
        ),
      );

      expect(find.text('You'), findsOneWidget);
      await tester.tap(find.byTooltip('Comment options'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      expect(deletes, 1);
    });
  });

  group('CommentComposer', () {
    late TextEditingController controller;

    setUp(() => controller = TextEditingController());
    tearDown(() => controller.dispose());

    IconButton send(WidgetTester tester) => tester.widget<IconButton>(
      find.ancestor(
        of: find.byTooltip('Send'),
        matching: find.byType(IconButton),
      ),
    );

    testWidgets('Send waits for non-blank text, then sends it', (tester) async {
      final sent = <String>[];
      await tester.pumpThemed(
        CommentComposer(
          controller: controller,
          isSending: false,
          onSend: sent.add,
        ),
      );
      expect(send(tester).onPressed, isNull);

      await tester.enterText(find.byType(TextField), '  ');
      await tester.pump();
      expect(send(tester).onPressed, isNull);

      await tester.enterText(find.byType(TextField), 'Nice!');
      await tester.pump();
      await tester.tap(find.byTooltip('Send'));

      expect(sent, ['Nice!']);
    });

    testWidgets('while sending: progress, and the text can\'t change', (
      tester,
    ) async {
      controller.text = 'Nice!';
      await tester.pumpThemed(
        CommentComposer(
          controller: controller,
          isSending: true,
          onSend: (_) {},
        ),
      );

      expect(find.bySemanticsLabel('Sending'), findsOneWidget);
      expect(send(tester).onPressed, isNull);
      expect(tester.widget<TextField>(find.byType(TextField)).readOnly, isTrue);
    });
  });

  group('CharacterCounter', () {
    Color? colorOf(WidgetTester tester, String text) =>
        tester.widget<Text>(find.text(text)).style?.color;

    testWidgets('turns to the error color once over the limit', (tester) async {
      final scheme = AppTheme.light().colorScheme;

      await tester.pumpThemed(const CharacterCounter(count: 280, max: 280));
      expect(colorOf(tester, '280/280'), scheme.onSurfaceVariant);

      await tester.pumpThemed(const CharacterCounter(count: 281, max: 280));
      expect(colorOf(tester, '281/280'), scheme.error);
      expect(find.bySemanticsLabel('281 of 280 characters'), findsOneWidget);
    });
  });
}
