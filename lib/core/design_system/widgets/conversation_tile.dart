import 'package:connect_hub/core/design_system/theme/app_spacing.dart';
import 'package:connect_hub/core/design_system/widgets/relative_time_text.dart';
import 'package:connect_hub/core/design_system/widgets/user_avatar.dart';
import 'package:connect_hub/domain/model/conversation.dart';
import 'package:material_ui/material_ui.dart';

/// A row in the Chats list: the other person and when they last wrote on the
/// first line; the last message and how many messages are unread on the
/// second.
///
/// A custom row rather than a `ListTile`: a `ListTile` gives its trailing
/// widget a fixed height, so the time and the badge overflowed it at large
/// text sizes. Here every line grows with the text. The row reads as one
/// button: "Grace Hopper, 30 minutes ago, Approved…, 2 unread".
class ConversationTile extends StatelessWidget {
  const ConversationTile({
    super.key,
    required this.conversation,
    required this.onTap,
  });

  final Conversation conversation;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final participant = conversation.participant;
    final unread = conversation.unreadCount;
    final hasUnread = unread > 0;
    return MergeSemantics(
      child: Semantics(
        button: true,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.medium,
              vertical: AppSpacing.small,
            ),
            child: Row(
              children: [
                ExcludeSemantics(
                  child: UserAvatar(
                    name: participant.name,
                    url: participant.avatarUrl,
                  ),
                ),
                const SizedBox(width: AppSpacing.medium),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Expanded(
                            child: Text(
                              participant.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: hasUnread ? FontWeight.w700 : null,
                              ),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.xSmall),
                          RelativeTimeText(
                            conversation.updatedAt,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xxSmall),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              conversation.lastMessage,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: hasUnread
                                    ? scheme.onSurface
                                    : scheme.onSurfaceVariant,
                                fontWeight: hasUnread ? FontWeight.w600 : null,
                              ),
                            ),
                          ),
                          if (hasUnread) ...[
                            const SizedBox(width: AppSpacing.xSmall),
                            Semantics(
                              label: '$unread unread',
                              excludeSemantics: true,
                              child: Badge.count(count: unread),
                            ),
                          ],
                        ],
                      ),
                    ],
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
