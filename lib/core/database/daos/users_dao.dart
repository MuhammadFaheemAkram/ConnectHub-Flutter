import 'package:connect_hub/core/database/app_database.dart';
import 'package:connect_hub/core/database/tables/users_table.dart';
import 'package:drift/drift.dart';

part 'users_dao.g.dart';

/// Cached profiles, one at a time: what the Profile screens read and write.
@DriftAccessor(tables: [Users])
class UsersDao extends DatabaseAccessor<AppDatabase> with _$UsersDaoMixin {
  UsersDao(super.attachedDatabase);

  /// One cached profile, emitted again whenever it changes; `null` while it
  /// isn't cached.
  Stream<UserRow?> watchUser(String userId) => (select(
    users,
  )..where((user) => user.id.equals(userId))).watchSingleOrNull();

  /// Saves a profile as the server returned it.
  ///
  /// Posts and comments JOIN this row for their author, so one upsert renames
  /// the author on every cached post and comment at once. An upsert, never
  /// `REPLACE`: the row is referenced from posts and comments.
  Future<void> upsertUser(UserRow user) =>
      into(users).insertOnConflictUpdate(user);
}
