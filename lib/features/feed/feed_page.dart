import 'package:connect_hub/core/design_system/design_system.dart';
import 'package:connect_hub/core/navigation/app_routes.dart';
import 'package:material_ui/material_ui.dart';

/// Placeholder for the Feed tab (the real feed arrives in Phase 3).
///
/// The app bar and FAB are already final: Chats lives in the Feed's app bar
/// and New post is the FAB, both pushed above the tab shell.
class FeedPage extends StatelessWidget {
  const FeedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ConnectHub'),
        actions: [
          IconButton(
            tooltip: 'Chats',
            icon: const Icon(Icons.chat_bubble_outline),
            onPressed: () => const ChatsRoute().push<void>(context),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'New post',
        onPressed: () => const CreatePostRoute().push<void>(context),
        child: const Icon(Icons.edit_outlined),
      ),
      body: EmptyStateView(
        icon: Icons.dynamic_feed_outlined,
        title: 'Feed',
        message: 'Posts arrive in Phase 3.',
        // TEMPORARY (Phase 1): sample links to the root-level placeholders.
        // Real post cards replace them in Phase 3.
        action: Column(
          children: [
            FilledButton.tonal(
              onPressed: () =>
                  const PostDetailRoute(postId: 'p1').push<void>(context),
              child: const Text('Open a sample post'),
            ),
            const SizedBox(height: AppSpacing.xSmall),
            TextButton(
              onPressed: () =>
                  const UserProfileRoute(userId: 'u_ada').push<void>(context),
              child: const Text('Open a sample profile'),
            ),
          ],
        ),
      ),
    );
  }
}
