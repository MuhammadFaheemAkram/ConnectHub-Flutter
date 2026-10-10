import 'package:connect_hub/core/common/app_config.dart';
import 'package:connect_hub/core/common/app_exception.dart';
import 'package:injectable/injectable.dart';

/// Pretends to be the network between the app and the fake server.
///
/// Every fake API call awaits [run] first, which adds latency and can fail on
/// purpose. That keeps the fake server itself free of transport concerns, the
/// same split as a real backend (logic) versus HTTP (latency, failures).
@lazySingleton
class NetworkSimulator {
  NetworkSimulator({
    @ignoreParam this.latencyFactor = 1.0,
    @ignoreParam this.failRequests = AppConfig.simulateNetworkErrors,
  });

  /// Multiplies every latency: 1.0 in the app, 0 in tests for instant replies.
  final double latencyFactor;

  /// While `true`, every request throws [NetworkException], as if offline.
  bool failRequests;

  /// Waits for [latency] (scaled by [latencyFactor]), then fails if
  /// [failRequests] is on.
  Future<void> run(Duration latency) async {
    if (latencyFactor > 0) {
      await Future<void>.delayed(latency * latencyFactor);
    }
    if (failRequests) throw const NetworkException();
  }
}
