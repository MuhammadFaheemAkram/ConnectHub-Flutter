import 'package:intl/intl.dart';

/// At most one decimal, as social apps show counts. `NumberFormat.compact()`
/// on its own keeps three significant digits ("1.29K").
final _compact = NumberFormat.compact()..maximumFractionDigits = 1;

/// A count as people read it on a social app: 142, 1.3K, 15.2K, 2.5M.
String compactCount(int count) => _compact.format(count);
