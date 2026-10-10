import 'package:connect_hub/core/design_system/design_system.dart';
import 'package:connect_hub/core/navigation/app_routes.dart';
import 'package:connect_hub/core/navigation/placeholder_session.dart';
import 'package:connect_hub/di/injection.dart';
import 'package:material_ui/material_ui.dart';

/// Placeholder for the Login screen (the real form arrives in Phase 2).
///
/// "Continue" flips the temporary [PlaceholderSession]. The page itself never
/// navigates to the Feed: the router's sign-in gate does that as soon as the
/// session changes.
class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign in')),
      body: EmptyStateView(
        icon: Icons.lock_outline,
        title: 'Welcome to ConnectHub',
        message: 'The sign-in form arrives in Phase 2.',
        action: Column(
          children: [
            FilledButton(
              onPressed: getIt<PlaceholderSession>().signIn,
              child: const Text('Continue'),
            ),
            const SizedBox(height: AppSpacing.xSmall),
            TextButton(
              onPressed: () => const SignUpRoute().push<void>(context),
              child: const Text('Create an account'),
            ),
          ],
        ),
      ),
    );
  }
}
