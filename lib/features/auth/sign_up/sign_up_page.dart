import 'package:connect_hub/core/design_system/design_system.dart';
import 'package:material_ui/material_ui.dart';

/// Placeholder for the Sign Up screen (the real form arrives in Phase 2).
class SignUpPage extends StatelessWidget {
  const SignUpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create account')),
      body: const EmptyStateView(
        icon: Icons.person_add_alt_1_outlined,
        title: 'Create account',
        message: 'The sign-up form arrives in Phase 2.',
      ),
    );
  }
}
