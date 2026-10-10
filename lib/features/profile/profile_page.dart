import 'package:connect_hub/core/design_system/design_system.dart';
import 'package:connect_hub/core/navigation/app_routes.dart';
import 'package:connect_hub/core/navigation/back_to_feed_button.dart';
import 'package:connect_hub/features/auth/bloc/auth_bloc.dart';
import 'package:connect_hub/features/auth/bloc/auth_event.dart';
import 'package:connect_hub/features/auth/bloc/auth_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';

/// Placeholder for profiles (the real screen arrives in Phase 5).
///
/// One page serves both cases: `userId == null` is the signed-in user's own
/// profile (the Profile tab), any other id is someone else's (`/users/:id`).
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key, this.userId});

  final String? userId;

  @override
  Widget build(BuildContext context) {
    final userId = this.userId;
    if (userId != null) {
      return Scaffold(
        appBar: AppBar(
          leading: const BackToFeedButton(),
          title: const Text('Profile'),
        ),
        body: EmptyStateView(
          icon: Icons.person_outline,
          title: 'Profile',
          message: 'Profile "$userId" arrives in Phase 5.',
        ),
      );
    }

    final email = context.select(
      (AuthBloc bloc) => switch (bloc.state) {
        AuthAuthenticated(:final session) => session.email,
        _ => null,
      },
    );
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            tooltip: 'Settings',
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => const SettingsRoute().push<void>(context),
          ),
        ],
      ),
      body: EmptyStateView(
        icon: Icons.account_circle_outlined,
        title: 'Your profile',
        message: [
          if (email != null) 'Signed in as $email.',
          'Profiles arrive in Phase 5.',
        ].join('\n'),
        action: Column(
          children: [
            FilledButton.tonal(
              onPressed: () => const EditProfileRoute().push<void>(context),
              child: const Text('Edit profile'),
            ),
            const SizedBox(height: AppSpacing.xSmall),
            TextButton(
              onPressed: () => _confirmLogout(context),
              child: const Text('Log out'),
            ),
          ],
        ),
      ),
    );
  }

  /// Logging out only tells the `AuthBloc`. The router's gate then returns to
  /// Login on its own.
  Future<void> _confirmLogout(BuildContext context) async {
    final confirmed = await showConfirmationDialog(
      context,
      title: 'Log out?',
      message: "You'll need to sign in again to use ConnectHub.",
      confirmLabel: 'Log out',
    );
    if (confirmed && context.mounted) {
      context.read<AuthBloc>().add(const AuthLogoutRequested());
    }
  }
}
