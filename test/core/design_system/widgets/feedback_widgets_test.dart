import 'package:connect_hub/core/design_system/design_system.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../../../helpers/pump_app.dart';

void main() {
  group('NoticeBanner', () {
    testWidgets('shows its icon and message', (tester) async {
      await tester.pumpThemed(
        const NoticeBanner(
          icon: Icons.lock_clock_outlined,
          message: 'Your session has expired.',
        ),
      );

      expect(find.byIcon(Icons.lock_clock_outlined), findsOneWidget);
      expect(find.text('Your session has expired.'), findsOneWidget);
    });
  });

  group('ButtonProgress', () {
    testWidgets('is a small spinner with a screen-reader label', (
      tester,
    ) async {
      await tester.pumpThemed(const ButtonProgress(semanticsLabel: 'Saving'));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.bySemanticsLabel('Saving'), findsOneWidget);
    });
  });

  group('showConfirmationDialog', () {
    Future<Future<bool>> open(WidgetTester tester) async {
      late Future<bool> answer;
      await tester.pumpThemed(
        Builder(
          builder: (context) => TextButton(
            onPressed: () => answer = showConfirmationDialog(
              context,
              title: 'Log out?',
              message: "You'll need to sign in again.",
              confirmLabel: 'Log out',
            ),
            child: const Text('Open'),
          ),
        ),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      return answer;
    }

    testWidgets('confirming answers true', (tester) async {
      final answer = await open(tester);
      expect(find.text('Log out?'), findsOneWidget);

      await tester.tap(find.widgetWithText(FilledButton, 'Log out'));
      await tester.pumpAndSettle();

      expect(await answer, isTrue);
    });

    testWidgets('cancelling answers false', (tester) async {
      final answer = await open(tester);

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(await answer, isFalse);
    });
  });
}
