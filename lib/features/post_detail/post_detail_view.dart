import 'package:connect_hub/core/design_system/design_system.dart';
import 'package:connect_hub/core/navigation/back_to_feed_button.dart';
import 'package:connect_hub/domain/model/comment.dart';
import 'package:connect_hub/domain/model/post.dart';
import 'package:connect_hub/features/post_detail/cubit/post_detail_cubit.dart';
import 'package:connect_hub/features/post_detail/cubit/post_detail_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';

/// Renders one post, a preview of its latest comments and a comment input.
///
/// Stateful only for the input's `TextEditingController`: it is cleared when
/// the Cubit reports a sent comment, and kept as typed when sending fails.
class PostDetailView extends StatefulWidget {
  const PostDetailView({
    super.key,
    required this.onOpenComments,
    required this.onOpenProfile,
  });

  final VoidCallback onOpenComments;

  /// Called with the user id.
  final ValueChanged<String> onOpenProfile;

  @override
  State<PostDetailView> createState() => _PostDetailViewState();
}

class _PostDetailViewState extends State<PostDetailView> {
  final _comment = TextEditingController();

  @override
  void dispose() {
    _comment.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<PostDetailCubit>();
    return MultiBlocListener(
      listeners: [
        BlocListener<PostDetailCubit, PostDetailState>(
          listenWhen: (previous, current) =>
              _loaded(current)?.message != null &&
              _loaded(current)?.message != _loaded(previous)?.message,
          listener: (context, state) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(content: Text(_loaded(state)!.message!.text)),
              );
          },
        ),
        BlocListener<PostDetailCubit, PostDetailState>(
          listenWhen: (previous, current) =>
              (_loaded(current)?.sentCount ?? 0) >
              (_loaded(previous)?.sentCount ?? 0),
          listener: (context, state) => _comment.clear(),
        ),
      ],
      child: Scaffold(
        appBar: AppBar(
          leading: const BackToFeedButton(),
          title: const Text('Post'),
        ),
        body: BlocBuilder<PostDetailCubit, PostDetailState>(
          builder: (context, state) => switch (state) {
            PostDetailLoading() => const LoadingView(message: 'Loading post…'),
            PostDetailError(:final message) => ErrorView(
              message: message,
              onRetry: cubit.load,
            ),
            PostDetailNotFound() => const EmptyStateView(
              icon: Icons.article_outlined,
              title: 'This post is no longer available.',
            ),
            PostDetailLoaded() => Column(
              children: [
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: cubit.refresh,
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.xSmall,
                      ),
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.medium,
                          ),
                          child: PostCard(
                            post: state.post,
                            onAuthorTap: () =>
                                widget.onOpenProfile(state.post.author.id),
                            onLike: () => cubit.toggleLike(state.post),
                            onComment: widget.onOpenComments,
                            onBookmark: () => cubit.toggleBookmark(state.post),
                          ),
                        ),
                        _CommentsPreview(
                          post: state.post,
                          comments: state.recentComments,
                          onOpenComments: widget.onOpenComments,
                          onOpenProfile: widget.onOpenProfile,
                        ),
                      ],
                    ),
                  ),
                ),
                ComposerBar(
                  controller: _comment,
                  isSending: state.isSending,
                  onSend: cubit.sendComment,
                ),
              ],
            ),
          },
        ),
      ),
    );
  }

  static PostDetailLoaded? _loaded(PostDetailState state) =>
      state is PostDetailLoaded ? state : null;
}

/// "Comments": the latest few, then a link to all of them.
class _CommentsPreview extends StatelessWidget {
  const _CommentsPreview({
    required this.post,
    required this.comments,
    required this.onOpenComments,
    required this.onOpenProfile,
  });

  final Post post;
  final List<Comment> comments;
  final VoidCallback onOpenComments;
  final ValueChanged<String> onOpenProfile;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final count = post.commentCount;
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.medium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.medium),
            child: Text('Comments', style: theme.textTheme.titleMedium),
          ),
          if (comments.isEmpty)
            Padding(
              padding: const EdgeInsets.all(AppSpacing.medium),
              child: Text(
                'No comments yet. Be the first to comment.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            )
          else
            for (final comment in comments)
              CommentTile(
                comment: comment,
                onAuthorTap: () => onOpenProfile(comment.author.id),
              ),
          if (count > 0)
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xSmall,
              ),
              child: TextButton(
                onPressed: onOpenComments,
                child: Text(
                  count == 1 ? 'View 1 comment' : 'View all $count comments',
                ),
              ),
            ),
        ],
      ),
    );
  }
}
