import 'package:connect_hub/domain/repository/cache_repository.dart';
import 'package:injectable/injectable.dart';

/// Clears the cached server data (Settings → Storage).
@injectable
class ClearCacheUseCase {
  const ClearCacheUseCase(this._cache);

  final CacheRepository _cache;

  Future<void> call() => _cache.clearCache();
}
