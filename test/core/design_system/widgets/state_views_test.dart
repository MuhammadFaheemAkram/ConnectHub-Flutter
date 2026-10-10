import 'package:connect_hub/core/design_system/design_system.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../../../helpers/pump_app.dart';

void main() {
  group('LoadingView', () {
    testWidgets('shows a spinner and its message', (tester) async {
      await tester.pumpThemed(const LoadingView(message: 'Loading your feed…'));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Loading your feed…'), findsOneWidget);
    });
  });

  group('ErrorView', () {
    testWidgets('shows the message without a retry button by default', (
      tester,
    ) async {
      await tester.pumpThemed(const ErrorView(message: 'Network down.'));

      expect(find.text('Something went wrong'), findsOneWidget);
      expect(find.text('Network down.'), findsOneWidget);
      expect(find.text('Try again'), findsNothing);
    });

    testWidgets('calls onRetry when "Try again" is tapped', (tester) async {
      var retries = 0;
      await tester.pumpThemed(
        ErrorView(message: 'Network down.', onRetry: () => retries++),
      );

      await tester.tap(find.text('Try again'));

      expect(retries, 1);
    });
  });

  group('EmptyStateView', () {
    testWidgets('renders its icon, title, message and action', (tester) async {
      var taps = 0;
      await tester.pumpThemed(
        EmptyStateView(
          icon: Icons.bookmark_border,
          title: 'No bookmarks yet',
          message: 'Tap the bookmark icon on a post to save it here.',
          action: TextButton(
            onPressed: () => taps++,
            child: const Text('Browse the feed'),
          ),
        ),
      );

      expect(find.byIcon(Icons.bookmark_border), findsOneWidget);
      expect(find.text('No bookmarks yet'), findsOneWidget);
      expect(
        find.text('Tap the bookmark icon on a post to save it here.'),
        findsOneWidget,
      );
      await tester.tap(find.text('Browse the feed'));
      expect(taps, 1);
    });

    testWidgets('omits the message and action when not provided', (
      tester,
    ) async {
      await tester.pumpThemed(
        const EmptyStateView(icon: Icons.search, title: 'Search ConnectHub'),
      );

      expect(find.text('Search ConnectHub'), findsOneWidget);
      expect(find.byType(TextButton), findsNothing);
    });
  });
}
