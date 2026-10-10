import 'package:clock/clock.dart';
import 'package:connect_hub/core/design_system/design_system.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../../../helpers/fixtures.dart';
import '../../../helpers/pump_app.dart';

void main() {
  // `samplePost` is posted at 11:00 UTC; the clock reads noon.
  final noon = Clock.fixed(DateTime.utc(2026, 10, 11, 12));

  group('UserAvatar', () {
    test('initials come from the first two words', () {
      expect(UserAvatar.initialsOf('Ada Lovelace'), 'AL');
      expect(UserAvatar.initialsOf('Linus T.'), 'LT');
      expect(UserAvatar.initialsOf('grace'), 'G');
      expect(UserAvatar.initialsOf('Jean Baptiste Joseph Fourier'), 'JB');
      expect(UserAvatar.initialsOf('  '), '?');
    });

    testWidgets('without a picture it shows the initials, and screen readers '
        'hear the name', (tester) async {
      await tester.pumpThemed(const UserAvatar(name: 'Ada Lovelace'));

      expect(find.text('AL'), findsOneWidget);
      expect(find.bySemanticsLabel('Ada Lovelace'), findsOneWidget);
    });
  });

  group('RelativeTimeText', () {
    testWidgets('shows the short form and reads the long one', (tester) async {
      await withClock(noon, () async {
        await tester.pumpThemed(
          RelativeTimeText(DateTime.utc(2026, 10, 11, 11, 55)),
        );
      });

      expect(find.text('5m'), findsOneWidget);
      expect(find.bySemanticsLabel('5 minutes ago'), findsOneWidget);
    });
  });

  group('PostCard', () {
    Future<void> pumpCard(WidgetTester tester, Widget card) =>
        withClock(noon, () => tester.pumpThemed(card));

    testWidgets('shows the author, the time, the text and the counts', (
      tester,
    ) async {
      await pumpCard(
        tester,
        PostCard(post: samplePost('p1', likeCount: 4820, commentCount: 3)),
      );

      expect(find.text('Ada Lovelace'), findsOneWidget);
      expect(find.text('1h'), findsOneWidget);
      expect(find.text('Post p1'), findsOneWidget);
      expect(find.text('4.8K'), findsOneWidget);
      expect(find.byTooltip('3 comments'), findsOneWidget);
    });

    testWidgets('the like and bookmark buttons follow the post', (
      tester,
    ) async {
      await pumpCard(tester, PostCard(post: samplePost('p1')));
      expect(find.byTooltip('Like'), findsOneWidget);
      expect(find.byTooltip('Bookmark'), findsOneWidget);

      await pumpCard(
        tester,
        PostCard(post: samplePost('p1', isLiked: true, isBookmarked: true)),
      );
      expect(find.byTooltip('Unlike'), findsOneWidget);
      expect(find.byTooltip('Remove bookmark'), findsOneWidget);
    });

    testWidgets('one comment is "1 comment"', (tester) async {
      await pumpCard(tester, PostCard(post: samplePost('p1', commentCount: 1)));

      expect(find.byTooltip('1 comment'), findsOneWidget);
    });

    testWidgets('every tap reaches its callback', (tester) async {
      final taps = <String>[];
      await pumpCard(
        tester,
        PostCard(
          post: samplePost('p1'),
          onTap: () => taps.add('card'),
          onAuthorTap: () => taps.add('author'),
          onLike: () => taps.add('like'),
          onComment: () => taps.add('comment'),
          onBookmark: () => taps.add('bookmark'),
        ),
      );

      await tester.tap(find.text('Post p1'));
      await tester.tap(find.text('Ada Lovelace'));
      await tester.tap(find.byTooltip('Like'));
      await tester.tap(find.byTooltip('0 comments'));
      await tester.tap(find.byTooltip('Bookmark'));

      expect(taps, ['card', 'author', 'like', 'comment', 'bookmark']);
    });

    testWidgets('a screen that doesn\'t support an action leaves it '
        'disabled', (tester) async {
      await pumpCard(tester, PostCard(post: samplePost('p1')));

      final like = tester.widget<TextButton>(
        find.descendant(
          of: find.byTooltip('Like'),
          matching: find.byWidgetPredicate((widget) => widget is TextButton),
        ),
      );
      expect(like.onPressed, isNull);
    });
  });
}
