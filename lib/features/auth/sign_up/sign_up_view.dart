import 'package:connect_hub/core/design_system/design_system.dart';
import 'package:connect_hub/features/auth/sign_up/bloc/sign_up_bloc.dart';
import 'package:connect_hub/features/auth/sign_up/bloc/sign_up_event.dart';
import 'package:connect_hub/features/auth/sign_up/bloc/sign_up_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';

/// Renders the Sign Up form and forwards what the user does to [SignUpBloc].
///
/// Unlike Login, the Bloc never sets a value itself, so the fields need no
/// controllers: they simply report every change.
class SignUpView extends StatelessWidget {
  const SignUpView({super.key, required this.onSignIn});

  /// "Already have an account? Sign in": back to Login.
  final VoidCallback onSignIn;

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<SignUpBloc>();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Create account')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.large),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: BlocBuilder<SignUpBloc, SignUpState>(
                builder: (context, state) {
                  final busy = state.isBusy;
                  final errorMessage = state.errorMessage;
                  return AutofillGroup(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Join the conversation.',
                          style: theme.textTheme.titleMedium,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppSpacing.large),
                        AppTextField(
                          label: 'Name',
                          errorText: state.nameError,
                          enabled: !busy,
                          textInputAction: TextInputAction.next,
                          autofillHints: const [AutofillHints.name],
                          onChanged: (value) =>
                              bloc.add(SignUpNameChanged(value)),
                        ),
                        const SizedBox(height: AppSpacing.small),
                        AppTextField(
                          label: 'Email',
                          errorText: state.emailError,
                          enabled: !busy,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          autofillHints: const [AutofillHints.email],
                          onChanged: (value) =>
                              bloc.add(SignUpEmailChanged(value)),
                        ),
                        const SizedBox(height: AppSpacing.small),
                        AppTextField(
                          label: 'Password',
                          errorText: state.passwordError,
                          enabled: !busy,
                          obscureText: true,
                          textInputAction: TextInputAction.next,
                          autofillHints: const [AutofillHints.newPassword],
                          onChanged: (value) =>
                              bloc.add(SignUpPasswordChanged(value)),
                        ),
                        const SizedBox(height: AppSpacing.small),
                        AppTextField(
                          label: 'Confirm password',
                          errorText: state.confirmPasswordError,
                          enabled: !busy,
                          obscureText: true,
                          textInputAction: TextInputAction.done,
                          onChanged: (value) =>
                              bloc.add(SignUpConfirmPasswordChanged(value)),
                          onSubmitted: (_) => bloc.add(const SignUpSubmitted()),
                        ),
                        if (errorMessage != null) ...[
                          const SizedBox(height: AppSpacing.small),
                          Text(
                            errorMessage,
                            style: TextStyle(color: theme.colorScheme.error),
                          ),
                        ],
                        const SizedBox(height: AppSpacing.large),
                        FilledButton(
                          onPressed: busy
                              ? null
                              : () => bloc.add(const SignUpSubmitted()),
                          child: busy
                              ? const ButtonProgress(
                                  semanticsLabel: 'Creating your account',
                                )
                              : const Text('Create account'),
                        ),
                        const SizedBox(height: AppSpacing.xSmall),
                        TextButton(
                          onPressed: busy ? null : onSignIn,
                          child: const Text('Already have an account? Sign in'),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
