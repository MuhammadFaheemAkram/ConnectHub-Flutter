import 'package:connect_hub/core/design_system/design_system.dart';
import 'package:connect_hub/features/auth/login/bloc/login_bloc.dart';
import 'package:connect_hub/features/auth/login/bloc/login_event.dart';
import 'package:connect_hub/features/auth/login/bloc/login_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';

/// Renders the Login form and forwards what the user does to [LoginBloc].
///
/// The Bloc owns the field values. This widget keeps two
/// `TextEditingController`s only so it can *show* values the Bloc sets itself
/// ("Use demo account"); a `BlocListener` copies them into the fields.
class LoginView extends StatefulWidget {
  const LoginView({super.key, required this.onCreateAccount, this.notice});

  final VoidCallback onCreateAccount;

  /// Shown above the form, e.g. "Your session has expired…".
  final String? notice;

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _email = TextEditingController();
  final _password = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<LoginBloc>();
    final theme = Theme.of(context);
    final notice = widget.notice;

    return BlocListener<LoginBloc, LoginState>(
      listenWhen: (previous, current) =>
          previous.email != current.email ||
          previous.password != current.password,
      listener: (context, state) {
        _show(_email, state.email);
        _show(_password, state.password);
      },
      child: Scaffold(
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.large),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: BlocBuilder<LoginBloc, LoginState>(
                  builder: (context, state) {
                    final busy = state.isBusy;
                    final errorMessage = state.errorMessage;
                    return AutofillGroup(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (notice != null) ...[
                            NoticeBanner(
                              icon: Icons.lock_clock_outlined,
                              message: notice,
                            ),
                            const SizedBox(height: AppSpacing.large),
                          ],
                          Icon(
                            Icons.forum_rounded,
                            size: 56,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(height: AppSpacing.small),
                          Text(
                            'Welcome to ConnectHub',
                            style: theme.textTheme.headlineSmall,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: AppSpacing.xxSmall),
                          Text(
                            'Sign in to continue.',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: AppSpacing.large),
                          AppTextField(
                            label: 'Email',
                            controller: _email,
                            errorText: state.emailError,
                            enabled: !busy,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            autofillHints: const [AutofillHints.email],
                            onChanged: (value) =>
                                bloc.add(LoginEmailChanged(value)),
                          ),
                          const SizedBox(height: AppSpacing.small),
                          AppTextField(
                            label: 'Password',
                            controller: _password,
                            errorText: state.passwordError,
                            enabled: !busy,
                            obscureText: true,
                            textInputAction: TextInputAction.done,
                            autofillHints: const [AutofillHints.password],
                            onChanged: (value) =>
                                bloc.add(LoginPasswordChanged(value)),
                            onSubmitted: (_) =>
                                bloc.add(const LoginSubmitted()),
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
                                : () => bloc.add(const LoginSubmitted()),
                            child: busy
                                ? const ButtonProgress(
                                    semanticsLabel: 'Signing in',
                                  )
                                : const Text('Sign in'),
                          ),
                          const SizedBox(height: AppSpacing.xSmall),
                          TextButton(
                            onPressed: busy
                                ? null
                                : () => bloc.add(
                                    const LoginDemoAccountRequested(),
                                  ),
                            child: const Text('Use demo account'),
                          ),
                          const Divider(height: AppSpacing.xLarge),
                          Text(
                            'New to ConnectHub?',
                            style: theme.textTheme.bodyMedium,
                            textAlign: TextAlign.center,
                          ),
                          TextButton(
                            onPressed: busy ? null : widget.onCreateAccount,
                            child: const Text('Create an account'),
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
      ),
    );
  }

  /// Puts a value set by the Bloc into a field, unless the field already
  /// shows it (it does whenever the user typed it). The cursor goes to the
  /// end.
  void _show(TextEditingController controller, String value) {
    if (controller.text == value) return;
    controller.value = TextEditingValue(
      text: value,
      selection: TextSelection.collapsed(offset: value.length),
    );
  }
}
