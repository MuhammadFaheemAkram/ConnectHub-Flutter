import 'package:intl/intl.dart';

/// Formats a timestamp relative to "now": "now", "5m", "3h", "2d", then
/// "Jul 24", or "Jul 24, 2025" in another year.
///
/// Pure functions of `(time, now)`, so every rule is a one-line test. The
/// caller passes the current time from a `Clock` (an injected one in services,
/// the zone-scoped `clock` in widgets), never from `DateTime.now()`.
abstract final class RelativeTime {
  /// The short label shown in the UI, e.g. "5m".
  static String short(DateTime time, {required DateTime now}) {
    final age = _age(time, now);
    if (age.inMinutes < 1) return 'now';
    if (age.inMinutes < 60) return '${age.inMinutes}m';
    if (age.inHours < 24) return '${age.inHours}h';
    if (age.inDays < 7) return '${age.inDays}d';
    return _date(time, now, DateFormat.MMMd(), DateFormat.yMMMd());
  }

  /// What a screen reader says for the same time, e.g. "5 minutes ago".
  static String spoken(DateTime time, {required DateTime now}) {
    final age = _age(time, now);
    if (age.inMinutes < 1) return 'just now';
    if (age.inMinutes < 60) return _ago(age.inMinutes, 'minute');
    if (age.inHours < 24) return _ago(age.inHours, 'hour');
    if (age.inDays < 7) return _ago(age.inDays, 'day');
    return _date(time, now, DateFormat.MMMMd(), DateFormat.yMMMMd());
  }

  /// A time slightly in the future (another device's clock running ahead)
  /// counts as "now" rather than as a negative age.
  static Duration _age(DateTime time, DateTime now) {
    final age = now.difference(time);
    return age.isNegative ? Duration.zero : age;
  }

  /// Calendar dates are shown in the device's time zone.
  static String _date(
    DateTime time,
    DateTime now,
    DateFormat sameYear,
    DateFormat otherYear,
  ) {
    final local = time.toLocal();
    final format = local.year == now.toLocal().year ? sameYear : otherYear;
    return format.format(local);
  }

  static String _ago(int count, String unit) =>
      '$count $unit${count == 1 ? '' : 's'} ago';
}
