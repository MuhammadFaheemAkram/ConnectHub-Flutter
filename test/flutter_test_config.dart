import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

/// `flutter_test` runs this before every test file under `test/`.
///
/// Tests have no network, and the default image cache asks `path_provider`
/// for a temporary directory the moment it is created. That lookup fails
/// here, and if nothing is waiting for it yet, the failure is an unhandled
/// error that fails whichever test happens to be running. Images load
/// through an offline cache instead, so every image shows its fallback
/// (initials, a plain box), as it would offline.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  CachedNetworkImageProvider.defaultCacheManager = _OfflineCacheManager();
  await testMain();
}

/// A cache that can't download anything. The image widgets ask it for one
/// method only; anything else would be a test bug, and throws.
class _OfflineCacheManager implements BaseCacheManager {
  @override
  Stream<FileResponse> getFileStream(
    String url, {
    String? key,
    Map<String, String>? headers,
    bool withProgress = false,
  }) => Stream.error(Exception('Tests are offline: $url'));

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
