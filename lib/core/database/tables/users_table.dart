import 'package:drift/drift.dart';

/// Cached profiles: post authors now, and later comment authors, chat
/// participants and search results.
///
/// Posts reference their author by id and every read JOINs this table, so
/// one profile edit renames the author on every cached post at once.
@DataClassName('UserRow')
class Users extends Table {
  TextColumn get id => text()();

  TextColumn get name => text()();

  TextColumn get avatarUrl => text().nullable()();

  TextColumn get bio => text()();

  IntColumn get followersCount => integer()();

  IntColumn get followingCount => integer()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
