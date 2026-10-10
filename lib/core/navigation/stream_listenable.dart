import 'dart:async';

import 'package:material_ui/material_ui.dart';

/// Adapts a [Stream] into a [Listenable], so `GoRouter.refreshListenable` can
/// follow a Bloc: every new state re-runs the router's redirect.
///
/// go_router only understands `Listenable`s; a Bloc exposes a `Stream`. This
/// is the whole bridge between the two.
class StreamListenable extends ChangeNotifier {
  StreamListenable(Stream<Object?> stream) {
    _subscription = stream.listen((_) => notifyListeners());
  }

  late final StreamSubscription<Object?> _subscription;

  @override
  void dispose() {
    unawaited(_subscription.cancel());
    super.dispose();
  }
}
