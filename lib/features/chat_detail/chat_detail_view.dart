import 'dart:collection';

import 'package:connect_hub/core/common/validators.dart';
import 'package:connect_hub/core/design_system/design_system.dart';
import 'package:connect_hub/core/navigation/back_to_feed_button.dart';
import 'package:connect_hub/domain/model/message.dart';
import 'package:connect_hub/domain/model/user.dart';
import 'package:connect_hub/features/chat_detail/cubit/chat_detail_cubit.dart';
import 'package:connect_hub/features/chat_detail/cubit/chat_detail_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';

/// One chat: bubbles, the typing indicator and the composer.
///
/// The list is `reverse`d, the usual shape for a chat: it starts at the
/// newest message (the bottom) with no initial scroll, and the newest
/// message stays in view as the keyboard opens. When a message arrives, mine
/// or theirs, the list scrolls back to it once: a one-time effect, keyed on
/// the newest message's id.
///
/// Stateful for what the UI owns: the composer's text and the scroll
/// position.
class ChatDetailView extends StatefulWidget {
  const ChatDetailView({super.key, required this.onOpenProfile});

  /// Called with the participant's user id (the title).
  final ValueChanged<String> onOpenProfile;

  @override
  State<ChatDetailView> createState() => _ChatDetailViewState();
}

class _ChatDetailViewState extends State<ChatDetailView> {
  final _input = TextEditingController();
  final _scroll = ScrollController();

  @override
  void dispose() {
    _input.dispose();
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ChatDetailCubit>();
    return Scaffold(
      appBar: AppBar(
        leading: const BackToFeedButton(),
        titleSpacing: 0,
        title: BlocSelector<ChatDetailCubit, ChatDetailState, User?>(
          selector: (state) => state.participant,
          builder: (context, participant) => participant == null
              ? const Text('Chat')
              : _ParticipantTitle(
                  participant: participant,
                  onTap: () => widget.onOpenProfile(participant.id),
                ),
        ),
      ),
      body: MultiBlocListener(
        listeners: [
          BlocListener<ChatDetailCubit, ChatDetailState>(
            listenWhen: (previous, current) =>
                current.message != null && current.message != previous.message,
            listener: (context, state) {
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(SnackBar(content: Text(state.message!.text)));
            },
          ),
          BlocListener<ChatDetailCubit, ChatDetailState>(
            listenWhen: (previous, current) =>
                previous.messages.lastOrNull?.id !=
                current.messages.lastOrNull?.id,
            listener: (context, _) => _scrollToNewest(),
          ),
        ],
        child: BlocBuilder<ChatDetailCubit, ChatDetailState>(
          builder: (context, state) => switch (state.status) {
            ChatStatus.loading => const LoadingView(
              message: 'Loading messages…',
            ),
            ChatStatus.failure => ErrorView(
              message: state.errorMessage,
              onRetry: cubit.load,
            ),
            ChatStatus.notFound => const EmptyStateView(
              icon: Icons.speaker_notes_off_outlined,
              title: "This conversation isn't available.",
            ),
            ChatStatus.ready => Column(
              children: [
                Expanded(
                  child: state.messages.isEmpty && !state.isTyping
                      ? EmptyStateView(
                          icon: Icons.waving_hand_outlined,
                          title: 'Say hello 👋',
                          message: switch (state.participant) {
                            final participant? =>
                              'Send ${participant.name} your first message.',
                            null => null,
                          },
                        )
                      : _MessageList(
                          controller: _scroll,
                          messages: state.messages,
                          isTyping: state.isTyping,
                          onRetry: cubit.retry,
                        ),
                ),
                ComposerBar(
                  controller: _input,
                  onSend: _send,
                  hintText: 'Message…',
                  maxLength: Validators.messageMaxLength,
                ),
              ],
            ),
          },
        ),
      ),
    );
  }

  /// The message shows at once ("Sending…"), so the field clears at once;
  /// if sending fails, the bubble says so and offers a retry.
  void _send(String text) {
    context.read<ChatDetailCubit>().send(text).ignore();
    _input.clear();
  }

  /// Brings the newest message into view, unless it already is.
  void _scrollToNewest() {
    if (!_scroll.hasClients || _scroll.offset <= 0) return;
    if (MediaQuery.disableAnimationsOf(context)) {
      _scroll.jumpTo(0);
    } else {
      _scroll
          .animateTo(
            0,
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut,
          )
          .ignore();
    }
  }
}

/// The participant's avatar and name; tapping opens their profile.
class _ParticipantTitle extends StatelessWidget {
  const _ParticipantTitle({required this.participant, required this.onTap});

  final User participant;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      hint: 'Opens their profile',
      child: InkWell(
        onTap: onTap,
        borderRadius: const BorderRadius.all(Radius.circular(AppRadius.small)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 48),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xSmall),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ExcludeSemantics(
                  child: UserAvatar(
                    name: participant.name,
                    url: participant.avatarUrl,
                    size: 32,
                  ),
                ),
                const SizedBox(width: AppSpacing.small),
                Flexible(
                  child: Text(
                    participant.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// The bubbles, newest at the bottom, and the typing indicator below them.
class _MessageList extends StatelessWidget {
  const _MessageList({
    required this.controller,
    required this.messages,
    required this.isTyping,
    required this.onRetry,
  });

  final ScrollController controller;

  /// Oldest first.
  final List<Message> messages;
  final bool isTyping;
  final ValueChanged<Message> onRetry;

  @override
  Widget build(BuildContext context) {
    // Reversed: index 0 is the bottom of the screen.
    final typingSlots = isTyping ? 1 : 0;
    return ListView.builder(
      controller: controller,
      reverse: true,
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.small),
      itemCount: messages.length + typingSlots,
      itemBuilder: (context, index) {
        if (index < typingSlots) {
          return const Padding(
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.medium,
              vertical: AppSpacing.xxSmall,
            ),
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: TypingIndicator(),
            ),
          );
        }
        final message = messages[messages.length - 1 - (index - typingSlots)];
        return MessageBubble(
          key: ValueKey(message.id),
          message: message,
          onRetry: message.status == MessageStatus.failed
              ? () => onRetry(message)
              : null,
        );
      },
    );
  }
}
