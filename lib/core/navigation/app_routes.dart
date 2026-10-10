import 'package:connect_hub/features/activity/activity_page.dart';
import 'package:connect_hub/features/auth/login/login_page.dart';
import 'package:connect_hub/features/auth/sign_up/sign_up_page.dart';
import 'package:connect_hub/features/bookmarks/bookmarks_page.dart';
import 'package:connect_hub/features/chat_detail/chat_detail_page.dart';
import 'package:connect_hub/features/chats/chats_page.dart';
import 'package:connect_hub/features/comments/comments_page.dart';
import 'package:connect_hub/features/create_post/create_post_page.dart';
import 'package:connect_hub/features/edit_profile/edit_profile_page.dart';
import 'package:connect_hub/features/feed/feed_page.dart';
import 'package:connect_hub/features/post_detail/post_detail_page.dart';
import 'package:connect_hub/features/profile/profile_page.dart';
import 'package:connect_hub/features/search/search_page.dart';
import 'package:connect_hub/features/settings/settings_page.dart';
import 'package:connect_hub/features/shell/main_shell.dart';
import 'package:connect_hub/features/splash/splash_page.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

part 'app_routes.g.dart';

// Typed routes: every destination is a class, and `go_router_builder`
// generates its path parsing, `location` getter and `go`/`push` helpers. A
// typo or a missing parameter is a compile error instead of a runtime "page
// not found" (the Dart equivalent of the iOS `Route` enums).
//
// The tree has three parts:
// 1. auth routes (splash, login, sign up), the only ones reachable while
//    signed out;
// 2. the tab shell, one branch per tab;
// 3. root-level screens, pushed *above* the shell (see "Root-level screens").

// ---------------------------------------------------------------------------
// 1. Auth

/// Shown while the session is being restored.
///
/// [from] is the return address: where the user was going when the gate
/// stepped in (see `authRedirect`). Non-path fields of a typed route become
/// query parameters, e.g. `/splash?from=%2Fposts%2Fp3`.
@TypedGoRoute<SplashRoute>(path: '/splash')
class SplashRoute extends GoRouteData with $SplashRoute {
  const SplashRoute({this.from});

  final String? from;

  @override
  Widget build(BuildContext context, GoRouterState state) => const SplashPage();
}

/// Sign Up is a *child* of Login, so it opens on top of Login and Back
/// returns there. Both carry the return address ([from]) along, so a deep
/// link survives creating an account too.
@TypedGoRoute<LoginRoute>(
  path: '/login',
  routes: [TypedGoRoute<SignUpRoute>(path: 'signup')],
)
class LoginRoute extends GoRouteData with $LoginRoute {
  const LoginRoute({this.from});

  final String? from;

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      LoginPage(from: from);
}

class SignUpRoute extends GoRouteData with $SignUpRoute {
  const SignUpRoute({this.from});

  final String? from;

  @override
  Widget build(BuildContext context, GoRouterState state) => const SignUpPage();
}

// ---------------------------------------------------------------------------
// 2. The tab shell

/// `StatefulShellRoute` gives every tab its own Navigator and keeps inactive
/// tabs alive in an IndexedStack, so switching tabs preserves each tab's
/// state (scroll position, search query).
@TypedStatefulShellRoute<MainShellRoute>(
  branches: [
    TypedStatefulShellBranch<FeedBranch>(
      routes: [TypedGoRoute<FeedRoute>(path: '/feed')],
    ),
    TypedStatefulShellBranch<SearchBranch>(
      routes: [TypedGoRoute<SearchRoute>(path: '/search')],
    ),
    TypedStatefulShellBranch<BookmarksBranch>(
      routes: [TypedGoRoute<BookmarksRoute>(path: '/bookmarks')],
    ),
    TypedStatefulShellBranch<ActivityBranch>(
      routes: [TypedGoRoute<ActivityRoute>(path: '/activity')],
    ),
    TypedStatefulShellBranch<ProfileBranch>(
      routes: [TypedGoRoute<ProfileRoute>(path: '/profile')],
    ),
  ],
)
class MainShellRoute extends StatefulShellRouteData {
  const MainShellRoute();

  @override
  Widget builder(
    BuildContext context,
    GoRouterState state,
    StatefulNavigationShell navigationShell,
  ) {
    return MainShell(navigationShell: navigationShell);
  }
}

// A named navigator key per tab makes each back stack addressable (and
// readable in debugging tools).

class FeedBranch extends StatefulShellBranchData {
  const FeedBranch();

  static final GlobalKey<NavigatorState> $navigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'feedTab');
}

class SearchBranch extends StatefulShellBranchData {
  const SearchBranch();

  static final GlobalKey<NavigatorState> $navigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'searchTab');
}

class BookmarksBranch extends StatefulShellBranchData {
  const BookmarksBranch();

  static final GlobalKey<NavigatorState> $navigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'bookmarksTab');
}

class ActivityBranch extends StatefulShellBranchData {
  const ActivityBranch();

  static final GlobalKey<NavigatorState> $navigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'activityTab');
}

class ProfileBranch extends StatefulShellBranchData {
  const ProfileBranch();

  static final GlobalKey<NavigatorState> $navigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'profileTab');
}

class FeedRoute extends GoRouteData with $FeedRoute {
  const FeedRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) => const FeedPage();
}

class SearchRoute extends GoRouteData with $SearchRoute {
  const SearchRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) => const SearchPage();
}

class BookmarksRoute extends GoRouteData with $BookmarksRoute {
  const BookmarksRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const BookmarksPage();
}

class ActivityRoute extends GoRouteData with $ActivityRoute {
  const ActivityRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const ActivityPage();
}

/// The signed-in user's own profile.
class ProfileRoute extends GoRouteData with $ProfileRoute {
  const ProfileRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const ProfilePage();
}

// ---------------------------------------------------------------------------
// 3. Root-level screens
//
// These routes are declared at the top level, so they live in the *root*
// Navigator. Pushing one from a tab covers the tab bar, and Back returns to
// that tab with its state intact. MovieExplorer did the opposite (Details was
// a child of each tab). Here, detail screens are reachable from several tabs,
// so one route each beats five per-tab copies, and full-screen screens (the
// chat composer, the forms) shouldn't sit above a tab bar anyway.

/// `/posts/:postId`
@TypedGoRoute<PostDetailRoute>(
  path: '/posts/:postId',
  routes: [TypedGoRoute<CommentsRoute>(path: 'comments')],
)
class PostDetailRoute extends GoRouteData with $PostDetailRoute {
  const PostDetailRoute({required this.postId});

  final String postId;

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      PostDetailPage(postId: postId);
}

/// `/posts/:postId/comments`
class CommentsRoute extends GoRouteData with $CommentsRoute {
  const CommentsRoute({required this.postId});

  final String postId;

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      CommentsPage(postId: postId);
}

/// `/users/:userId`: someone else's profile.
@TypedGoRoute<UserProfileRoute>(path: '/users/:userId')
class UserProfileRoute extends GoRouteData with $UserProfileRoute {
  const UserProfileRoute({required this.userId});

  final String userId;

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      ProfilePage(userId: userId);
}

/// `/compose`: a full-screen dialog (a close button instead of Back, and it
/// slides up), the Material counterpart of an iOS sheet.
@TypedGoRoute<CreatePostRoute>(path: '/compose')
class CreatePostRoute extends GoRouteData with $CreatePostRoute {
  const CreatePostRoute();

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) =>
      MaterialPage<void>(
        key: state.pageKey,
        fullscreenDialog: true,
        child: const CreatePostPage(),
      );
}

/// `/edit-profile`: also a full-screen dialog.
@TypedGoRoute<EditProfileRoute>(path: '/edit-profile')
class EditProfileRoute extends GoRouteData with $EditProfileRoute {
  const EditProfileRoute();

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) =>
      MaterialPage<void>(
        key: state.pageKey,
        fullscreenDialog: true,
        child: const EditProfilePage(),
      );
}

/// `/chats`, with each chat as a child (`/chats/:conversationId`), so a deep
/// link to a chat still has the list underneath it.
@TypedGoRoute<ChatsRoute>(
  path: '/chats',
  routes: [TypedGoRoute<ChatRoute>(path: ':conversationId')],
)
class ChatsRoute extends GoRouteData with $ChatsRoute {
  const ChatsRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) => const ChatsPage();
}

class ChatRoute extends GoRouteData with $ChatRoute {
  const ChatRoute({required this.conversationId});

  final String conversationId;

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      ChatDetailPage(conversationId: conversationId);
}

/// `/settings`
@TypedGoRoute<SettingsRoute>(path: '/settings')
class SettingsRoute extends GoRouteData with $SettingsRoute {
  const SettingsRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const SettingsPage();
}
