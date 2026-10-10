import 'package:connect_hub/core/design_system/design_system.dart';
import 'package:connect_hub/core/navigation/app_router.dart';
import 'package:connect_hub/core/navigation/placeholder_session.dart';
import 'package:connect_hub/di/injection.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

/// The root widget: themes and the router.
///
/// The [GoRouter] is created once and disposed with this widget. It listens to
/// the session, so the sign-in gate works from the very first frame. In Phase
/// 2 the app-scoped `AuthBloc` is provided here, above `MaterialApp.router`,
/// so both the router and every screen can read it.
class ConnectHubApp extends StatefulWidget {
  const ConnectHubApp({super.key, this.initialLocation});

  /// Lets tests start on a deep link; the app itself starts on the Feed (or
  /// on Login, when the gate redirects).
  final String? initialLocation;

  @override
  State<ConnectHubApp> createState() => _ConnectHubAppState();
}

class _ConnectHubAppState extends State<ConnectHubApp> {
  late final GoRouter _router = createAppRouter(
    session: getIt<PlaceholderSession>(),
    initialLocation: widget.initialLocation,
  );

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'ConnectHub',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      routerConfig: _router,
    );
  }
}
