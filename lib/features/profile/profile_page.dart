import 'package:connect_hub/core/design_system/design_system.dart';
import 'package:connect_hub/core/navigation/app_routes.dart';
import 'package:connect_hub/core/navigation/placeholder_session.dart';
import 'package:connect_hub/di/injection.dart';
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
        appBar: AppBar(title: const Text('Profile')),
        body: EmptyStateView(
          icon: Icons.person_outline,
          title: 'Profile',
          message: 'Profile "$userId" arrives in Phase 5.',
        ),
      );
    }
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
        message: 'Profiles arrive in Phase 5.',
        action: Column(
          children: [
            FilledButton.tonal(
              onPressed: () => const EditProfileRoute().push<void>(context),
              child: const Text('Edit profile'),
            ),
            const SizedBox(height: AppSpacing.xSmall),
            // TEMPORARY (Phase 1): signs out of the placeholder session. The
            // router's gate then returns to Login on its own.
            TextButton(
              onPressed: getIt<PlaceholderSession>().signOut,
              child: const Text('Log out'),
            ),
          ],
        ),
      ),
    );
  }
}
