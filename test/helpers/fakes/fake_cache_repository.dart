import 'dart:async';

import 'package:connect_hub/domain/repository/cache_repository.dart';

/// An in-memory [CacheRepository]: "Clear cache" only counts and signals
/// (synchronously, like the real one).
class FakeCacheRepository implements CacheRepository {
  final _cleared = StreamController<void>.broadcast(sync: true);

  int clearCalls = 0;

  /// Holds [clearCache] in flight until completed.
  Completer<void>? gate;

  @override
  Future<void> clearCache() async {
    clearCalls++;
    await gate?.future;
    _cleared.add(null);
  }

  @override
  Stream<void> watchCleared() => _cleared.stream;

  Future<void> dispose() => _cleared.close();
}
