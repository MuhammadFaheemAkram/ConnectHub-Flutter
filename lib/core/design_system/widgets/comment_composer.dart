import 'package:connect_hub/core/common/validators.dart';
import 'package:connect_hub/core/design_system/theme/app_spacing.dart';
import 'package:connect_hub/core/design_system/widgets/button_progress.dart';
import 'package:material_ui/material_ui.dart';

/// The "Add a comment…" bar at the bottom of a screen.
///
/// The text lives in [controller], which the screen owns: it clears the
/// field once a comment is sent, and leaves it alone when sending fails, so
/// nothing typed is lost. Send stays disabled while the text is blank, and
/// shows progress while [isSending].
class CommentComposer extends StatelessWidget {
  const CommentComposer({
    super.key,
    required this.controller,
    required this.isSending,
    required this.onSend,
  });

  final TextEditingController controller;
  final bool isSending;
  final ValueChanged<String> onSend;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: scheme.surfaceContainer,
        border: Border(top: BorderSide(color: scheme.outlineVariant)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xSmall),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  // Read-only, not disabled, while sending: the keyboard
                  // stays up, and the text can't change under the request.
                  readOnly: isSending,
                  minLines: 1,
                  maxLines: 4,
                  maxLength: Validators.commentMaxLength,
                  // The limit is enforced quietly; a counter would only
                  // crowd the bar.
                  buildCounter: (
                    _, {
                    required currentLength,
                    required isFocused,
                    maxLength,
                  }) => null,
                  keyboardType: TextInputType.multiline,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    hintText: 'Add a comment…',
                    isDense: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(24)),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.xxSmall),
              ListenableBuilder(
                listenable: controller,
                builder: (context, _) {
                  final canSend =
                      !isSending && controller.text.trim().isNotEmpty;
                  return IconButton(
                    tooltip: 'Send',
                    onPressed: canSend ? () => onSend(controller.text) : null,
                    icon: isSending
                        ? const ButtonProgress(semanticsLabel: 'Sending')
                        : const Icon(Icons.send),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
