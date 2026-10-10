import 'package:connect_hub/core/design_system/design_system.dart';
import 'package:connect_hub/core/navigation/back_to_feed_button.dart';
import 'package:material_ui/material_ui.dart';

/// Placeholder for Settings (the real screen arrives in Phase 6).
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackToFeedButton(),
        title: const Text('Settings'),
      ),
      body: const EmptyStateView(
        icon: Icons.settings_outlined,
        title: 'Settings',
        message: 'Appearance, badges, language and more arrive in Phase 6.',
      ),
    );
  }
}
