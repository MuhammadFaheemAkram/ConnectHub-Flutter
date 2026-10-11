import 'package:connect_hub/core/design_system/theme/app_spacing.dart';
import 'package:connect_hub/core/design_system/widgets/relative_time_text.dart';
import 'package:connect_hub/core/design_system/widgets/user_avatar.dart';
import 'package:connect_hub/domain/model/comment.dart';
import 'package:material_ui/material_ui.dart';

/// One comment: the author's picture and name ("You" for the signed-in
/// user's own), the time and the text.
///
/// [onDelete] adds a ⋮ menu with "Delete". Screens pass it only for the
/// user's own comments; confirming is up to them.
class CommentTile extends StatelessWidget {
  const CommentTile({
    super.key,
    required this.comment,
    this.onAuthorTap,
    this.onDelete,
  });

  final Comment comment;
  final VoidCallback? onAuthorTap;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final author = comment.author;
    final onDelete = this.onDelete;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.medium,
        AppSpacing.xSmall,
        AppSpacing.xxSmall,
        AppSpacing.xSmall,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: onAuthorTap,
            customBorder: const CircleBorder(),
            child: UserAvatar(
              name: author.name,
              url: author.avatarUrl,
              size: 36,
            ),
          ),
          const SizedBox(width: AppSpacing.small),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        comment.isMine ? 'You' : author.name,
                        style: theme.textTheme.titleSmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xSmall),
                    RelativeTimeText(
                      comment.createdAt,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xxSmall),
                Text(comment.text, style: theme.textTheme.bodyMedium),
              ],
            ),
          ),
          if (onDelete != null)
            PopupMenuButton<void>(
              tooltip: 'Comment options',
              icon: const Icon(Icons.more_vert),
              itemBuilder: (context) => [
                PopupMenuItem<void>(
                  onTap: onDelete,
                  child: const Text('Delete'),
                ),
              ],
            )
          else
            const SizedBox(width: AppSpacing.small),
        ],
      ),
    );
  }
}
