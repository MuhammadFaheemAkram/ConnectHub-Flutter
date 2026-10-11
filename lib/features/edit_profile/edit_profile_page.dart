import 'package:connect_hub/core/navigation/app_routes.dart';
import 'package:connect_hub/di/injection.dart';
import 'package:connect_hub/features/auth/bloc/auth_bloc.dart';
import 'package:connect_hub/features/auth/bloc/auth_state.dart';
import 'package:connect_hub/features/edit_profile/cubit/edit_profile_cubit.dart';
import 'package:connect_hub/features/edit_profile/edit_profile_view.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

/// Edit Profile's entry point, shown as a full-screen dialog (see
/// `EditProfileRoute`). It edits the session's user: the only profile anyone
/// may change is their own.
class EditProfilePage extends StatelessWidget {
  const EditProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final myId = context.select(
      (AuthBloc bloc) => switch (bloc.state) {
        AuthAuthenticated(:final session) => session.userId,
        _ => null,
      },
    );
    // Signing out: the router's gate is about to leave this screen.
    if (myId == null) return const Scaffold();

    return BlocProvider(
      key: ValueKey(myId),
      create: (_) => getIt<EditProfileCubit>(param1: myId)..load(),
      child: EditProfileView(onClose: () => _close(context)),
    );
  }

  /// As in Create Post: `pop()` closes the page even while a `PopScope` holds
  /// changes, so it is only called after saving or confirming the discard.
  /// Opened directly (a deep link), there is nothing underneath, so it goes
  /// to the Profile tab.
  static void _close(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      const ProfileRoute().go(context);
    }
  }
}
