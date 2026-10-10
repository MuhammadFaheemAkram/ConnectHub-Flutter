import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

/// Hosts the bottom [NavigationBar] around the active tab.
///
/// [navigationShell] holds the five tab navigators in an IndexedStack; this
/// widget only decides which branch is visible. Each tab screen brings its own
/// `Scaffold`, `AppBar` and actions (the Feed's FAB, for example).
///
/// The shell exists only while signed in, so in Phase 6 it is also where
/// session-scoped state (the unread badges) is provided.
class MainShell extends StatelessWidget {
  const MainShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  /// Order must match the branches declared in `app_routes.dart`.
  static const _destinations = [
    NavigationDestination(
      icon: Icon(Icons.home_outlined),
      selectedIcon: Icon(Icons.home),
      label: 'Feed',
    ),
    NavigationDestination(
      icon: Icon(Icons.search_outlined),
      selectedIcon: Icon(Icons.search),
      label: 'Search',
    ),
    NavigationDestination(
      icon: Icon(Icons.bookmark_border),
      selectedIcon: Icon(Icons.bookmark),
      label: 'Bookmarks',
    ),
    NavigationDestination(
      icon: Icon(Icons.notifications_none),
      selectedIcon: Icon(Icons.notifications),
      label: 'Activity',
    ),
    NavigationDestination(
      icon: Icon(Icons.person_outline),
      selectedIcon: Icon(Icons.person),
      label: 'Profile',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: _onDestinationSelected,
        destinations: _destinations,
      ),
    );
  }

  void _onDestinationSelected(int index) {
    // Re-tapping the active tab returns it to its initial location (the
    // platform convention on both Android and iOS).
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }
}
