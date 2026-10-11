import 'package:connect_hub/core/database/tables/users_table.dart';
import 'package:drift/drift.dart';

/// Cached conversations (schema v4, Phase 6), each with the other person
/// (JOINed from `users`, like post authors).
@DataClassName('ConversationRow')
class Conversations extends Table {
  TextColumn get id => text()();

  TextColumn get participantId => text().references(Users, #id)();

  TextColumn get lastMessage => text()();

  /// Replies the user hasn't read. The server's number; the client only sets
  /// it to zero when the conversation is read.
  IntColumn get unreadCount => integer()();

  /// UTC: the time of the last message. The list shows the most recent
  /// first.
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
