import 'package:connect_hub/core/design_system/design_system.dart';
import 'package:connect_hub/core/navigation/back_to_feed_button.dart';
import 'package:material_ui/material_ui.dart';

/// Placeholder for a post's comments (the real screen arrives in Phase 4).
class CommentsPage extends StatelessWidget {
  const CommentsPage({super.key, required this.postId});

  final String postId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackToFeedButton(),
        title: const Text('Comments'),
      ),
      body: EmptyStateView(
        icon: Icons.mode_comment_outlined,
        title: 'Comments',
        message: 'Comments on "$postId" arrive in Phase 4.',
      ),
    );
  }
}
