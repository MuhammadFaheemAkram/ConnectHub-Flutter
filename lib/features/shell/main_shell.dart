import 'package:connect_hub/core/design_system/design_system.dart';
import 'package:connect_hub/di/injection.dart';
import 'package:connect_hub/features/shell/cubit/badges_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

/// Hosts the bottom [NavigationBar] around the active tab.
///
/// [navigationShell] holds the five tab navigators in an IndexedStack; this
/// widget only decides which branch is visible. Each tab screen brings its own
/// `Scaffold`, `AppBar` and actions (the Feed's FAB, for example).
///
/// The shell exists only while signed in, so it is also where session-scoped
/// state lives: the [BadgesCubit] behind the unread badges. Provided here,
/// above the tab navigators, it reaches the Feed's Chats button too.
class MainShell extends StatelessWidget {
  const MainShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<BadgesCubit>()..load(),
      child: _ShellScaffold(navigationShell: navigationShell),
    );
  }
}

class _ShellScaffold extends StatelessWidget {
  const _ShellScaffold({required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    final unreadActivity = context.select(
      (BadgesCubit cubit) => cubit.state.activity,
    );
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: _onDestinationSelected,
        // Order must match the branches declared in `app_routes.dart`.
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Feed',
          ),
          const NavigationDestination(
            icon: Icon(Icons.search_outlined),
            selectedIcon: Icon(Icons.search),
            label: 'Search',
          ),
          const NavigationDestination(
            icon: Icon(Icons.bookmark_border),
            selectedIcon: Icon(Icons.bookmark),
            label: 'Bookmarks',
          ),
          NavigationDestination(
            icon: UnreadBadge(
              count: unreadActivity,
              child: const Icon(Icons.notifications_none),
            ),
            selectedIcon: UnreadBadge(
              count: unreadActivity,
              child: const Icon(Icons.notifications),
            ),
            label: 'Activity',
          ),
          const NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
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
