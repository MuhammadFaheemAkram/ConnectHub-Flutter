import 'package:connect_hub/core/common/app_exception.dart';
import 'package:connect_hub/core/navigation/app_routes.dart';
import 'package:connect_hub/di/injection.dart';
import 'package:connect_hub/domain/model/session_state.dart';
import 'package:connect_hub/features/auth/bloc/auth_bloc.dart';
import 'package:connect_hub/features/auth/bloc/auth_state.dart';
import 'package:connect_hub/features/auth/login/bloc/login_bloc.dart';
import 'package:connect_hub/features/auth/login/login_view.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';

/// Wires the Login screen: provides its [LoginBloc] and hands the view plain
/// values and callbacks. The view therefore needs no router, no `getIt` and
/// no `AuthBloc` in its widget tests.
class LoginPage extends StatelessWidget {
  const LoginPage({super.key, this.from});

  /// The return address, passed on to Sign Up so it survives that detour.
  final String? from;

  @override
  Widget build(BuildContext context) {
    final sessionExpired = context.select(
      (AuthBloc bloc) => switch (bloc.state) {
        AuthUnauthenticated(reason: SignOutReason.expired) => true,
        _ => false,
      },
    );
    return BlocProvider(
      create: (_) => getIt<LoginBloc>(),
      child: LoginView(
        notice: sessionExpired ? const UnauthorizedException().message : null,
        onCreateAccount: () => SignUpRoute(from: from).push<void>(context),
      ),
    );
  }
}
