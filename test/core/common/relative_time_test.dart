import 'package:connect_hub/core/common/compact_count.dart';
import 'package:connect_hub/core/common/relative_time.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // Mid-day, so a few hours either way stay on the same calendar day in any
  // time zone the tests run in.
  final now = DateTime.utc(2026, 7, 24, 12);

  String short(Duration age) => RelativeTime.short(now.subtract(age), now: now);
  String spoken(Duration age) =>
      RelativeTime.spoken(now.subtract(age), now: now);

  group('RelativeTime.short', () {
    test('under a minute is "now"', () {
      expect(short(Duration.zero), 'now');
      expect(short(const Duration(seconds: 59)), 'now');
    });

    test('minutes, hours, then days', () {
      expect(short(const Duration(minutes: 5)), '5m');
      expect(short(const Duration(minutes: 59)), '59m');
      expect(short(const Duration(hours: 3)), '3h');
      expect(short(const Duration(hours: 23, minutes: 59)), '23h');
      expect(short(const Duration(days: 2)), '2d');
      expect(short(const Duration(days: 6)), '6d');
    });

    test(
      'a week or more shows the date, with the year only when it differs',
      () {
        expect(short(const Duration(days: 7)), 'Jul 17');
        expect(
          RelativeTime.short(DateTime.utc(2025, 7, 24, 12), now: now),
          'Jul 24, 2025',
        );
      },
    );

    test('a time slightly in the future (a clock running ahead) is "now"', () {
      expect(short(const Duration(minutes: -2)), 'now');
    });
  });

  group('RelativeTime.spoken', () {
    test('reads as a phrase, singular or plural', () {
      expect(spoken(Duration.zero), 'just now');
      expect(spoken(const Duration(minutes: 1)), '1 minute ago');
      expect(spoken(const Duration(minutes: 5)), '5 minutes ago');
      expect(spoken(const Duration(hours: 1)), '1 hour ago');
      expect(spoken(const Duration(days: 2)), '2 days ago');
      expect(spoken(const Duration(days: 7)), 'July 17');
    });
  });

  group('compactCount', () {
    test('abbreviates thousands and millions', () {
      expect(compactCount(0), '0');
      expect(compactCount(142), '142');
      expect(compactCount(1290), '1.3K');
      expect(compactCount(4820), '4.8K');
      expect(compactCount(15200), '15.2K');
      expect(compactCount(2500000), '2.5M');
    });
  });
}
