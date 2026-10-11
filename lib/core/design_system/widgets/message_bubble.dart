import 'package:connect_hub/core/design_system/theme/app_spacing.dart';
import 'package:connect_hub/domain/model/message.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

/// One chat message: mine on the right in `primaryContainer`, theirs on the
/// left in `surfaceContainerHighest`, each with its time.
///
/// My message shows "Sending…" in place of the time while it goes out. If it
/// failed, "Not sent · Tap to retry" shows *under* the bubble, in the error
/// color on the page's surface (on the bubble's teal it would be
/// unreadable), and tapping calls [onRetry].
class MessageBubble extends StatelessWidget {
  const MessageBubble({super.key, required this.message, this.onRetry});

  final Message message;
  final VoidCallback? onRetry;

  static const failedLabel = 'Not sent · Tap to retry';
  static final _time = DateFormat.jm();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isMine = message.isMine;
    final failed = message.status == MessageStatus.failed;
    final status = switch (message.status) {
      MessageStatus.sending => 'Sending…',
      MessageStatus.sent => _time.format(message.createdAt.toLocal()),
      MessageStatus.failed => null,
    };

    final bubble = ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.sizeOf(context).width * 0.75,
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: isMine
              ? scheme.primaryContainer
              : scheme.surfaceContainerHighest,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: Radius.circular(isMine ? 18 : 4),
            bottomRight: Radius.circular(isMine ? 4 : 18),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Align(
                alignment: AlignmentDirectional.centerStart,
                widthFactor: 1,
                child: Text(
                  message.text,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: isMine
                        ? scheme.onPrimaryContainer
                        : scheme.onSurface,
                  ),
                ),
              ),
              if (status != null) ...[
                const SizedBox(height: AppSpacing.xxSmall),
                Text(
                  status,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: isMine
                        ? scheme.onPrimaryContainer
                        : scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );

    final content = failed
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              bubble,
              const SizedBox(height: AppSpacing.xxSmall),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.error_outline, size: 16, color: scheme.error),
                  const SizedBox(width: AppSpacing.xxSmall),
                  // Wraps rather than overflows at large text sizes.
                  Flexible(
                    child: Text(
                      failedLabel,
                      textAlign: TextAlign.end,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: scheme.error,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          )
        : bubble;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.medium,
        vertical: AppSpacing.xxSmall,
      ),
      child: Align(
        alignment: isMine
            ? AlignmentDirectional.centerEnd
            : AlignmentDirectional.centerStart,
        child: failed && onRetry != null
            ? Semantics(
                button: true,
                hint: 'Sends the message again',
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: onRetry,
                  child: content,
                ),
              )
            : content,
      ),
    );
  }
}
