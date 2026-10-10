import 'package:connect_hub/core/design_system/design_system.dart';
import 'package:material_ui/material_ui.dart';

/// Placeholder for Create Post (the real composer arrives in Phase 4).
///
/// It is shown as a full-screen dialog (see `CreatePostRoute`), so the app bar
/// shows a close button instead of Back.
class CreatePostPage extends StatelessWidget {
  const CreatePostPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New post')),
      body: const EmptyStateView(
        icon: Icons.edit_note,
        title: 'New post',
        message: 'The composer arrives in Phase 4.',
      ),
    );
  }
}
