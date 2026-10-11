import 'package:connect_hub/core/common/compact_count.dart';
import 'package:connect_hub/core/common/ui_message.dart';
import 'package:connect_hub/core/design_system/design_system.dart';
import 'package:connect_hub/core/navigation/back_to_feed_button.dart';
import 'package:connect_hub/domain/model/post.dart';
import 'package:connect_hub/domain/model/user.dart';
import 'package:connect_hub/features/profile/cubit/profile_cubit.dart';
import 'package:connect_hub/features/profile/cubit/profile_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';

/// A profile: the header (picture, name, bio, counts), then the user's
/// posts.
///
/// [isMine] decides the extras. My profile is a tab root with a Settings
/// gear, "Edit profile" and "Log out"; anyone else's is a read-only screen
/// pushed over the tabs, with a Back button.
class ProfileView extends StatelessWidget {
  const ProfileView({
    super.key,
    required this.isMine,
    required this.onOpenPost,
    required this.onOpenComments,
    this.onEditProfile,
    this.onOpenSettings,
    this.onLogout,
  });

  final bool isMine;

  /// Called with the post's id.
  final ValueChanged<String> onOpenPost;

  /// Called with the post's id.
  final ValueChanged<String> onOpenComments;

  final VoidCallback? onEditProfile;
  final VoidCallback? onOpenSettings;

  /// Called once the user has confirmed.
  final VoidCallback? onLogout;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ProfileCubit>();
    return Scaffold(
      appBar: AppBar(
        leading: isMine ? null : const BackToFeedButton(),
        title: const Text('Profile'),
        actions: [
          if (isMine)
            IconButton(
              tooltip: 'Settings',
              icon: const Icon(Icons.settings_outlined),
              onPressed: onOpenSettings,
            ),
        ],
      ),
      body: BlocConsumer<ProfileCubit, ProfileState>(
        listenWhen: (previous, current) =>
            _messageOf(current) != null &&
            _messageOf(current) != _messageOf(previous),
        listener: (context, state) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(content: Text(_messageOf(state)!.text)));
        },
        builder: (context, state) => switch (state) {
          ProfileLoading() => const LoadingView(message: 'Loading profile…'),
          ProfileError(:final message) => ErrorView(
            message: message,
            onRetry: cubit.load,
          ),
          ProfileNotFound() => const EmptyStateView(
            icon: Icons.person_off_outlined,
            title: "This profile isn't available.",
          ),
          ProfileLoaded() => RefreshIndicator(
            onRefresh: cubit.refresh,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.only(bottom: AppSpacing.large),
              children: [
                _ProfileHeader(
                  user: state.user,
                  postCount: state.posts.length,
                  actions: isMine
                      ? _MyProfileActions(
                          onEditProfile: onEditProfile,
                          onLogout: () => _confirmLogout(context),
                        )
                      : null,
                ),
                const Divider(height: AppSpacing.large),
                ..._posts(state, cubit),
              ],
            ),
          ),
        },
      ),
    );
  }

  List<Widget> _posts(ProfileLoaded state, ProfileCubit cubit) {
    if (state.isLoadingPosts) {
      return const [
        Padding(
          padding: EdgeInsets.all(AppSpacing.large),
          child: Center(
            child: CircularProgressIndicator(semanticsLabel: 'Loading posts'),
          ),
        ),
      ];
    }
    if (state.posts.isEmpty) {
      return [_QuietText(isMine ? "You haven't posted yet." : 'No posts yet.')];
    }
    return [
      for (final post in state.posts)
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.medium,
            0,
            AppSpacing.medium,
            AppSpacing.small,
          ),
          child: _postCard(post, cubit),
        ),
    ];
  }

  // No author tap: this is the author's profile already.
  Widget _postCard(Post post, ProfileCubit cubit) => PostCard(
    key: ValueKey(post.id),
    post: post,
    onTap: () => onOpenPost(post.id),
    onLike: () => cubit.toggleLike(post),
    onComment: () => onOpenComments(post.id),
    onBookmark: () => cubit.toggleBookmark(post),
  );

  /// Logging out goes through the `AuthBloc` (the page wires [onLogout]).
  /// The router's gate then returns to Login on its own.
  Future<void> _confirmLogout(BuildContext context) async {
    final confirmed = await showConfirmationDialog(
      context,
      title: 'Log out?',
      message: "You'll need to sign in again to use ConnectHub.",
      confirmLabel: 'Log out',
    );
    if (confirmed) onLogout?.call();
  }

  static UiMessage? _messageOf(ProfileState state) => switch (state) {
    ProfileLoaded(:final message) => message,
    _ => null,
  };
}

/// The picture, name, bio and the three counts, then [actions] if any.
class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({
    required this.user,
    required this.postCount,
    this.actions,
  });

  final User user;
  final int postCount;
  final Widget? actions;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final actions = this.actions;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.medium,
        AppSpacing.medium,
        AppSpacing.medium,
        0,
      ),
      child: Column(
        children: [
          UserAvatar(name: user.name, url: user.avatarUrl, size: 96),
          const SizedBox(height: AppSpacing.small),
          Text(
            user.name,
            style: theme.textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          if (user.bio.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.xxSmall),
            Text(
              user.bio,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
          const SizedBox(height: AppSpacing.medium),
          Row(
            children: [
              _Count(label: 'Followers', count: user.followersCount),
              _Count(label: 'Following', count: user.followingCount),
              _Count(label: 'Posts', count: postCount),
            ],
          ),
          if (actions != null) ...[
            const SizedBox(height: AppSpacing.medium),
            actions,
          ],
        ],
      ),
    );
  }
}

/// "4.8K" over "Followers", read out as one phrase.
class _Count extends StatelessWidget {
  const _Count({required this.label, required this.count});

  final String label;
  final int count;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final value = compactCount(count);
    return Expanded(
      child: Semantics(
        // Its own node, so each count is read (and focused) on its own.
        container: true,
        label: '$value $label',
        excludeSemantics: true,
        child: Column(
          children: [
            Text(value, style: theme.textTheme.titleMedium),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MyProfileActions extends StatelessWidget {
  const _MyProfileActions({
    required this.onEditProfile,
    required this.onLogout,
  });

  final VoidCallback? onEditProfile;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: FilledButton.tonal(
            onPressed: onEditProfile,
            child: const Text('Edit profile'),
          ),
        ),
        const SizedBox(width: AppSpacing.small),
        Expanded(
          child: OutlinedButton(
            onPressed: onLogout,
            child: const Text('Log out'),
          ),
        ),
      ],
    );
  }
}

class _QuietText extends StatelessWidget {
  const _QuietText(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.large),
      child: Text(
        text,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
