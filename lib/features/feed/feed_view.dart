import 'package:connect_hub/core/common/ui_message.dart';
import 'package:connect_hub/core/design_system/design_system.dart';
import 'package:connect_hub/domain/model/post.dart';
import 'package:connect_hub/features/feed/cubit/feed_cubit.dart';
import 'package:connect_hub/features/feed/cubit/feed_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';

/// Renders the Feed and forwards what the user does: likes and bookmarks to
/// the [FeedCubit], navigation to the callbacks (the page turns them into
/// routes, so this view never needs a router in its tests).
class FeedView extends StatelessWidget {
  const FeedView({
    super.key,
    required this.onOpenPost,
    required this.onOpenComments,
    required this.onOpenProfile,
    required this.onOpenChats,
    required this.onCreatePost,
    this.unreadChats = 0,
  });

  /// Called with the post's id.
  final ValueChanged<String> onOpenPost;

  /// Called with the post's id.
  final ValueChanged<String> onOpenComments;

  /// Called with the author's user id.
  final ValueChanged<String> onOpenProfile;

  final VoidCallback onOpenChats;
  final VoidCallback onCreatePost;

  /// The Chats button's badge; 0 hides it.
  final int unreadChats;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ConnectHub'),
        actions: [
          IconButton(
            tooltip: 'Chats',
            icon: UnreadBadge(
              count: unreadChats,
              child: const Icon(Icons.chat_bubble_outline),
            ),
            onPressed: onOpenChats,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'New post',
        onPressed: onCreatePost,
        child: const Icon(Icons.edit_outlined),
      ),
      body: BlocConsumer<FeedCubit, FeedState>(
        // A message shows once, when it changes. Its id makes a repeated
        // failure count as a change.
        listenWhen: (previous, current) =>
            _messageOf(current) != null &&
            _messageOf(current) != _messageOf(previous),
        listener: (context, state) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(content: Text(_messageOf(state)!.text)));
        },
        builder: (context, state) {
          final cubit = context.read<FeedCubit>();
          return switch (state) {
            FeedLoading() => const LoadingView(message: 'Loading posts…'),
            FeedError(:final message) => ErrorView(
              message: message,
              onRetry: cubit.load,
            ),
            FeedEmpty() => RefreshIndicator(
              onRefresh: cubit.refresh,
              child: _EmptyFeed(onCreatePost: onCreatePost),
            ),
            FeedLoaded() => _PostList(
              state: state,
              onRefresh: cubit.refresh,
              onLoadMore: cubit.loadMore,
              cardFor: (post) => PostCard(
                key: ValueKey(post.id),
                post: post,
                onTap: () => onOpenPost(post.id),
                onAuthorTap: () => onOpenProfile(post.author.id),
                onLike: () => cubit.toggleLike(post),
                onComment: () => onOpenComments(post.id),
                onBookmark: () => cubit.toggleBookmark(post),
              ),
            ),
          };
        },
      ),
    );
  }

  static UiMessage? _messageOf(FeedState state) => switch (state) {
    FeedLoaded(:final message) => message,
    _ => null,
  };
}

/// The posts, with pull to refresh and infinite scroll.
///
/// Stateful only for its `ScrollController`, the one piece of UI state it
/// owns: when the user nears the end, it asks for the next page.
class _PostList extends StatefulWidget {
  const _PostList({
    required this.state,
    required this.onRefresh,
    required this.onLoadMore,
    required this.cardFor,
  });

  final FeedLoaded state;
  final Future<void> Function() onRefresh;
  final VoidCallback onLoadMore;
  final Widget Function(Post post) cardFor;

  @override
  State<_PostList> createState() => _PostListState();
}

class _PostListState extends State<_PostList> {
  final _scroll = ScrollController();

  /// "Near the end": less than about a screen of posts left below.
  static const _loadMoreDistance = 600.0;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_loadMoreIfNearEnd);
    _checkAfterLayout();
  }

  @override
  void didUpdateWidget(_PostList oldWidget) {
    super.didUpdateWidget(oldWidget);
    // A page can arrive without the user scrolling, or add nothing new (e.g.
    // posts already cached). Check again once it is laid out, so a list
    // that is still short keeps loading.
    final old = oldWidget.state;
    final current = widget.state;
    if (old.posts.length != current.posts.length ||
        old.loadMore != current.loadMore) {
      _checkAfterLayout();
    }
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _checkAfterLayout() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _loadMoreIfNearEnd();
    });
  }

  void _loadMoreIfNearEnd() {
    final state = widget.state;
    // A failed page waits for the footer's Retry instead of retrying in a
    // loop.
    if (!state.hasMore || state.loadMore != LoadMoreStatus.idle) return;
    if (!_scroll.hasClients) return;
    if (_scroll.position.extentAfter < _loadMoreDistance) widget.onLoadMore();
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    final posts = state.posts;
    return RefreshIndicator(
      onRefresh: widget.onRefresh,
      child: ListView.separated(
        controller: _scroll,
        physics: const AlwaysScrollableScrollPhysics(),
        // Bottom padding keeps the last post clear of the FAB.
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.medium,
          AppSpacing.xSmall,
          AppSpacing.medium,
          AppSpacing.xLarge * 3,
        ),
        itemCount: posts.length + 1,
        separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.small),
        itemBuilder: (context, index) => index < posts.length
            ? widget.cardFor(posts[index])
            : _FeedFooter(
                hasMore: state.hasMore,
                status: state.loadMore,
                onRetry: widget.onLoadMore,
              ),
      ),
    );
  }
}

/// The end of the list: a spinner while there is more, "Couldn't load more
/// · Retry" after a failure, and "You're all caught up" at the very end.
class _FeedFooter extends StatelessWidget {
  const _FeedFooter({
    required this.hasMore,
    required this.status,
    required this.onRetry,
  });

  final bool hasMore;
  final LoadMoreStatus status;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final quiet = theme.textTheme.bodyMedium?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );
    if (!hasMore) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.large),
        child: Text(
          "You're all caught up",
          style: quiet,
          textAlign: TextAlign.center,
        ),
      );
    }
    if (status == LoadMoreStatus.failed) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xSmall),
        child: Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text("Couldn't load more", style: quiet),
            TextButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      );
    }
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: AppSpacing.large),
      child: Center(
        child: SizedBox.square(
          dimension: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            semanticsLabel: 'Loading more posts',
          ),
        ),
      ),
    );
  }
}

/// "No posts yet", still pullable to refresh.
class _EmptyFeed extends StatelessWidget {
  const _EmptyFeed({required this.onCreatePost});

  final VoidCallback onCreatePost;

  @override
  Widget build(BuildContext context) {
    // RefreshIndicator needs something scrollable to pull, even when there is
    // nothing to scroll.
    return LayoutBuilder(
      builder: (context, constraints) => ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(
            height: constraints.maxHeight,
            child: EmptyStateView(
              icon: Icons.dynamic_feed_outlined,
              title: 'No posts yet',
              message: 'Pull to refresh or share the first post.',
              action: FilledButton.tonal(
                onPressed: onCreatePost,
                child: const Text('New post'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
