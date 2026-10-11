import 'package:connect_hub/core/design_system/theme/app_spacing.dart';
import 'package:connect_hub/core/design_system/widgets/relative_time_text.dart';
import 'package:connect_hub/core/design_system/widgets/user_avatar.dart';
import 'package:connect_hub/domain/model/conversation.dart';
import 'package:material_ui/material_ui.dart';

/// A row in the Chats list: the other person, the last message, when, and
/// how many messages are unread.
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
    final participant = conversation.participant;
    final unread = conversation.unreadCount;
    final hasUnread = unread > 0;
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.medium),
      leading: ExcludeSemantics(
        child: UserAvatar(name: participant.name, url: participant.avatarUrl),
      ),
      title: Text(
        participant.name,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: hasUnread ? const TextStyle(fontWeight: FontWeight.w700) : null,
      ),
      subtitle: Text(
        conversation.lastMessage,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: hasUnread
            ? TextStyle(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              )
            : null,
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          RelativeTimeText(
            conversation.updatedAt,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          if (hasUnread) ...[
            const SizedBox(height: AppSpacing.xxSmall),
            Semantics(
              label: '$unread unread',
              excludeSemantics: true,
              child: Badge.count(count: unread),
            ),
          ],
        ],
      ),
    );
  }
}
