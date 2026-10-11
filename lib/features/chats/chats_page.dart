import 'package:connect_hub/core/navigation/app_routes.dart';
import 'package:connect_hub/di/injection.dart';
import 'package:connect_hub/features/chats/chats_view.dart';
import 'package:connect_hub/features/chats/cubit/chats_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';

/// The Chats list's entry point: creates the [ChatsCubit], starts the first
/// load, and opens a chat on top (`/chats/:conversationId`).
class ChatsPage extends StatelessWidget {
  const ChatsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<ChatsCubit>()..load(),
      child: ChatsView(
        onOpenChat: (conversationId) =>
            ChatRoute(conversationId: conversationId).push<void>(context),
      ),
    );
  }
}
