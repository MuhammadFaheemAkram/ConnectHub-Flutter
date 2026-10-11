/// The cache as a whole: "Clear cache" in Settings.
abstract interface class CacheRepository {
  /// Deletes the cached copy of the server's data. It keeps what can't be
  /// fetched again or belongs to the device: bookmarked posts (and their
  /// authors), the signed-in user, unsent messages, recent searches. Nothing
  /// else is lost: the server still has it.
  Future<void> clearCache();

  /// Emits after every [clearCache]. Screens that show the server's data load
  /// it again, instead of showing their emptied cache as "nothing here".
  Stream<void> watchCleared();
}
