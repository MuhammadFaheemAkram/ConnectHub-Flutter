import 'package:connect_hub/core/design_system/theme/app_colors.dart';
import 'package:connect_hub/core/design_system/theme/app_spacing.dart';
import 'package:connect_hub/core/design_system/widgets/relative_time_text.dart';
import 'package:connect_hub/domain/model/app_notification.dart';
import 'package:material_ui/material_ui.dart';

/// One activity notification: an icon for its kind, the text, and when.
/// Unread ones are bold, with a dot, on the `unread` tint.
class NotificationTile extends StatelessWidget {
  const NotificationTile({super.key, required this.notification, this.onTap});

  final AppNotification notification;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final unread = !notification.isRead;
    final (icon, kind) = switch (notification.kind) {
      NotificationKind.like => (Icons.favorite, 'Like'),
      NotificationKind.comment => (Icons.mode_comment, 'Comment'),
      NotificationKind.follow => (Icons.person_add_alt_1, 'Follow'),
      NotificationKind.mention => (Icons.alternate_email, 'Mention'),
    };
    return Material(
      color: unread ? context.appColors.unread : Colors.transparent,
      child: Semantics(
        // "Unread. Like. Grace Hopper liked your post…"
        label: '${unread ? 'Unread. ' : ''}$kind.',
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.medium,
              vertical: AppSpacing.small,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ExcludeSemantics(
                  child: CircleAvatar(
                    backgroundColor: scheme.secondaryContainer,
                    foregroundColor: scheme.onSecondaryContainer,
                    child: Icon(icon, size: 20),
                  ),
                ),
                const SizedBox(width: AppSpacing.small),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        notification.text,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: unread ? FontWeight.w700 : null,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xxSmall),
                      RelativeTimeText(
                        notification.createdAt,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                if (unread)
                  Padding(
                    padding: const EdgeInsets.only(
                      left: AppSpacing.xSmall,
                      top: AppSpacing.xxSmall,
                    ),
                    child: ExcludeSemantics(
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: scheme.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
