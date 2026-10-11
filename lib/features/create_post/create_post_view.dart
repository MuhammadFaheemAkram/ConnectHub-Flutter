import 'package:connect_hub/core/common/form_status.dart';
import 'package:connect_hub/core/common/validators.dart';
import 'package:connect_hub/core/design_system/design_system.dart';
import 'package:connect_hub/core/navigation/back_to_feed_button.dart';
import 'package:connect_hub/features/create_post/cubit/create_post_cubit.dart';
import 'package:connect_hub/features/create_post/cubit/create_post_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';

/// The New post form, shown as a full-screen dialog.
///
/// [onClose] leaves the page, after a post was published or a draft was
/// discarded. Leaving with a draft any other way (the close button, the
/// system back gesture) first asks "Discard post?", through [PopScope].
class CreatePostView extends StatelessWidget {
  const CreatePostView({super.key, required this.onClose});

  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<CreatePostCubit>();
    return BlocConsumer<CreatePostCubit, CreatePostState>(
      listenWhen: (previous, current) =>
          current.status == FormStatus.success &&
          previous.status != FormStatus.success,
      listener: (context, state) => onClose(),
      builder: (context, state) {
        final theme = Theme.of(context);
        final errorMessage = state.errorMessage;
        return PopScope(
          // Nothing to lose, or already published: leave freely.
          canPop: !state.hasDraft || state.status == FormStatus.success,
          onPopInvokedWithResult: (didPop, _) async {
            if (didPop) return;
            if (await _confirmDiscard(context)) onClose();
          },
          child: Scaffold(
            appBar: AppBar(
              leading: const BackToFeedButton.close(),
              title: const Text('New post'),
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.xSmall),
                  child: FilledButton(
                    onPressed: state.canSubmit ? cubit.submit : null,
                    child: state.status == FormStatus.submitting
                        ? const ButtonProgress(semanticsLabel: 'Posting')
                        : const Text('Post'),
                  ),
                ),
              ],
            ),
            body: ListView(
              padding: const EdgeInsets.all(AppSpacing.medium),
              children: [
                TextField(
                  autofocus: true,
                  enabled: !state.isBusy,
                  minLines: 5,
                  maxLines: null,
                  keyboardType: TextInputType.multiline,
                  textCapitalization: TextCapitalization.sentences,
                  onChanged: cubit.contentChanged,
                  decoration: InputDecoration(
                    hintText: "What's on your mind?",
                    errorText: state.contentError,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxSmall),
                Align(
                  alignment: Alignment.centerRight,
                  child: CharacterCounter(
                    count: state.length,
                    max: Validators.postMaxLength,
                  ),
                ),
                const SizedBox(height: AppSpacing.small),
                AppTextField(
                  label: 'Image URL (optional)',
                  hintText: 'https://…',
                  errorText: state.imageUrlError,
                  enabled: !state.isBusy,
                  keyboardType: TextInputType.url,
                  onChanged: cubit.imageUrlChanged,
                ),
                if (errorMessage != null) ...[
                  const SizedBox(height: AppSpacing.medium),
                  Text(
                    errorMessage,
                    style: TextStyle(color: theme.colorScheme.error),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Future<bool> _confirmDiscard(BuildContext context) => showConfirmationDialog(
    context,
    title: 'Discard post?',
    message: "What you've written will be lost.",
    confirmLabel: 'Discard',
    isDestructive: true,
  );
}
