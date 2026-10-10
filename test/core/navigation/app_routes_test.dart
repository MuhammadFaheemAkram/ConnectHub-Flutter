import 'package:connect_hub/core/navigation/app_routes.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // The generated `location` getters are what screens navigate with, so a
  // path change shows up here (and in deep links) instead of at runtime.
  test('typed routes build the expected locations', () {
    expect(const SplashRoute().location, '/splash');
    expect(const LoginRoute().location, '/login');
    expect(const SignUpRoute().location, '/login/signup');

    expect(const FeedRoute().location, '/feed');
    expect(const SearchRoute().location, '/search');
    expect(const BookmarksRoute().location, '/bookmarks');
    expect(const ActivityRoute().location, '/activity');
    expect(const ProfileRoute().location, '/profile');

    expect(const PostDetailRoute(postId: 'p1').location, '/posts/p1');
    expect(const CommentsRoute(postId: 'p1').location, '/posts/p1/comments');
    expect(const UserProfileRoute(userId: 'u_ada').location, '/users/u_ada');
    expect(const CreatePostRoute().location, '/compose');
    expect(const EditProfileRoute().location, '/edit-profile');
    expect(const ChatsRoute().location, '/chats');
    expect(const ChatRoute(conversationId: 'c1').location, '/chats/c1');
    expect(const SettingsRoute().location, '/settings');
  });

  test('the return address travels as an encoded query parameter', () {
    expect(
      const LoginRoute(from: '/posts/p3').location,
      '/login?from=%2Fposts%2Fp3',
    );
    expect(
      const SignUpRoute(from: '/posts/p3').location,
      '/login/signup?from=%2Fposts%2Fp3',
    );
    expect(
      const SplashRoute(from: '/chats/c1').location,
      '/splash?from=%2Fchats%2Fc1',
    );
  });

  test('path parameters are URL-encoded', () {
    expect(const UserProfileRoute(userId: 'a b').location, '/users/a%20b');
  });
}
