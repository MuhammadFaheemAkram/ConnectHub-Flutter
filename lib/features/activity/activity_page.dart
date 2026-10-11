import 'package:connect_hub/core/navigation/app_routes.dart';
import 'package:connect_hub/di/injection.dart';
import 'package:connect_hub/features/activity/activity_view.dart';
import 'package:connect_hub/features/activity/cubit/activity_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';

/// The Activity tab's entry point: creates the [ActivityCubit], starts the
/// first load, and turns a notification's link into a route.
class ActivityPage extends StatelessWidget {
  const ActivityPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<ActivityCubit>()..load(),
      child: ActivityView(
        onOpenPost: (postId) =>
            PostDetailRoute(postId: postId).push<void>(context),
        onOpenProfile: (userId) => openProfile(context, userId),
      ),
    );
  }
}
