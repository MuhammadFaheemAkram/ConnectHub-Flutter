import 'package:connect_hub/core/design_system/design_system.dart';
import 'package:material_ui/material_ui.dart';

/// Placeholder for the Activity tab.
class ActivityPage extends StatelessWidget {
  const ActivityPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Activity')),
      body: const EmptyStateView(
        icon: Icons.notifications_none,
        title: 'Activity',
        message: 'Notifications arrive in Phase 6.',
      ),
    );
  }
}
