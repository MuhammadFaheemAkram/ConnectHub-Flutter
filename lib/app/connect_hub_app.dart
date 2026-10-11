import 'dart:async';

import 'package:connect_hub/app/theme_mode_mapper.dart';
import 'package:connect_hub/core/design_system/design_system.dart';
import 'package:connect_hub/core/navigation/app_router.dart';
import 'package:connect_hub/core/navigation/stream_listenable.dart';
import 'package:connect_hub/di/injection.dart';
import 'package:connect_hub/domain/model/app_settings.dart';
import 'package:connect_hub/domain/model/app_theme_mode.dart';
import 'package:connect_hub/features/auth/bloc/auth_bloc.dart';
import 'package:connect_hub/features/auth/bloc/auth_event.dart';
import 'package:connect_hub/features/settings/cubit/settings_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

/// The root widget: app-scoped state, themes and the router.
///
/// - The [AuthBloc] lives here, for the whole app. It is provided *above*
///   `MaterialApp.router`, so every route can read it, and the router uses
///   the same instance for its sign-in gate.
/// - So is the [SettingsCubit]: `MaterialApp` takes its `themeMode` from it,
///   and the Settings screen changes it. Its first state is read
///   synchronously, so a saved dark theme applies on the very first frame.
/// - This `State` owns the Bloc, the [StreamListenable] that lets the router
///   follow it, and the router itself, and disposes all three. It creates the
///   Bloc itself (instead of `BlocProvider(create:)`) because the router needs
///   the instance before the first build.
class ConnectHubApp extends StatefulWidget {
  const ConnectHubApp({super.key, this.initialLocation});

  /// Lets tests start on a deep link. The app itself starts on the Feed, and
  /// the gate redirects from there.
  final String? initialLocation;

  @override
  State<ConnectHubApp> createState() => _ConnectHubAppState();
}

class _ConnectHubAppState extends State<ConnectHubApp> {
  late final AuthBloc _authBloc = getIt<AuthBloc>()
    ..add(const AuthSubscriptionRequested());
  late final StreamListenable _authChanges = StreamListenable(_authBloc.stream);
  late final GoRouter _router = createAppRouter(
    authBloc: _authBloc,
    refreshListenable: _authChanges,
    initialLocation: widget.initialLocation,
  );

  @override
  void dispose() {
    _router.dispose();
    _authChanges.dispose();
    unawaited(_authBloc.close());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>.value(value: _authBloc),
        BlocProvider(create: (_) => getIt<SettingsCubit>()),
      ],
      // Only a theme change rebuilds the app; the other settings don't.
      child: BlocSelector<SettingsCubit, AppSettings, AppThemeMode>(
        selector: (settings) => settings.themeMode,
        builder: (context, themeMode) => MaterialApp.router(
          title: 'ConnectHub',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          themeMode: themeMode.toThemeMode(),
          routerConfig: _router,
        ),
      ),
    );
  }
}
