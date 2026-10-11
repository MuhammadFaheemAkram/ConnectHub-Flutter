import 'package:connect_hub/core/navigation/app_routes.dart';
import 'package:connect_hub/di/injection.dart';
import 'package:connect_hub/features/create_post/create_post_view.dart';
import 'package:connect_hub/features/create_post/cubit/create_post_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

/// The New post screen's entry point, shown as a full-screen dialog (see
/// `CreatePostRoute`).
class CreatePostPage extends StatelessWidget {
  const CreatePostPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<CreatePostCubit>(),
      child: CreatePostView(onClose: () => _close(context)),
    );
  }

  /// `pop()` closes the page even while a `PopScope` holds a draft: it is
  /// only called after publishing or confirming the discard. Opened directly
  /// (a deep link), there is nothing underneath, so it goes to the Feed.
  static void _close(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      const FeedRoute().go(context);
    }
  }
}
