import 'package:connect_hub/core/navigation/app_routes.dart';

/// Decides where the router sends the user, before any route is built.
///
/// It is a pure function of the session and the requested location, so every
/// rule is a one-line unit test and the router itself stays declarative:
/// screens never check "am I signed in?", the router guarantees it.
///
/// - Signed out: only the auth routes (`/login…`) are reachable; anything else
///   goes to Login.
/// - Signed in: the splash and auth routes (and `/`) lead to the Feed; any
///   other location is allowed.
///
/// Returns the location to redirect to, or `null` to continue.
///
/// Phase 2 replaces the `bool` with the `AuthBloc` state: an unknown session
/// shows the splash, and Login remembers where the user was going (`from`).
String? authRedirect({required bool isSignedIn, required Uri location}) {
  // Paths come from the typed routes, so renaming a route can't silently
  // break the gate.
  final loginPath = const LoginRoute().location;
  final path = location.path;
  final onAuthRoute = path == loginPath || path.startsWith('$loginPath/');

  if (!isSignedIn) {
    return onAuthRoute ? null : loginPath;
  }
  if (onAuthRoute || path == const SplashRoute().location || path == '/') {
    return const FeedRoute().location;
  }
  return null;
}
