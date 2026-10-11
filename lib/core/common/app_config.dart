/// Switches for the fake backend.
abstract final class AppConfig {
  /// The starting value of `NetworkSimulator.failRequests`. Flip to `true`
  /// to make every fake API call fail, and walk through each screen's error
  /// state end to end. Settings → Developer → "Simulate network failure"
  /// flips it at runtime.
  static const bool simulateNetworkErrors = false;
}
