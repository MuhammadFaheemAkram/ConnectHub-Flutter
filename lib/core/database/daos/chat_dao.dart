import 'package:connect_hub/core/database/app_database.dart';
import 'package:connect_hub/core/database/tables/conversations_table.dart';
import 'package:connect_hub/core/database/tables/messages_table.dart';
import 'package:connect_hub/core/database/tables/users_table.dart';
import 'package:drift/drift.dart';

part 'chat_dao.g.dart';

/// A cached conversation with the other person.
typedef CachedConversation = ({
  ConversationRow conversation,
  UserRow participant,
});

/// Cached conversations and their messages.
@DriftAccessor(tables: [Conversations, Messages, Users])
class ChatDao extends DatabaseAccessor<AppDatabase> with _$ChatDaoMixin {
  ChatDao(super.attachedDatabase);

  // ---------------------------------------------------------------------------
  // Conversations

  /// The conversations, the most recent activity first, each with the other
  /// person (JOINed, so a renamed person is renamed here too).
  Stream<List<CachedConversation>> watchConversations() {
    final query =
        select(conversations).join([
          innerJoin(users, users.id.equalsExp(conversations.participantId)),
        ])..orderBy([
          OrderingTerm.desc(conversations.updatedAt),
          OrderingTerm.asc(conversations.id),
        ]);
    return query.watch().map(
      (rows) => [for (final row in rows) _readConversation(row)],
    );
  }

  /// One conversation with the other person; `null` while it isn't cached.
  Stream<CachedConversation?> watchConversation(String conversationId) {
    final query = select(conversations).join([
      innerJoin(users, users.id.equalsExp(conversations.participantId)),
    ])..where(conversations.id.equals(conversationId));
    return query.watchSingleOrNull().map(
      (row) => row == null ? null : _readConversation(row),
    );
  }

  Future<bool> isCached(String conversationId) async =>
      await _find(conversationId) != null;

  /// Every conversation's unread count, added up: the Chats badge.
  Stream<int> watchUnreadCount() {
    final total = conversations.unreadCount.sum();
    final query = selectOnly(conversations)..addColumns([total]);
    return query.map((row) => row.read(total) ?? 0).watchSingle();
  }

  /// Mirrors the server's conversations (Correctness Rule 1): upserts what it
  /// returned, with the other people, and deletes the ones it no longer has
  /// (their messages go too, by cascade), in one transaction.
  Future<void> replaceConversations(List<CachedConversation> entries) {
    return batch((batch) {
      batch
        ..insertAllOnConflictUpdate(users, [
          for (final entry in entries) entry.participant,
        ])
        ..insertAllOnConflictUpdate(conversations, [
          for (final entry in entries) entry.conversation,
        ])
        ..deleteWhere(
          conversations,
          (conversation) => conversation.id.isNotIn([
            for (final entry in entries) entry.conversation.id,
          ]),
        );
    });
  }

  /// Sets a conversation's unread count (zero, when it is read). Returns the
  /// count from before, so a failed request can restore it, or `null` if the
  /// conversation isn't cached.
  Future<int?> setUnreadCount(String conversationId, int count) {
    return transaction(() async {
      final row = await _find(conversationId);
      if (row == null) return null;
      await (update(conversations)
            ..where((conversation) => conversation.id.equals(conversationId)))
          .write(ConversationsCompanion(unreadCount: Value(count)));
      return row.unreadCount;
    });
  }

  // ---------------------------------------------------------------------------
  // Messages

  /// A conversation's messages: the delivered ones in time order, then the
  /// ones still going out (or failed), in the order they were written.
  ///
  /// An unsent message's time is the device's guess, and the server's time
  /// for it will be later than every message the server already has. Keeping
  /// unsent messages at the end means a message never jumps when the server
  /// accepts it. Among themselves, they keep the order they were written in,
  /// which is also the order they are sent in, whatever the device's clock
  /// says.
  Stream<List<MessageRow>> watchMessages(String conversationId) {
    final isSent = messages.status.equalsValue(MessageRowStatus.sent);
    final query = select(messages)
      ..where((message) => message.conversationId.equals(conversationId))
      ..orderBy([
        (message) => OrderingTerm.asc(isSent.not()),
        // The time, for delivered messages only (NULL for the others).
        (message) => OrderingTerm.asc(
          CaseWhenExpression(
            cases: [CaseWhen(isSent, then: message.createdAt)],
          ),
        ),
        // SQLite's row id: the order rows were written.
        (message) => OrderingTerm.asc(message.rowId),
      ]);
    return query.watch();
  }

  /// Mirrors the server's messages in [conversationId] (Correctness Rules 1
  /// and 7): upserts what it returned, as sent, and deletes the delivered
  /// messages it no longer has. Messages still sending, or failed, are the
  /// user's words, not yet on the server, so they stay.
  ///
  /// A message the server already has while it is still "sending" here (its
  /// answer hasn't arrived) simply becomes sent: the ids match.
  Future<void> replaceMessages(
    String conversationId,
    List<MessageRow> delivered,
  ) {
    return transaction(() async {
      if (await _find(conversationId) == null) return;
      await batch((batch) {
        batch
          ..insertAllOnConflictUpdate(messages, delivered)
          ..deleteWhere(
            messages,
            (message) =>
                message.conversationId.equals(conversationId) &
                message.status.equalsValue(MessageRowStatus.sent) &
                message.id.isNotIn([for (final row in delivered) row.id]),
          );
      });
    });
  }

  /// Writes a message the user just sent, as `sending`, so it shows at once.
  /// Skipped if the conversation is no longer cached (a logout meanwhile).
  Future<void> insertPending(MessageRow message) {
    return transaction(() async {
      if (await _find(message.conversationId) == null) return;
      await into(messages).insertOnConflictUpdate(message);
    });
  }

  Future<MessageRow?> findMessage(String messageId) {
    final query = select(messages)
      ..where((message) => message.id.equals(messageId));
    return query.getSingleOrNull();
  }

  /// The server has accepted [sent]: the row becomes `sent`, with the
  /// server's time, and the conversation's last message (unless a newer one
  /// already is).
  Future<void> confirmSent(MessageRow sent) {
    return transaction(() async {
      final updated =
          await (update(
            messages,
          )..where((message) => message.id.equals(sent.id))).write(
            MessagesCompanion(
              status: const Value(MessageRowStatus.sent),
              createdAt: Value(sent.createdAt),
            ),
          );
      final conversation = await _find(sent.conversationId);
      if (updated == 0 ||
          conversation == null ||
          conversation.updatedAt.isAfter(sent.createdAt)) {
        return;
      }
      await (update(
        conversations,
      )..where((row) => row.id.equals(sent.conversationId))).write(
        ConversationsCompanion(
          lastMessage: Value(sent.content),
          updatedAt: Value(sent.createdAt),
        ),
      );
    });
  }

  /// The message didn't go through: it shows "Not sent · Tap to retry".
  Future<void> markFailed(String messageId) {
    final query = update(messages)
      ..where((message) => message.id.equals(messageId));
    return query.write(
      const MessagesCompanion(status: Value(MessageRowStatus.failed)),
    );
  }

  /// Puts a failed message back to `sending`, for a retry. Returns `false`,
  /// doing nothing, unless it had failed.
  Future<bool> markSending(String messageId) async {
    final query = update(messages)
      ..where(
        (message) =>
            message.id.equals(messageId) &
            message.status.equalsValue(MessageRowStatus.failed),
      );
    final updated = await query.write(
      const MessagesCompanion(status: Value(MessageRowStatus.sending)),
    );
    return updated > 0;
  }

  /// Caches a message from the realtime channel, with the conversation as it
  /// now stands (and the other person), in one transaction.
  Future<void> addIncoming({
    required MessageRow message,
    required CachedConversation conversation,
  }) {
    return transaction(() async {
      await into(users).insertOnConflictUpdate(conversation.participant);
      await into(conversations)
          .insertOnConflictUpdate(conversation.conversation);
      await into(messages).insertOnConflictUpdate(message);
    });
  }

  Future<ConversationRow?> _find(String conversationId) {
    final query = select(conversations)
      ..where((conversation) => conversation.id.equals(conversationId));
    return query.getSingleOrNull();
  }

  CachedConversation _readConversation(TypedResult row) => (
    conversation: row.readTable(conversations),
    participant: row.readTable(users),
  );
}
