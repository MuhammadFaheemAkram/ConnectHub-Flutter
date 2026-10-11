import 'package:connect_hub/core/common/ui_message.dart';
import 'package:connect_hub/core/design_system/design_system.dart';
import 'package:connect_hub/features/bookmarks/cubit/bookmarks_cubit.dart';
import 'package:connect_hub/features/bookmarks/cubit/bookmarks_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';

/// The Bookmarks tab: the saved posts, newest bookmark first, with pull to
/// refresh. The bookmark button removes a post, and the SnackBar offers
/// Undo.
class BookmarksView extends StatelessWidget {
  const BookmarksView({
    super.key,
    required this.onOpenPost,
    required this.onOpenComments,
    required this.onOpenProfile,
  });

  /// Called with the post's id.
  final ValueChanged<String> onOpenPost;

  /// Called with the post's id.
  final ValueChanged<String> onOpenComments;

  /// Called with the author's user id.
  final ValueChanged<String> onOpenProfile;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<BookmarksCubit>();
    return Scaffold(
      appBar: AppBar(title: const Text('Bookmarks')),
      body: BlocConsumer<BookmarksCubit, BookmarksState>(
        listenWhen: (previous, current) =>
            current.message != null && current.message != previous.message,
        listener: (context, state) {
          final message = state.message!;
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text(message.text),
                action: switch (message.action) {
                  UiMessageAction.undo => SnackBarAction(
                    label: UiMessageAction.undo.label,
                    onPressed: cubit.undoRemove,
                  ),
                  null => null,
                },
              ),
            );
        },
        builder: (context, state) => switch (state.status) {
          BookmarksStatus.loading => const LoadingView(
            message: 'Loading bookmarks…',
          ),
          BookmarksStatus.failure => ErrorView(
            message: state.errorMessage,
            onRetry: cubit.load,
          ),
          BookmarksStatus.loaded => RefreshIndicator(
            onRefresh: cubit.refresh,
            child: state.posts.isEmpty
                ? const _NoBookmarks()
                : ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.medium,
                      AppSpacing.xSmall,
                      AppSpacing.medium,
                      AppSpacing.large,
                    ),
                    itemCount: state.posts.length,
                    separatorBuilder: (_, _) =>
                        const SizedBox(height: AppSpacing.small),
                    itemBuilder: (context, index) {
                      final post = state.posts[index];
                      return PostCard(
                        key: ValueKey(post.id),
                        post: post,
                        onTap: () => onOpenPost(post.id),
                        onAuthorTap: () => onOpenProfile(post.author.id),
                        onLike: () => cubit.toggleLike(post),
                        onComment: () => onOpenComments(post.id),
                        // Every post here is bookmarked: the button removes.
                        onBookmark: () => cubit.remove(post),
                      );
                    },
                  ),
          ),
        },
      ),
    );
  }
}

/// "No bookmarks yet", still pullable to refresh.
class _NoBookmarks extends StatelessWidget {
  const _NoBookmarks();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(
            height: constraints.maxHeight,
            child: const EmptyStateView(
              icon: Icons.bookmark_border,
              title: 'No bookmarks yet',
              message: 'Tap the bookmark icon on a post to save it here.',
            ),
          ),
        ],
      ),
    );
  }
}
