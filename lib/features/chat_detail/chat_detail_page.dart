import 'package:connect_hub/core/navigation/app_routes.dart';
import 'package:connect_hub/di/injection.dart';
import 'package:connect_hub/features/chat_detail/chat_detail_view.dart';
import 'package:connect_hub/features/chat_detail/cubit/chat_detail_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';

/// A chat's entry point: creates its [ChatDetailCubit] (the conversation id
/// is a factory parameter) and opens the participant's profile from the
/// title.
class ChatDetailPage extends StatelessWidget {
  const ChatDetailPage({super.key, required this.conversationId});

  final String conversationId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<ChatDetailCubit>(param1: conversationId)..load(),
      child: ChatDetailView(
        onOpenProfile: (userId) => openProfile(context, userId),
      ),
    );
  }
}
