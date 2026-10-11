import 'package:connect_hub/core/database/tables/conversations_table.dart';
import 'package:drift/drift.dart';

/// Where a message stands. Only `sent` messages are the server's; the other
/// two exist on this device only, until the server accepts them.
enum MessageRowStatus { sending, sent, failed }

/// Cached chat messages (schema v4, Phase 6).
///
/// - `ON DELETE CASCADE` on the conversation: messages go with it.
/// - A refresh mirrors the server's messages but never touches `sending` or
///   `failed` ones: they are the user's words, not yet on the server
///   (Correctness Rule 7).
/// - The user's own messages keep the id the client generated, so a retry
///   can't create a second copy on the server.
@DataClassName('MessageRow')
class Messages extends Table {
  TextColumn get id => text()();

  TextColumn get conversationId =>
      text().references(Conversations, #id, onDelete: KeyAction.cascade)();

  /// The signed-in user or the other person; not a reference, because a
  /// message never needs its sender's row.
  TextColumn get senderId => text()();

  /// The message's text. (A column named `text` would hide drift's `text()`
  /// column builder inside this class.)
  TextColumn get content => text()();

  /// UTC: the server's time once sent; the device's while sending.
  DateTimeColumn get createdAt => dateTime()();

  /// Stored as the enum's name.
  TextColumn get status => textEnum<MessageRowStatus>()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
