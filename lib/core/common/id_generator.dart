import 'dart:math';

import 'package:injectable/injectable.dart';

/// Generates random ids and tokens (for the fake server, and later for
/// client-side ids such as chat messages).
///
/// Injected rather than called statically, so tests can pass a seeded
/// [Random] and get repeatable values.
@lazySingleton
class IdGenerator {
  IdGenerator({@ignoreParam Random? random})
    : _random = random ?? Random.secure();

  final Random _random;

  /// An id such as `u_3fa94c1e` for `next('u')`.
  String next(String prefix) => '${prefix}_${hex(8)}';

  /// [length] random hexadecimal characters.
  String hex(int length) => List.generate(
    length,
    (_) => _random.nextInt(16).toRadixString(16),
  ).join();
}
