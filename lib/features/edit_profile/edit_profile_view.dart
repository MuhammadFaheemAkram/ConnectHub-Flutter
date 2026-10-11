import 'package:connect_hub/core/common/form_status.dart';
import 'package:connect_hub/core/common/validators.dart';
import 'package:connect_hub/core/design_system/design_system.dart';
import 'package:connect_hub/core/navigation/back_to_feed_button.dart';
import 'package:connect_hub/domain/model/user.dart';
import 'package:connect_hub/features/edit_profile/cubit/edit_profile_cubit.dart';
import 'package:connect_hub/features/edit_profile/cubit/edit_profile_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';

/// The Edit profile form, shown as a full-screen dialog.
///
/// [onClose] leaves the page, after a save or a confirmed discard. Leaving
/// with unsaved changes any other way (the close button, the system back
/// gesture) first asks "Discard changes?", through [PopScope].
class EditProfileView extends StatelessWidget {
  const EditProfileView({super.key, required this.onClose});

  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<EditProfileCubit>();
    return BlocConsumer<EditProfileCubit, EditProfileState>(
      listenWhen: (previous, current) =>
          current.status == FormStatus.success &&
          previous.status != FormStatus.success,
      listener: (context, state) => onClose(),
      builder: (context, state) {
        final original = state.original;
        final loadError = state.loadError;
        return PopScope(
          // Nothing to lose, or already saved: leave freely.
          canPop: !state.hasChanges || state.status == FormStatus.success,
          onPopInvokedWithResult: (didPop, _) async {
            if (didPop) return;
            if (await _confirmDiscard(context)) onClose();
          },
          child: Scaffold(
            appBar: AppBar(
              leading: const BackToFeedButton.close(),
              title: const Text('Edit profile'),
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.xSmall),
                  child: FilledButton(
                    onPressed: state.canSave ? cubit.save : null,
                    child: state.status == FormStatus.submitting
                        ? const ButtonProgress(semanticsLabel: 'Saving')
                        : const Text('Save'),
                  ),
                ),
              ],
            ),
            body: original != null
                ? _ProfileForm(original: original, state: state)
                : loadError != null
                ? ErrorView(message: loadError, onRetry: cubit.load)
                : const LoadingView(message: 'Loading your profile…'),
          ),
        );
      },
    );
  }

  Future<bool> _confirmDiscard(BuildContext context) => showConfirmationDialog(
    context,
    title: 'Discard changes?',
    message: "Your edits to your profile won't be saved.",
    confirmLabel: 'Discard',
    isDestructive: true,
  );
}

/// The three fields. Stateful only for their controllers, which start from
/// the [original] profile; every change goes to the Cubit.
class _ProfileForm extends StatefulWidget {
  const _ProfileForm({required this.original, required this.state});

  final User original;
  final EditProfileState state;

  @override
  State<_ProfileForm> createState() => _ProfileFormState();
}

class _ProfileFormState extends State<_ProfileForm> {
  late final _name = TextEditingController(text: widget.original.name);
  late final _bio = TextEditingController(text: widget.original.bio);
  late final _avatarUrl = TextEditingController(
    text: widget.original.avatarUrl ?? '',
  );

  @override
  void dispose() {
    _name.dispose();
    _bio.dispose();
    _avatarUrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<EditProfileCubit>();
    final state = widget.state;
    final errorMessage = state.errorMessage;
    final theme = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.medium),
      children: [
        AppTextField(
          label: 'Name',
          controller: _name,
          errorText: state.nameError,
          enabled: !state.isBusy,
          textInputAction: TextInputAction.next,
          onChanged: cubit.nameChanged,
        ),
        const SizedBox(height: AppSpacing.medium),
        AppTextField(
          label: 'Bio',
          controller: _bio,
          errorText: state.bioError,
          enabled: !state.isBusy,
          keyboardType: TextInputType.multiline,
          maxLines: 4,
          onChanged: cubit.bioChanged,
        ),
        const SizedBox(height: AppSpacing.xxSmall),
        Align(
          alignment: Alignment.centerRight,
          child: CharacterCounter(
            count: state.bioLength,
            max: Validators.bioMaxLength,
          ),
        ),
        const SizedBox(height: AppSpacing.small),
        AppTextField(
          label: 'Avatar URL',
          hintText: 'https://…',
          controller: _avatarUrl,
          errorText: state.avatarUrlError,
          enabled: !state.isBusy,
          keyboardType: TextInputType.url,
          onChanged: cubit.avatarUrlChanged,
        ),
        if (errorMessage != null) ...[
          const SizedBox(height: AppSpacing.medium),
          Text(errorMessage, style: TextStyle(color: theme.colorScheme.error)),
        ],
      ],
    );
  }
}
