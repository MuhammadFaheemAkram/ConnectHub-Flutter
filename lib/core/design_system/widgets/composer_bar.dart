import 'package:connect_hub/core/common/validators.dart';
import 'package:connect_hub/core/design_system/theme/app_spacing.dart';
import 'package:connect_hub/core/design_system/widgets/button_progress.dart';
import 'package:material_ui/material_ui.dart';

/// The text input bar at the bottom of a screen: "Add a comment…" under a
/// post, "Message…" in a chat.
///
/// The text lives in [controller], which the screen owns: it clears the
/// field once the text is sent, and leaves it alone when sending fails, so
/// nothing typed is lost. Send stays disabled while the text is blank, and
/// shows progress while [isSending].
class ComposerBar extends StatelessWidget {
  const ComposerBar({
    super.key,
    required this.controller,
    required this.onSend,
    this.isSending = false,
    this.hintText = 'Add a comment…',
    this.maxLength = Validators.commentMaxLength,
  });

  final TextEditingController controller;
  final ValueChanged<String> onSend;
  final bool isSending;
  final String hintText;

  /// Enforced by the field, quietly (no counter).
  final int maxLength;

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
                  maxLength: maxLength,
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
                  decoration: InputDecoration(
                    hintText: hintText,
                    isDense: true,
                    border: const OutlineInputBorder(
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
