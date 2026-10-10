import 'package:connect_hub/core/navigation/app_routes.dart';
import 'package:connect_hub/domain/model/session_state.dart';
import 'package:connect_hub/features/auth/bloc/auth_state.dart';

/// Decides where the router sends the user, before any route is built.
///
/// It is a pure function of the session and the requested location, so every
/// rule is a one-line unit test, and screens never check "am I signed in?":
/// the router guarantees it.
///
/// | Session | Location | Result |
/// |---|---|---|
/// | unknown (restoring) | anything but the splash | the splash |
/// | signed out | an auth route (`/login…`) | stay |
/// | signed out | anything else | Login |
/// | signed in | the splash, an auth route, or `/` | the return address, else the Feed |
/// | signed in | anything else | stay |
///
/// The **return address** (`from`) is where the user was going when the gate
/// stepped in, e.g. a deep link to a post. It travels as a query parameter
/// through the splash, Login and Sign Up, and is used once signed in. It is
/// dropped after a deliberate logout: the next sign-in shouldn't reopen the
/// screen the user just left. It is kept after an *expired* session, which
/// the user didn't choose.
String? authRedirect(AuthState auth, Uri location) {
  final path = location.path;
  final onGate = _isGate(path);

  switch (auth) {
    case AuthUnknown():
      return path == _splash
          ? null
          : SplashRoute(from: _returnAddress(location)).location;
    case AuthUnauthenticated(:final reason):
      if (_isAuthRoute(path)) return null;
      final from = reason == SignOutReason.loggedOut
          ? null
          : _returnAddress(location);
      return LoginRoute(from: from).location;
    case AuthAuthenticated():
      if (onGate || path == '/') {
        return _returnAddress(location) ?? const FeedRoute().location;
      }
      return null;
  }
}

final String _splash = const SplashRoute().location;
final String _login = const LoginRoute().location;
final String _feed = const FeedRoute().location;

bool _isAuthRoute(String path) => path == _login || path.startsWith('$_login/');

/// The splash and the auth routes: screens that only exist to let the user
/// through the gate.
bool _isGate(String path) => path == _splash || _isAuthRoute(path);

/// Where the user was trying to go: on a gate screen that's its `from`
/// parameter; anywhere else it's the location itself. `null` when that's
/// just the default destination, or not a safe in-app path.
String? _returnAddress(Uri location) {
  final candidate = _isGate(location.path)
      ? location.queryParameters['from']
      : location.toString();
  return _safeInAppPath(candidate);
}

/// Only relative, in-app paths are followed. `https://evil.example` or
/// `//evil.example` (which a browser treats as another host) must never be a
/// destination, and neither may a gate screen (that would loop).
String? _safeInAppPath(String? candidate) {
  if (candidate == null) return null;
  final uri = Uri.tryParse(candidate);
  if (uri == null || uri.hasScheme || uri.hasAuthority) return null;
  final path = uri.path;
  if (!path.startsWith('/') || path == '/' || path == _feed || _isGate(path)) {
    return null;
  }
  return uri.toString();
}
