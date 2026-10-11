import 'package:connect_hub/core/design_system/design_system.dart';
import 'package:connect_hub/core/navigation/back_to_feed_button.dart';
import 'package:connect_hub/features/chats/cubit/chats_cubit.dart';
import 'package:connect_hub/features/chats/cubit/chats_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';

/// The conversation list, the most recent activity first, with a search
/// field that filters it as you type.
///
/// Stateful only for the search field's controller (its Clear button).
class ChatsView extends StatefulWidget {
  const ChatsView({super.key, required this.onOpenChat});

  /// Called with the conversation's id.
  final ValueChanged<String> onOpenChat;

  @override
  State<ChatsView> createState() => _ChatsViewState();
}

class _ChatsViewState extends State<ChatsView> {
  final _query = TextEditingController();

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ChatsCubit>();
    return Scaffold(
      appBar: AppBar(
        leading: const BackToFeedButton(),
        title: const Text('Chats'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.medium,
              AppSpacing.xSmall,
              AppSpacing.medium,
              AppSpacing.small,
            ),
            child: ValueListenableBuilder(
              valueListenable: _query,
              builder: (context, value, _) => SearchBar(
                controller: _query,
                hintText: 'Search chats',
                leading: const Icon(Icons.search),
                trailing: [
                  if (value.text.isNotEmpty)
                    IconButton(
                      tooltip: 'Clear search',
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        _query.clear();
                        cubit.search('');
                      },
                    ),
                ],
                onChanged: cubit.search,
              ),
            ),
          ),
          Expanded(
            child: BlocConsumer<ChatsCubit, ChatsState>(
              listenWhen: (previous, current) =>
                  current.message != null &&
                  current.message != previous.message,
              listener: (context, state) {
                ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(SnackBar(content: Text(state.message!.text)));
              },
              builder: (context, state) => switch (state.status) {
                ChatsStatus.loading => const LoadingView(
                  message: 'Loading chats…',
                ),
                ChatsStatus.failure => ErrorView(
                  message: state.errorMessage,
                  onRetry: cubit.load,
                ),
                ChatsStatus.loaded => RefreshIndicator(
                  onRefresh: cubit.refresh,
                  child: _ConversationList(
                    state: state,
                    onOpenChat: widget.onOpenChat,
                  ),
                ),
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ConversationList extends StatelessWidget {
  const _ConversationList({required this.state, required this.onOpenChat});

  final ChatsState state;
  final ValueChanged<String> onOpenChat;

  @override
  Widget build(BuildContext context) {
    final visible = state.visible;
    if (visible.isEmpty) {
      return LayoutBuilder(
        builder: (context, constraints) => ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(
              height: constraints.maxHeight,
              child: state.conversations.isEmpty
                  ? const EmptyStateView(
                      icon: Icons.forum_outlined,
                      title: 'No conversations',
                      message: 'Your chats will show up here.',
                    )
                  : EmptyStateView(
                      icon: Icons.search_off,
                      title: 'No matches',
                      message: 'No chats match “${state.query.trim()}”.',
                    ),
            ),
          ],
        ),
      );
    }
    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: visible.length,
      itemBuilder: (context, index) {
        final conversation = visible[index];
        return ConversationTile(
          key: ValueKey(conversation.id),
          conversation: conversation,
          onTap: () => onOpenChat(conversation.id),
        );
      },
    );
  }
}
