import 'package:connect_hub/core/design_system/design_system.dart';
import 'package:connect_hub/core/navigation/back_to_feed_button.dart';
import 'package:connect_hub/domain/model/comment.dart';
import 'package:connect_hub/features/comments/cubit/comments_cubit.dart';
import 'package:connect_hub/features/comments/cubit/comments_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';

/// Renders a post's comments, oldest first, with pull to refresh, a delete
/// for the user's own, and the comment input.
///
/// Stateful for its UI-only objects: the input's controller (cleared after a
/// sent comment) and the list's scroll controller (which then scrolls to it).
class CommentsView extends StatefulWidget {
  const CommentsView({super.key, required this.onOpenProfile});

  /// Called with the user id.
  final ValueChanged<String> onOpenProfile;

  @override
  State<CommentsView> createState() => _CommentsViewState();
}

class _CommentsViewState extends State<CommentsView> {
  final _comment = TextEditingController();
  final _scroll = ScrollController();

  @override
  void dispose() {
    _comment.dispose();
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<CommentsCubit>();
    return MultiBlocListener(
      listeners: [
        BlocListener<CommentsCubit, CommentsState>(
          listenWhen: (previous, current) =>
              current.message != null && current.message != previous.message,
          listener: (context, state) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(SnackBar(content: Text(state.message!.text)));
          },
        ),
        BlocListener<CommentsCubit, CommentsState>(
          listenWhen: (previous, current) =>
              current.sentCount > previous.sentCount,
          listener: (context, state) {
            _comment.clear();
            _scrollToNewest();
          },
        ),
      ],
      child: Scaffold(
        appBar: AppBar(
          leading: const BackToFeedButton(),
          title: const Text('Comments'),
        ),
        body: BlocBuilder<CommentsCubit, CommentsState>(
          builder: (context, state) => Column(
            children: [
              Expanded(
                child: switch (state.status) {
                  CommentsStatus.loading => const LoadingView(
                    message: 'Loading comments…',
                  ),
                  CommentsStatus.failure => ErrorView(
                    message: state.errorMessage,
                    onRetry: cubit.load,
                  ),
                  CommentsStatus.loaded => RefreshIndicator(
                    onRefresh: cubit.refresh,
                    child: state.comments.isEmpty
                        ? const _NoComments()
                        : ListView.builder(
                            controller: _scroll,
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.symmetric(
                              vertical: AppSpacing.xSmall,
                            ),
                            itemCount: state.comments.length,
                            itemBuilder: (context, index) {
                              final comment = state.comments[index];
                              return CommentTile(
                                key: ValueKey(comment.id),
                                comment: comment,
                                onAuthorTap: () =>
                                    widget.onOpenProfile(comment.author.id),
                                onDelete: comment.isMine
                                    ? () => _confirmDelete(comment)
                                    : null,
                              );
                            },
                          ),
                  ),
                },
              ),
              // Nothing to comment on when the comments couldn't load.
              if (state.status != CommentsStatus.failure)
                CommentComposer(
                  controller: _comment,
                  isSending: state.isSending,
                  onSend: cubit.send,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirmDelete(Comment comment) async {
    final confirmed = await showConfirmationDialog(
      context,
      title: 'Delete comment?',
      message: 'It will be removed for everyone.',
      confirmLabel: 'Delete',
      isDestructive: true,
    );
    if (confirmed && mounted) {
      await context.read<CommentsCubit>().delete(comment);
    }
  }

  /// The new comment is the last one. Scroll once it has been laid out.
  void _scrollToNewest() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scroll.hasClients) return;
      _scroll.animateTo(
        _scroll.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }
}

/// "No comments yet", still pullable to refresh.
class _NoComments extends StatelessWidget {
  const _NoComments();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(
            height: constraints.maxHeight,
            child: const EmptyStateView(
              icon: Icons.mode_comment_outlined,
              title: 'No comments yet',
              message: 'Be the first to comment.',
            ),
          ),
        ],
      ),
    );
  }
}
