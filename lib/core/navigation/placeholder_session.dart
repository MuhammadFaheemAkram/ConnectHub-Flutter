import 'package:injectable/injectable.dart';
import 'package:material_ui/material_ui.dart';

/// TEMPORARY (Phase 1): an in-memory stand-in for the real session.
///
/// It lets the router's sign-in gate be built and tested before any auth code
/// exists. Being a [ValueNotifier], it is a `Listenable`, which is exactly what
/// `GoRouter.refreshListenable` needs to re-run the redirect when it changes.
///
/// Phase 2 replaces it with `AuthBloc`, whose state stream drives the same
/// redirect through a small `Stream` → `Listenable` adapter.
@lazySingleton
class PlaceholderSession extends ValueNotifier<bool> {
  // `@ignoreParam`: without it, injectable would try to inject a `bool`
  // dependency. The app starts signed out; tests can start signed in.
  PlaceholderSession({@ignoreParam bool signedIn = false}) : super(signedIn);

  bool get isSignedIn => value;

  void signIn() => value = true;

  void signOut() => value = false;
}
