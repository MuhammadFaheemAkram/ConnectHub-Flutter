import 'package:connect_hub/core/database/app_database.dart';
import 'package:connect_hub/core/database/tables/messages_table.dart';
import 'package:connect_hub/core/network/dto/message_dto.dart';
import 'package:connect_hub/domain/model/message.dart';

extension MessageDtoMapper on MessageDto {
  /// A message from the server: delivered, by definition.
  MessageRow toRow() => MessageRow(
    id: id,
    conversationId: conversationId,
    senderId: senderId,
    content: text,
    createdAt: createdAt.toUtc(),
    status: MessageRowStatus.sent,
  );
}

extension MessageRowMapper on MessageRow {
  /// [signedInUserId] decides [Message.isMine]: one identity, from the
  /// session, drives it everywhere (Correctness Rule 2).
  Message toDomain({required String? signedInUserId}) => Message(
    id: id,
    conversationId: conversationId,
    senderId: senderId,
    text: content,
    createdAt: createdAt,
    isMine: senderId == signedInUserId,
    status: switch (status) {
      MessageRowStatus.sending => MessageStatus.sending,
      MessageRowStatus.sent => MessageStatus.sent,
      MessageRowStatus.failed => MessageStatus.failed,
    },
  );
}
