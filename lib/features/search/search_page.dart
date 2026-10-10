import 'package:connect_hub/core/design_system/design_system.dart';
import 'package:material_ui/material_ui.dart';

/// Placeholder for the Search tab.
class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Search')),
      body: const EmptyStateView(
        icon: Icons.search,
        title: 'Search people and posts',
        message: 'Search arrives in Phase 5.',
      ),
    );
  }
}
