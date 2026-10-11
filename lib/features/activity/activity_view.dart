import 'package:connect_hub/core/design_system/design_system.dart';
import 'package:connect_hub/domain/model/app_notification.dart';
import 'package:connect_hub/features/activity/cubit/activity_cubit.dart';
import 'package:connect_hub/features/activity/cubit/activity_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';

/// The Activity tab: notifications, newest first, with filter chips, pull to
/// refresh and "Mark all read". Tapping a row marks it read and opens what
/// it links to.
class ActivityView extends StatelessWidget {
  const ActivityView({
    super.key,
    required this.onOpenPost,
    required this.onOpenProfile,
  });

  /// Called with the post's id.
  final ValueChanged<String> onOpenPost;

  /// Called with the user's id.
  final ValueChanged<String> onOpenProfile;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ActivityCubit>();
    final hasUnread = context.select(
      (ActivityCubit cubit) => cubit.state.hasUnread,
    );
    return Scaffold(
      appBar: AppBar(
        title: const Text('Activity'),
        actions: [
          TextButton(
            onPressed: hasUnread ? cubit.markAllRead : null,
            child: const Text('Mark all read'),
          ),
        ],
      ),
      body: BlocConsumer<ActivityCubit, ActivityState>(
        listenWhen: (previous, current) =>
            current.message != null && current.message != previous.message,
        listener: (context, state) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(content: Text(state.message!.text)));
        },
        builder: (context, state) => Column(
          children: [
            _FilterChips(
              selected: state.filter,
              onSelected: cubit.selectFilter,
            ),
            Expanded(
              child: switch (state.status) {
                ActivityStatus.loading => const LoadingView(
                  message: 'Loading activity…',
                ),
                ActivityStatus.failure => ErrorView(
                  message: state.errorMessage,
                  onRetry: cubit.load,
                ),
                ActivityStatus.loaded => RefreshIndicator(
                  onRefresh: cubit.refresh,
                  child: state.visible.isEmpty
                      ? _NoActivity(filtered: state.notifications.isNotEmpty)
                      : ListView.separated(
                          physics: const AlwaysScrollableScrollPhysics(),
                          itemCount: state.visible.length,
                          separatorBuilder: (_, _) => const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final notification = state.visible[index];
                            return NotificationTile(
                              key: ValueKey(notification.id),
                              notification: notification,
                              onTap: () => _open(cubit, notification),
                            );
                          },
                        ),
                ),
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Marks the row read and opens its post or profile, if it links to one.
  /// The page opens at once; marking read finishes in the background.
  void _open(ActivityCubit cubit, AppNotification notification) {
    cubit.markRead(notification).ignore();
    if (notification.postId case final postId?) {
      onOpenPost(postId);
    } else if (notification.userId case final userId?) {
      onOpenProfile(userId);
    }
  }
}

class _FilterChips extends StatelessWidget {
  const _FilterChips({required this.selected, required this.onSelected});

  final ActivityFilter selected;
  final ValueChanged<ActivityFilter> onSelected;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.medium,
        vertical: AppSpacing.xSmall,
      ),
      child: Row(
        children: [
          for (final filter in ActivityFilter.values)
            Padding(
              padding: const EdgeInsetsDirectional.only(end: AppSpacing.xSmall),
              child: FilterChip(
                label: Text(filter.label),
                selected: filter == selected,
                onSelected: (_) => onSelected(filter),
              ),
            ),
        ],
      ),
    );
  }
}

/// "No activity yet", or nothing for the chosen filter; still pullable to
/// refresh.
class _NoActivity extends StatelessWidget {
  const _NoActivity({required this.filtered});

  final bool filtered;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(
            height: constraints.maxHeight,
            child: filtered
                ? const EmptyStateView(
                    icon: Icons.filter_list_off,
                    title: 'No matches',
                    message: 'Nothing here for this filter.',
                  )
                : const EmptyStateView(
                    icon: Icons.notifications_none,
                    title: 'No activity yet',
                    message:
                        'Likes, comments, follows and mentions will show '
                        'up here.',
                  ),
          ),
        ],
      ),
    );
  }
}
