import 'package:connect_hub/core/design_system/design_system.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  group('AppTheme', () {
    test('builds Material 3 light and dark themes from the seed', () {
      final light = AppTheme.light();
      final dark = AppTheme.dark();

      expect(light.useMaterial3, isTrue);
      expect(light.colorScheme.brightness, Brightness.light);
      expect(dark.colorScheme.brightness, Brightness.dark);
    });

    test('registers the matching AppColors extension for each brightness', () {
      expect(AppTheme.light().extension<AppColors>(), same(AppColors.light));
      expect(AppTheme.dark().extension<AppColors>(), same(AppColors.dark));
    });
  });

  group('AppColors', () {
    test('lerp interpolates every token', () {
      final mid = AppColors.light.lerp(AppColors.dark, 0.5);

      expect(
        mid.like,
        Color.lerp(AppColors.light.like, AppColors.dark.like, 0.5),
      );
      expect(
        mid.unread,
        Color.lerp(AppColors.light.unread, AppColors.dark.unread, 0.5),
      );
    });

    test('lerp towards a missing extension keeps the current colors', () {
      expect(AppColors.light.lerp(null, 0.5), same(AppColors.light));
    });

    test('copyWith replaces only the given tokens', () {
      const purple = Color(0xFF7B1FA2);
      final copy = AppColors.light.copyWith(like: purple);

      expect(copy.like, purple);
      expect(copy.unread, AppColors.light.unread);
    });
  });

  // WCAG contrast checks, so a color tweak can't silently make text or icons
  // unreadable (the lesson from MovieExplorer's dark-mode pass).
  group('Contrast in both themes', () {
    double contrast(Color a, Color b) {
      final (hi, lo) = (a.computeLuminance(), b.computeLuminance());
      return hi > lo ? (hi + 0.05) / (lo + 0.05) : (lo + 0.05) / (hi + 0.05);
    }

    for (final theme in [AppTheme.light(), AppTheme.dark()]) {
      final name = theme.colorScheme.brightness.name;
      final colors = theme.extension<AppColors>()!;
      final scheme = theme.colorScheme;

      test('$name: text on an unread row meets AA (4.5:1)', () {
        final row = Color.alphaBlend(colors.unread, scheme.surface);
        expect(contrast(scheme.onSurface, row), greaterThanOrEqualTo(4.5));
      });

      test('$name: the like heart stands out from the surface (3:1)', () {
        expect(contrast(colors.like, scheme.surface), greaterThanOrEqualTo(3));
      });
    }
  });
}
