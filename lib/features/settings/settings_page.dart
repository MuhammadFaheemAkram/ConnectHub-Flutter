import 'package:connect_hub/di/injection.dart';
import 'package:connect_hub/features/auth/bloc/auth_bloc.dart';
import 'package:connect_hub/features/auth/bloc/auth_event.dart';
import 'package:connect_hub/features/settings/cubit/settings_tools_cubit.dart';
import 'package:connect_hub/features/settings/settings_view.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// Settings' entry point.
///
/// The preferences need no Cubit here: the app-scoped `SettingsCubit` above
/// `MaterialApp` is already in the tree. This page provides the screen's
/// own [SettingsToolsCubit], the version from the platform's package info
/// (resolved before `runApp`), and logging out through the [AuthBloc].
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final info = getIt<PackageInfo>();
    return BlocProvider(
      create: (_) => getIt<SettingsToolsCubit>(),
      child: SettingsView(
        appVersion: '${info.version} (${info.buildNumber})',
        onLogout: () =>
            context.read<AuthBloc>().add(const AuthLogoutRequested()),
      ),
    );
  }
}
