import 'package:connect_hub/core/design_system/design_system.dart';
import 'package:material_ui/material_ui.dart';

/// Placeholder for the Bookmarks tab.
class BookmarksPage extends StatelessWidget {
  const BookmarksPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bookmarks')),
      body: const EmptyStateView(
        icon: Icons.bookmark_border,
        title: 'Bookmarks',
        message: 'Offline bookmarks arrive in Phase 5.',
      ),
    );
  }
}
