import 'package:connect_hub/core/navigation/app_routes.dart';
import 'package:connect_hub/di/injection.dart';
import 'package:connect_hub/features/feed/cubit/feed_cubit.dart';
import 'package:connect_hub/features/feed/feed_view.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';

/// The Feed tab's entry point: creates the [FeedCubit], starts the first
/// load, and turns the view's callbacks into typed routes.
///
/// The tab shell keeps this page alive while the user visits other tabs, so
/// the feed (and its scroll position) is still there when they come back.
class FeedPage extends StatelessWidget {
  const FeedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<FeedCubit>()..load(),
      child: FeedView(
        onOpenPost: (postId) =>
            PostDetailRoute(postId: postId).push<void>(context),
        onOpenComments: (postId) =>
            CommentsRoute(postId: postId).push<void>(context),
        onOpenProfile: (userId) =>
            UserProfileRoute(userId: userId).push<void>(context),
        onOpenChats: () => const ChatsRoute().push<void>(context),
        onCreatePost: () => const CreatePostRoute().push<void>(context),
      ),
    );
  }
}
