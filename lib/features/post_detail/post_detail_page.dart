import 'package:connect_hub/core/design_system/design_system.dart';
import 'package:connect_hub/core/navigation/app_routes.dart';
import 'package:connect_hub/core/navigation/back_to_feed_button.dart';
import 'package:material_ui/material_ui.dart';

/// Placeholder for Post Detail (the real screen arrives in Phase 4).
class PostDetailPage extends StatelessWidget {
  const PostDetailPage({super.key, required this.postId});

  final String postId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackToFeedButton(),
        title: const Text('Post'),
      ),
      body: EmptyStateView(
        icon: Icons.article_outlined,
        title: 'Post "$postId"',
        message: 'Post details arrive in Phase 4.',
        action: FilledButton.tonal(
          onPressed: () => CommentsRoute(postId: postId).push<void>(context),
          child: const Text('View comments'),
        ),
      ),
    );
  }
}
