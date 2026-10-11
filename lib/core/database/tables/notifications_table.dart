import 'package:drift/drift.dart';

/// What a notification is about. Stored as the enum's name.
enum NotificationRowKind { like, comment, follow, mention }

/// Cached activity notifications (schema v4, Phase 6).
///
/// The read state is the server's: a refresh mirrors it, and marking a
/// notification read here is an optimistic write the server confirms
/// (Correctness Rule 10).
@DataClassName('NotificationRow')
class Notifications extends Table {
  TextColumn get id => text()();

  TextColumn get kind => textEnum<NotificationRowKind>()();

  /// The notification's text. (A column named `text` would hide drift's
  /// `text()` column builder.)
  TextColumn get content => text()();

  /// UTC. The list shows the newest first.
  DateTimeColumn get createdAt => dateTime()();

  BoolColumn get isRead => boolean()();

  /// What tapping it opens, if anything: a post or a profile. Not references:
  /// they may point at something that isn't cached (yet).
  TextColumn get postId => text().nullable()();

  TextColumn get userId => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
