import 'dart:async';

extension FirstValue<T> on Stream<T> {
  /// The stream's first value, like [Stream.first], except that it doesn't
  /// wait for the subscription to finish cancelling.
  ///
  /// The Cubits use it to read what a drift query holds *now*, right after a
  /// write (see `FeedCubit`). `first` works in the app too, but it completes
  /// only once its subscription has been cancelled, and under the fake async
  /// of widget tests a drift stream's cancel never finishes: `first` would
  /// hang there (conventions §11.27).
  Future<T> get firstValue {
    final completer = Completer<T>();
    StreamSubscription<T>? subscription;
    void finish(void Function() complete) {
      if (completer.isCompleted) return;
      complete();
      unawaited(subscription?.cancel());
    }

    subscription = listen(
      (value) => finish(() => completer.complete(value)),
      onError: (Object error, StackTrace stackTrace) =>
          finish(() => completer.completeError(error, stackTrace)),
      onDone: () =>
          finish(() => completer.completeError(StateError('No element'))),
    );
    // A stream that delivers synchronously finished before `listen` returned.
    if (completer.isCompleted) unawaited(subscription.cancel());
    return completer.future;
  }
}
