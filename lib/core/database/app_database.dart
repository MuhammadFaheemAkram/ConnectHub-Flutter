import 'package:connect_hub/core/database/app_database.steps.dart';
import 'package:connect_hub/core/database/daos/bookmarks_dao.dart';
import 'package:connect_hub/core/database/daos/cache_dao.dart';
import 'package:connect_hub/core/database/daos/comments_dao.dart';
import 'package:connect_hub/core/database/daos/feed_dao.dart';
import 'package:connect_hub/core/database/daos/posts_dao.dart';
import 'package:connect_hub/core/database/daos/search_dao.dart';
import 'package:connect_hub/core/database/daos/users_dao.dart';
import 'package:connect_hub/core/database/tables/bookmarks_table.dart';
import 'package:connect_hub/core/database/tables/comments_table.dart';
import 'package:connect_hub/core/database/tables/feed_items_table.dart';
import 'package:connect_hub/core/database/tables/posts_table.dart';
import 'package:connect_hub/core/database/tables/recent_searches_table.dart';
import 'package:connect_hub/core/database/tables/users_table.dart';
import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'app_database.g.dart';

/// The app's SQLite database: the local cache every screen reads from.
///
/// The server owns the data; this is the client's copy of it. Screens render
/// only what drift emits, and repositories refresh drift from the API, so
/// cached data shows at once and offline (the offline-first rule).
///
/// This file and the rest of `core/database/` never import `material_ui` or
/// the JSON packages: drift exports `Table`, `Column` and `JsonKey`, and
/// those names would clash (conventions §11.1).
@DriftDatabase(
  tables: [Users, Posts, FeedItems, Bookmarks, Comments, RecentSearches],
  daos: [
    PostsDao,
    FeedDao,
    CommentsDao,
    UsersDao,
    BookmarksDao,
    SearchDao,
    CacheDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  /// Opens `connect_hub.sqlite` in the app's documents directory. Tests pass
  /// an in-memory [executor] instead.
  AppDatabase([QueryExecutor? executor])
    : super(executor ?? driftDatabase(name: 'connect_hub'));

  /// Each phase is treated as a release: a phase that changes the schema
  /// bumps this, exports the new version (`drift_dev make-migrations`) and
  /// ships a tested migration.
  ///
  /// 1. Phase 3: users, posts, feed_items, bookmarks.
  /// 2. Phase 4: comments.
  /// 3. Phase 5: recent_searches.
  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    // A fresh install creates the latest schema directly (`createAll`). An
    // update walks one version at a time: `stepByStep` comes from the
    // generated `app_database.steps.dart`, and each step only sees the
    // tables as they were at that version (`schema`), so an old step keeps
    // working however later versions change the tables.
    onUpgrade: stepByStep(
      from1To2: (m, schema) async {
        await m.createTable(schema.comments);
      },
      from2To3: (m, schema) async {
        await m.createTable(schema.recentSearches);
      },
    ),
    // SQLite ships with foreign keys *off*, per connection. Without this
    // pragma, every REFERENCES and ON DELETE CASCADE would be ignored.
    beforeOpen: (details) => customStatement('PRAGMA foreign_keys = ON'),
  );
}
