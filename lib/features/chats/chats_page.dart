import 'package:connect_hub/core/design_system/design_system.dart';
import 'package:connect_hub/core/navigation/app_routes.dart';
import 'package:material_ui/material_ui.dart';

/// Placeholder for the conversation list (the real screen arrives in Phase 6).
class ChatsPage extends StatelessWidget {
  const ChatsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chats')),
      body: EmptyStateView(
        icon: Icons.forum_outlined,
        title: 'Chats',
        message: 'Conversations arrive in Phase 6.',
        // TEMPORARY (Phase 1): replaced by the conversation list in Phase 6.
        action: FilledButton.tonal(
          onPressed: () =>
              const ChatRoute(conversationId: 'c1').push<void>(context),
          child: const Text('Open a sample chat'),
        ),
      ),
    );
  }
}
