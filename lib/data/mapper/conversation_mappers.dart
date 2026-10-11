import 'package:connect_hub/core/database/app_database.dart';
import 'package:connect_hub/core/database/daos/chat_dao.dart';
import 'package:connect_hub/core/network/dto/conversation_dto.dart';
import 'package:connect_hub/data/mapper/user_mappers.dart';
import 'package:connect_hub/domain/model/conversation.dart';

extension ConversationDtoMapper on ConversationDto {
  /// The conversation split into the rows it is cached as.
  CachedConversation toCached() => (
    conversation: ConversationRow(
      id: id,
      participantId: participant.id,
      lastMessage: lastMessage,
      unreadCount: unreadCount,
      updatedAt: updatedAt.toUtc(),
    ),
    participant: participant.toRow(),
  );
}

extension CachedConversationMapper on CachedConversation {
  Conversation toDomain() => Conversation(
    id: conversation.id,
    participant: participant.toDomain(),
    lastMessage: conversation.lastMessage,
    unreadCount: conversation.unreadCount,
    updatedAt: conversation.updatedAt,
  );
}
