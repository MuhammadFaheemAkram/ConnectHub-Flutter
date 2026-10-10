import 'package:connect_hub/core/design_system/design_system.dart';
import 'package:connect_hub/core/navigation/app_routes.dart';
import 'package:connect_hub/core/navigation/auth_redirect.dart';
import 'package:connect_hub/features/auth/bloc/auth_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

/// Creates the app's [GoRouter], gated by the session.
///
/// - [refreshListenable] notifies on every [AuthBloc] state, so the router
///   re-runs [authRedirect] whenever the session changes. Signing in or out
///   needs no navigation code: the gate moves the user to the right place.
/// - This is a factory rather than a global: the app widget owns one router
///   for its lifetime, and every widget test starts from a fresh one.
GoRouter createAppRouter({
  required AuthBloc authBloc,
  required Listenable refreshListenable,
  String? initialLocation,
}) {
  // `late`: the redirect needs the router it belongs to. It only runs after
  // the router exists (routing starts once `MaterialApp.router` mounts).
  late final GoRouter router;
  router = GoRouter(
    initialLocation: initialLocation ?? const FeedRoute().location,
    routes: $appRoutes,
    refreshListenable: refreshListenable,
    redirect: (context, state) =>
        authRedirect(authBloc.state, _visibleLocation(router, state)),
    errorBuilder: (context, state) =>
        _NotFoundPage(location: state.uri.toString()),
  );
  return router;
}

/// The location the sign-in gate should reason about.
///
/// When `refreshListenable` fires, go_router re-runs the redirect on the
/// *base* location. With a screen pushed on top (e.g. `/posts/p1` over
/// `/feed`), `state.uri` is still `/feed`, so an expired session would
/// forget the post the user was reading. When the redirect is re-checking
/// the current location (rather than a new navigation), use what is actually
/// on screen instead.
Uri _visibleLocation(GoRouter router, GoRouterState state) {
  final current = router.routerDelegate.currentConfiguration;
  if (current.isEmpty || state.uri != current.uri) return state.uri;
  return router.state.uri;
}

/// Shown when a location matches no route, e.g. a mistyped deep link.
class _NotFoundPage extends StatelessWidget {
  const _NotFoundPage({required this.location});

  final String location;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Not found')),
      body: EmptyStateView(
        icon: Icons.explore_off_outlined,
        title: 'Page not found',
        message: 'Nothing lives at "$location".',
        action: FilledButton.tonal(
          onPressed: () => const FeedRoute().go(context),
          child: const Text('Go to the feed'),
        ),
      ),
    );
  }
}
