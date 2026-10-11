import 'package:connect_hub/core/navigation/app_routes.dart';
import 'package:connect_hub/di/injection.dart';
import 'package:connect_hub/features/auth/bloc/auth_bloc.dart';
import 'package:connect_hub/features/auth/bloc/auth_event.dart';
import 'package:connect_hub/features/auth/bloc/auth_state.dart';
import 'package:connect_hub/features/profile/cubit/profile_cubit.dart';
import 'package:connect_hub/features/profile/profile_view.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';

/// A profile's entry point.
///
/// One page serves both cases: `userId == null` is the signed-in user's own
/// profile (the Profile tab), any other id is someone else's (`/users/:id`).
/// "Me" is the session's user, the same identity the router's gate and every
/// `isMine` use (Correctness Rule 2).
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key, this.userId});

  final String? userId;

  @override
  Widget build(BuildContext context) {
    final myId = context.select(
      (AuthBloc bloc) => switch (bloc.state) {
        AuthAuthenticated(:final session) => session.userId,
        _ => null,
      },
    );
    final userId = this.userId ?? myId;
    // Signing out: the router's gate is about to leave this screen.
    if (userId == null) return const Scaffold();

    return BlocProvider(
      // A different user is a different Cubit.
      key: ValueKey(userId),
      create: (_) => getIt<ProfileCubit>(param1: userId)..load(),
      child: ProfileView(
        isMine: userId == myId,
        onOpenPost: (postId) =>
            PostDetailRoute(postId: postId).push<void>(context),
        onOpenComments: (postId) =>
            CommentsRoute(postId: postId).push<void>(context),
        onEditProfile: () => const EditProfileRoute().push<void>(context),
        onOpenSettings: () => const SettingsRoute().push<void>(context),
        onLogout: () =>
            context.read<AuthBloc>().add(const AuthLogoutRequested()),
      ),
    );
  }
}
