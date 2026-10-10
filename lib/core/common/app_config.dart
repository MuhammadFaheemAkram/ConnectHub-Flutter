/// Switches for the fake backend.
abstract final class AppConfig {
  /// The starting value of `NetworkSimulator.failRequests`. Flip to `true`
  /// to make every fake API call fail, and walk through each screen's error
  /// state end to end. (From Phase 6, Settings → Developer flips it at
  /// runtime.)
  static const bool simulateNetworkErrors = false;
}
