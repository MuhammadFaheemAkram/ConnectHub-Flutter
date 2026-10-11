import 'package:connect_hub/core/navigation/app_routes.dart';
import 'package:connect_hub/di/injection.dart';
import 'package:connect_hub/features/search/bloc/search_bloc.dart';
import 'package:connect_hub/features/search/bloc/search_event.dart';
import 'package:connect_hub/features/search/search_view.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';

/// The Search tab's entry point: creates the [SearchBloc] and turns the
/// view's callbacks into typed routes.
///
/// The tab shell keeps this page alive, so the query and its results are
/// still there after visiting another tab.
class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          getIt<SearchBloc>()..add(const SearchSubscriptionRequested()),
      child: SearchView(
        onOpenPost: (postId) =>
            PostDetailRoute(postId: postId).push<void>(context),
        onOpenComments: (postId) =>
            CommentsRoute(postId: postId).push<void>(context),
        onOpenProfile: (userId) => openProfile(context, userId),
      ),
    );
  }
}
