import 'package:connect_hub/core/navigation/app_routes.dart';
import 'package:connect_hub/di/injection.dart';
import 'package:connect_hub/features/post_detail/cubit/post_detail_cubit.dart';
import 'package:connect_hub/features/post_detail/post_detail_view.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';

/// Post Detail's entry point: creates the Cubit for [postId] and turns the
/// view's callbacks into routes.
class PostDetailPage extends StatelessWidget {
  const PostDetailPage({super.key, required this.postId});

  final String postId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      // The id reaches the Cubit through DI (`@factoryParam`).
      create: (_) => getIt<PostDetailCubit>(param1: postId)..load(),
      child: PostDetailView(
        onOpenComments: () => CommentsRoute(postId: postId).push<void>(context),
        onOpenProfile: (userId) =>
            UserProfileRoute(userId: userId).push<void>(context),
      ),
    );
  }
}
