import 'package:connect_hub/di/injection.dart';
import 'package:connect_hub/features/auth/sign_up/bloc/sign_up_bloc.dart';
import 'package:connect_hub/features/auth/sign_up/sign_up_view.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

/// Wires the Sign Up screen. Like Login, success needs no navigation here:
/// the new session moves the router's gate to the Feed (or to the return
/// address in the URL).
class SignUpPage extends StatelessWidget {
  const SignUpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<SignUpBloc>(),
      child: SignUpView(onSignIn: () => context.pop()),
    );
  }
}
