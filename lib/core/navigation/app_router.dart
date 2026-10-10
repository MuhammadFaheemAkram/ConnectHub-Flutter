import 'package:connect_hub/core/design_system/design_system.dart';
import 'package:connect_hub/core/navigation/app_routes.dart';
import 'package:connect_hub/core/navigation/auth_redirect.dart';
import 'package:connect_hub/core/navigation/placeholder_session.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

/// Creates the app's [GoRouter], gated by the session.
///
/// - `refreshListenable`: whenever the session changes, the router re-runs
///   [authRedirect]. Signing in or out therefore needs no navigation code at
///   all: the gate moves the user to the right place.
/// - This is a factory rather than a global: the app widget owns one router
///   for its lifetime, and every widget test starts from a fresh one.
GoRouter createAppRouter({
  required PlaceholderSession session,
  String? initialLocation,
}) {
  return GoRouter(
    initialLocation: initialLocation ?? const FeedRoute().location,
    routes: $appRoutes,
    refreshListenable: session,
    redirect: (context, state) =>
        authRedirect(isSignedIn: session.isSignedIn, location: state.uri),
    errorBuilder: (context, state) =>
        _NotFoundPage(location: state.uri.toString()),
  );
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
