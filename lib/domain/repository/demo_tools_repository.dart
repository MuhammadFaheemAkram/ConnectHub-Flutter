/// Settings → Developer: switches for trying offline and error states.
abstract interface class DemoToolsRepository {
  /// Whether every request fails, as if offline. Kept in memory: it resets
  /// when the app restarts.
  bool get failsRequests;

  void setFailsRequests({required bool fail});

  /// Makes the current session invalid on the server: the next request
  /// answers 401, and the app returns to Login with the expiry message.
  Future<void> expireSession();
}
