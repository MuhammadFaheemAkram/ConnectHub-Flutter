import 'package:async/async.dart' show StreamQueue;

/// Waits for the next stream event, failing fast instead of hanging the suite
/// (every wait in a test must be bounded, conventions §11.6).
Future<T> nextEvent<T>(StreamQueue<T> queue) =>
    queue.next.timeout(const Duration(seconds: 2));
