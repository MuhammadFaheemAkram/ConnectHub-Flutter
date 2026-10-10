import 'package:cached_network_image/cached_network_image.dart';
import 'package:connect_hub/core/common/compact_count.dart';
import 'package:connect_hub/core/design_system/theme/app_colors.dart';
import 'package:connect_hub/core/design_system/theme/app_radius.dart';
import 'package:connect_hub/core/design_system/theme/app_spacing.dart';
import 'package:connect_hub/core/design_system/widgets/relative_time_text.dart';
import 'package:connect_hub/core/design_system/widgets/user_avatar.dart';
import 'package:connect_hub/domain/model/post.dart';
import 'package:material_ui/material_ui.dart';

/// A post in a list: the author, the time, the text, an optional image, then
/// like, comment and bookmark buttons.
///
/// Every callback is optional, so each screen wires only what it supports,
/// and the card itself holds no navigation or business logic. The buttons
/// show whatever [post] says: after a tap, the new state arrives from drift.
class PostCard extends StatelessWidget {
  const PostCard({
    super.key,
    required this.post,
    this.onTap,
    this.onAuthorTap,
    this.onLike,
    this.onComment,
    this.onBookmark,
  });

  final Post post;

  /// Opens the post.
  final VoidCallback? onTap;

  /// Opens the author's profile.
  final VoidCallback? onAuthorTap;

  final VoidCallback? onLike;

  /// Opens the comments.
  final VoidCallback? onComment;

  final VoidCallback? onBookmark;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final imageUrl = post.imageUrl;
    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.medium,
            AppSpacing.small,
            AppSpacing.xSmall,
            AppSpacing.xxSmall,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _AuthorHeader(post: post, onTap: onAuthorTap),
              const SizedBox(height: AppSpacing.xSmall),
              Padding(
                padding: const EdgeInsets.only(right: AppSpacing.xSmall),
                child: Text(post.content, style: theme.textTheme.bodyLarge),
              ),
              if (imageUrl != null) ...[
                const SizedBox(height: AppSpacing.small),
                Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.xSmall),
                  child: _PostImage(url: imageUrl),
                ),
              ],
              const SizedBox(height: AppSpacing.xxSmall),
              _Actions(
                post: post,
                onLike: onLike,
                onComment: onComment,
                onBookmark: onBookmark,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AuthorHeader extends StatelessWidget {
  const _AuthorHeader({required this.post, required this.onTap});

  final Post post;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final author = post.author;
    return InkWell(
      onTap: onTap,
      borderRadius: const BorderRadius.all(Radius.circular(AppRadius.small)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxSmall),
        child: Row(
          children: [
            // The name is right next to it, so the picture stays silent.
            ExcludeSemantics(
              child: UserAvatar(name: author.name, url: author.avatarUrl),
            ),
            const SizedBox(width: AppSpacing.small),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    author.name,
                    style: theme.textTheme.titleSmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  RelativeTimeText(
                    post.createdAt,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The post's picture, 16:9 with rounded corners. Offline it falls back to a
/// placeholder; everything else on the card still works.
class _PostImage extends StatelessWidget {
  const _PostImage({required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final placeholder = ColoredBox(color: scheme.surfaceContainerHighest);
    return ExcludeSemantics(
      child: ClipRRect(
        borderRadius: const BorderRadius.all(Radius.circular(AppRadius.medium)),
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: CachedNetworkImage(
            imageUrl: url,
            fit: BoxFit.cover,
            fadeInDuration: const Duration(milliseconds: 200),
            placeholder: (_, _) => placeholder,
            errorWidget: (_, _, _) => ColoredBox(
              color: scheme.surfaceContainerHighest,
              child: Icon(
                Icons.image_not_supported_outlined,
                color: scheme.onSurfaceVariant,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Actions extends StatelessWidget {
  const _Actions({
    required this.post,
    required this.onLike,
    required this.onComment,
    required this.onBookmark,
  });

  final Post post;
  final VoidCallback? onLike;
  final VoidCallback? onComment;
  final VoidCallback? onBookmark;

  @override
  Widget build(BuildContext context) {
    final comments = post.commentCount;
    return Row(
      children: [
        _CountButton(
          tooltip: post.isLiked ? 'Unlike' : 'Like',
          icon: post.isLiked ? Icons.favorite : Icons.favorite_border,
          iconColor: post.isLiked ? context.appColors.like : null,
          count: post.likeCount,
          onPressed: onLike,
        ),
        _CountButton(
          tooltip: '$comments comment${comments == 1 ? '' : 's'}',
          icon: Icons.mode_comment_outlined,
          count: comments,
          onPressed: onComment,
        ),
        const Spacer(),
        IconButton(
          tooltip: post.isBookmarked ? 'Remove bookmark' : 'Bookmark',
          isSelected: post.isBookmarked,
          icon: const Icon(Icons.bookmark_border),
          selectedIcon: const Icon(Icons.bookmark),
          onPressed: onBookmark,
        ),
      ],
    );
  }
}

/// An icon with a count next to it ("♥ 142"), tappable as one button.
class _CountButton extends StatelessWidget {
  const _CountButton({
    required this.tooltip,
    required this.icon,
    required this.count,
    required this.onPressed,
    this.iconColor,
  });

  final String tooltip;
  final IconData icon;
  final Color? iconColor;
  final int count;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: TextButton.icon(
        style: TextButton.styleFrom(
          foregroundColor: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        onPressed: onPressed,
        icon: Icon(icon, color: iconColor),
        label: Text(compactCount(count)),
      ),
    );
  }
}
