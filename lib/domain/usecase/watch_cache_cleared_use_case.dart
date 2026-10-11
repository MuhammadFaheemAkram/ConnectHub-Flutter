import 'package:connect_hub/domain/repository/cache_repository.dart';
import 'package:injectable/injectable.dart';

/// Emits after every "Clear cache", so a screen can load its data again.
@injectable
class WatchCacheClearedUseCase {
  const WatchCacheClearedUseCase(this._cache);

  final CacheRepository _cache;

  Stream<void> call() => _cache.watchCleared();
}
