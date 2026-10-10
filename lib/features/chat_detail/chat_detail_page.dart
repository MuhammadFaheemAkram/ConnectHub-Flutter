import 'package:connect_hub/core/design_system/design_system.dart';
import 'package:material_ui/material_ui.dart';

/// Placeholder for a chat (the real screen arrives in Phase 6).
class ChatDetailPage extends StatelessWidget {
  const ChatDetailPage({super.key, required this.conversationId});

  final String conversationId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chat')),
      body: EmptyStateView(
        icon: Icons.chat_outlined,
        title: 'Chat',
        message: 'Messages in "$conversationId" arrive in Phase 6.',
      ),
    );
  }
}
