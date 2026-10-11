import 'package:clock/clock.dart';
import 'package:connect_hub/core/database/app_database.dart';
import 'package:connect_hub/core/database/daos/bookmarks_dao.dart';
import 'package:connect_hub/core/database/daos/cache_dao.dart';
import 'package:connect_hub/core/database/daos/chat_dao.dart';
import 'package:connect_hub/core/database/daos/comments_dao.dart';
import 'package:connect_hub/core/database/daos/feed_dao.dart';
import 'package:connect_hub/core/database/daos/notifications_dao.dart';
import 'package:connect_hub/core/database/daos/posts_dao.dart';
import 'package:connect_hub/core/database/daos/search_dao.dart';
import 'package:connect_hub/core/database/daos/users_dao.dart';
import 'package:connect_hub/core/storage/settings_local_data_source.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Registers types the app doesn't own, so they can be injected (and replaced
/// in tests) like everything else.
@module
abstract class AppModule {
  /// The asset bundle the fake server reads its seed JSON from.
  @lazySingleton
  AssetBundle get assetBundle => rootBundle;

  /// Keychain on iOS, Keystore-backed storage on Android.
  @lazySingleton
  FlutterSecureStorage get secureStorage => const FlutterSecureStorage();

  /// The current time, injected so tests can fix it (`Clock.fixed`).
  @lazySingleton
  Clock get clock => const Clock();

  /// One database for the whole app. Several connections to the same SQLite
  /// file would break drift's change notifications.
  @lazySingleton
  AppDatabase get appDatabase => AppDatabase();

  @lazySingleton
  PostsDao postsDao(AppDatabase database) => database.postsDao;

  @lazySingleton
  FeedDao feedDao(AppDatabase database) => database.feedDao;

  @lazySingleton
  CommentsDao commentsDao(AppDatabase database) => database.commentsDao;

  @lazySingleton
  UsersDao usersDao(AppDatabase database) => database.usersDao;

  @lazySingleton
  BookmarksDao bookmarksDao(AppDatabase database) => database.bookmarksDao;

  @lazySingleton
  SearchDao searchDao(AppDatabase database) => database.searchDao;

  @lazySingleton
  ChatDao chatDao(AppDatabase database) => database.chatDao;

  @lazySingleton
  NotificationsDao notificationsDao(AppDatabase database) =>
      database.notificationsDao;

  @lazySingleton
  CacheDao cacheDao(AppDatabase database) => database.cacheDao;

  /// `@preResolve` awaits this before `runApp`, so preferences can be read
  /// synchronously from the first frame: a saved dark theme never flashes
  /// light (Correctness Rule 13).
  @preResolve
  @lazySingleton
  Future<SharedPreferencesWithCache> get preferences =>
      SharedPreferencesWithCache.create(
        cacheOptions: const SharedPreferencesWithCacheOptions(
          allowList: SettingsLocalDataSource.allowList,
        ),
      );

  /// App name, version and build number, for Settings → About.
  @preResolve
  @lazySingleton
  Future<PackageInfo> get packageInfo => PackageInfo.fromPlatform();
}
