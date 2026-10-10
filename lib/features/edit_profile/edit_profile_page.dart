import 'package:connect_hub/core/design_system/design_system.dart';
import 'package:connect_hub/core/navigation/back_to_feed_button.dart';
import 'package:material_ui/material_ui.dart';

/// Placeholder for Edit Profile (the real form arrives in Phase 5), shown as a
/// full-screen dialog.
class EditProfilePage extends StatelessWidget {
  const EditProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackToFeedButton.close(),
        title: const Text('Edit profile'),
      ),
      body: const EmptyStateView(
        icon: Icons.manage_accounts_outlined,
        title: 'Edit profile',
        message: 'Profile editing arrives in Phase 5.',
      ),
    );
  }
}
