import 'package:connect_hub/core/navigation/app_routes.dart';
import 'package:connect_hub/di/injection.dart';
import 'package:connect_hub/features/comments/comments_view.dart';
import 'package:connect_hub/features/comments/cubit/comments_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';

/// The Comments screen's entry point: creates the Cubit for [postId] and
/// turns the view's callbacks into routes.
class CommentsPage extends StatelessWidget {
  const CommentsPage({super.key, required this.postId});

  final String postId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<CommentsCubit>(param1: postId)..load(),
      child: CommentsView(
        onOpenProfile: (userId) =>
            UserProfileRoute(userId: userId).push<void>(context),
      ),
    );
  }
}
