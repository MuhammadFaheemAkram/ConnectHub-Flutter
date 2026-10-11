import 'package:connect_hub/core/navigation/app_routes.dart';
import 'package:connect_hub/di/injection.dart';
import 'package:connect_hub/features/bookmarks/bookmarks_view.dart';
import 'package:connect_hub/features/bookmarks/cubit/bookmarks_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';

/// The Bookmarks tab's entry point: creates the [BookmarksCubit], refreshes
/// from the server as the tab opens, and turns the view's callbacks into
/// typed routes.
///
/// The tab shell builds this page the first time the tab is opened and then
/// keeps it alive. Bookmarks made on other tabs reach the list through
/// drift meanwhile, so it needs no refresh on every visit.
class BookmarksPage extends StatelessWidget {
  const BookmarksPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<BookmarksCubit>()..load(),
      child: BookmarksView(
        onOpenPost: (postId) =>
            PostDetailRoute(postId: postId).push<void>(context),
        onOpenComments: (postId) =>
            CommentsRoute(postId: postId).push<void>(context),
        onOpenProfile: (userId) => openProfile(context, userId),
      ),
    );
  }
}
