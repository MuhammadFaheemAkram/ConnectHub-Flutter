import 'dart:async';

import 'package:connect_hub/core/database/daos/cache_dao.dart';
import 'package:connect_hub/domain/repository/cache_repository.dart';
import 'package:connect_hub/domain/repository/session_repository.dart';
import 'package:injectable/injectable.dart';

/// "Clear cache": the cached copy of the server's data goes (see
/// `CacheDao.clearServerData`), and the screens hear about it.
///
/// The screens observe drift, so without the signal they would show their
/// emptied lists as "nothing here". Instead, the ones showing server data
/// load it again, which is the point of the feature: the server owns the
/// data, so a cache can always be rebuilt.
@LazySingleton(as: CacheRepository)
class CacheRepositoryImpl implements CacheRepository {
  CacheRepositoryImpl(this._cache, this._sessions);

  final CacheDao _cache;
  final SessionRepository _sessions;

  /// Synchronous, so the screens hear about the wipe the moment it commits:
  /// before drift's watchers have re-read the emptied tables (that takes
  /// them at least one more asynchronous step). A screen therefore marks
  /// itself "loading" first, and never shows its emptied list as "nothing
  /// here".
  final _cleared = StreamController<void>.broadcast(sync: true);

  @override
  Future<void> clearCache() async {
    final me = _sessions.currentSession?.userId;
    if (me == null) return;
    await _cache.clearServerData(keepUserId: me);
    _cleared.add(null);
  }

  @override
  Stream<void> watchCleared() => _cleared.stream;

  /// Closes the signal (for tests).
  Future<void> dispose() => _cleared.close();
}
