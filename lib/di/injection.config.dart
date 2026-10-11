// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'package:clock/clock.dart' as _i454;
import 'package:connect_hub/core/common/id_generator.dart' as _i613;
import 'package:connect_hub/core/database/app_database.dart' as _i131;
import 'package:connect_hub/core/database/daos/bookmarks_dao.dart' as _i193;
import 'package:connect_hub/core/database/daos/cache_dao.dart' as _i423;
import 'package:connect_hub/core/database/daos/chat_dao.dart' as _i676;
import 'package:connect_hub/core/database/daos/comments_dao.dart' as _i99;
import 'package:connect_hub/core/database/daos/feed_dao.dart' as _i324;
import 'package:connect_hub/core/database/daos/notifications_dao.dart' as _i325;
import 'package:connect_hub/core/database/daos/posts_dao.dart' as _i355;
import 'package:connect_hub/core/database/daos/search_dao.dart' as _i146;
import 'package:connect_hub/core/database/daos/users_dao.dart' as _i897;
import 'package:connect_hub/core/network/api/auth_api_service.dart' as _i1000;
import 'package:connect_hub/core/network/api/chat_api_service.dart' as _i779;
import 'package:connect_hub/core/network/api/comment_api_service.dart' as _i557;
import 'package:connect_hub/core/network/api/developer_tools_service.dart'
    as _i899;
import 'package:connect_hub/core/network/api/fake_api_client.dart' as _i412;
import 'package:connect_hub/core/network/api/fake_auth_api_service.dart'
    as _i270;
import 'package:connect_hub/core/network/api/fake_chat_api_service.dart'
    as _i609;
import 'package:connect_hub/core/network/api/fake_comment_api_service.dart'
    as _i724;
import 'package:connect_hub/core/network/api/fake_developer_tools_service.dart'
    as _i887;
import 'package:connect_hub/core/network/api/fake_feed_api_service.dart'
    as _i610;
import 'package:connect_hub/core/network/api/fake_notification_api_service.dart'
    as _i536;
import 'package:connect_hub/core/network/api/fake_search_api_service.dart'
    as _i428;
import 'package:connect_hub/core/network/api/fake_user_api_service.dart'
    as _i139;
import 'package:connect_hub/core/network/api/feed_api_service.dart' as _i632;
import 'package:connect_hub/core/network/api/notification_api_service.dart'
    as _i436;
import 'package:connect_hub/core/network/api/search_api_service.dart' as _i976;
import 'package:connect_hub/core/network/api/user_api_service.dart' as _i895;
import 'package:connect_hub/core/network/asset_json_loader.dart' as _i409;
import 'package:connect_hub/core/network/fake_server/fake_server.dart' as _i698;
import 'package:connect_hub/core/network/fake_server/network_simulator.dart'
    as _i608;
import 'package:connect_hub/core/network/fake_server/reply_scheduler.dart'
    as _i891;
import 'package:connect_hub/core/network/fake_server/seed_loader.dart' as _i483;
import 'package:connect_hub/core/storage/session_storage.dart' as _i370;
import 'package:connect_hub/core/storage/settings_local_data_source.dart'
    as _i988;
import 'package:connect_hub/data/repository/api_guard.dart' as _i525;
import 'package:connect_hub/data/repository/auth_repository_impl.dart' as _i410;
import 'package:connect_hub/data/repository/bookmark_repository_impl.dart'
    as _i868;
import 'package:connect_hub/data/repository/cache_repository_impl.dart'
    as _i105;
import 'package:connect_hub/data/repository/chat_repository_impl.dart' as _i278;
import 'package:connect_hub/data/repository/comment_repository_impl.dart'
    as _i1052;
import 'package:connect_hub/data/repository/demo_tools_repository_impl.dart'
    as _i493;
import 'package:connect_hub/data/repository/feed_repository_impl.dart' as _i233;
import 'package:connect_hub/data/repository/notification_repository_impl.dart'
    as _i1071;
import 'package:connect_hub/data/repository/post_repository_impl.dart' as _i945;
import 'package:connect_hub/data/repository/profile_repository_impl.dart'
    as _i222;
import 'package:connect_hub/data/repository/search_repository_impl.dart'
    as _i292;
import 'package:connect_hub/data/repository/session_repository_impl.dart'
    as _i1055;
import 'package:connect_hub/data/repository/settings_repository_impl.dart'
    as _i2;
import 'package:connect_hub/di/app_module.dart' as _i781;
import 'package:connect_hub/domain/repository/auth_repository.dart' as _i288;
import 'package:connect_hub/domain/repository/bookmark_repository.dart'
    as _i441;
import 'package:connect_hub/domain/repository/cache_repository.dart' as _i1062;
import 'package:connect_hub/domain/repository/chat_repository.dart' as _i23;
import 'package:connect_hub/domain/repository/comment_repository.dart' as _i862;
import 'package:connect_hub/domain/repository/demo_tools_repository.dart'
    as _i690;
import 'package:connect_hub/domain/repository/feed_repository.dart' as _i677;
import 'package:connect_hub/domain/repository/notification_repository.dart'
    as _i869;
import 'package:connect_hub/domain/repository/post_repository.dart' as _i721;
import 'package:connect_hub/domain/repository/profile_repository.dart' as _i603;
import 'package:connect_hub/domain/repository/search_repository.dart' as _i816;
import 'package:connect_hub/domain/repository/session_repository.dart' as _i596;
import 'package:connect_hub/domain/repository/settings_repository.dart'
    as _i688;
import 'package:connect_hub/domain/usecase/add_comment_use_case.dart' as _i144;
import 'package:connect_hub/domain/usecase/bookmark_post_use_case.dart'
    as _i459;
import 'package:connect_hub/domain/usecase/clear_cache_use_case.dart' as _i79;
import 'package:connect_hub/domain/usecase/clear_recent_searches_use_case.dart'
    as _i311;
import 'package:connect_hub/domain/usecase/create_post_use_case.dart' as _i387;
import 'package:connect_hub/domain/usecase/delete_comment_use_case.dart'
    as _i67;
import 'package:connect_hub/domain/usecase/expire_session_use_case.dart'
    as _i787;
import 'package:connect_hub/domain/usecase/get_network_failure_use_case.dart'
    as _i504;
import 'package:connect_hub/domain/usecase/get_settings_use_case.dart' as _i427;
import 'package:connect_hub/domain/usecase/like_post_use_case.dart' as _i1008;
import 'package:connect_hub/domain/usecase/load_more_feed_use_case.dart'
    as _i737;
import 'package:connect_hub/domain/usecase/login_use_case.dart' as _i199;
import 'package:connect_hub/domain/usecase/logout_use_case.dart' as _i696;
import 'package:connect_hub/domain/usecase/mark_all_notifications_read_use_case.dart'
    as _i644;
import 'package:connect_hub/domain/usecase/mark_conversation_read_use_case.dart'
    as _i547;
import 'package:connect_hub/domain/usecase/mark_notification_read_use_case.dart'
    as _i166;
import 'package:connect_hub/domain/usecase/refresh_bookmarks_use_case.dart'
    as _i766;
import 'package:connect_hub/domain/usecase/refresh_comments_use_case.dart'
    as _i985;
import 'package:connect_hub/domain/usecase/refresh_conversations_use_case.dart'
    as _i524;
import 'package:connect_hub/domain/usecase/refresh_feed_use_case.dart' as _i663;
import 'package:connect_hub/domain/usecase/refresh_messages_use_case.dart'
    as _i830;
import 'package:connect_hub/domain/usecase/refresh_notifications_use_case.dart'
    as _i693;
import 'package:connect_hub/domain/usecase/refresh_post_use_case.dart' as _i466;
import 'package:connect_hub/domain/usecase/refresh_user_posts_use_case.dart'
    as _i633;
import 'package:connect_hub/domain/usecase/refresh_user_use_case.dart' as _i818;
import 'package:connect_hub/domain/usecase/retry_message_use_case.dart'
    as _i491;
import 'package:connect_hub/domain/usecase/save_recent_search_use_case.dart'
    as _i531;
import 'package:connect_hub/domain/usecase/search_use_case.dart' as _i467;
import 'package:connect_hub/domain/usecase/send_message_use_case.dart' as _i529;
import 'package:connect_hub/domain/usecase/set_network_failure_use_case.dart'
    as _i12;
import 'package:connect_hub/domain/usecase/sign_up_use_case.dart' as _i958;
import 'package:connect_hub/domain/usecase/update_language_use_case.dart'
    as _i486;
import 'package:connect_hub/domain/usecase/update_notifications_enabled_use_case.dart'
    as _i1034;
import 'package:connect_hub/domain/usecase/update_profile_use_case.dart'
    as _i568;
import 'package:connect_hub/domain/usecase/update_theme_mode_use_case.dart'
    as _i1013;
import 'package:connect_hub/domain/usecase/watch_bookmarks_use_case.dart'
    as _i345;
import 'package:connect_hub/domain/usecase/watch_cache_cleared_use_case.dart'
    as _i952;
import 'package:connect_hub/domain/usecase/watch_comments_use_case.dart'
    as _i845;
import 'package:connect_hub/domain/usecase/watch_conversation_use_case.dart'
    as _i748;
import 'package:connect_hub/domain/usecase/watch_conversations_use_case.dart'
    as _i1001;
import 'package:connect_hub/domain/usecase/watch_feed_use_case.dart' as _i735;
import 'package:connect_hub/domain/usecase/watch_messages_use_case.dart'
    as _i773;
import 'package:connect_hub/domain/usecase/watch_notifications_use_case.dart'
    as _i1059;
import 'package:connect_hub/domain/usecase/watch_post_use_case.dart' as _i835;
import 'package:connect_hub/domain/usecase/watch_recent_searches_use_case.dart'
    as _i667;
import 'package:connect_hub/domain/usecase/watch_search_results_use_case.dart'
    as _i180;
import 'package:connect_hub/domain/usecase/watch_session_use_case.dart' as _i5;
import 'package:connect_hub/domain/usecase/watch_settings_use_case.dart'
    as _i535;
import 'package:connect_hub/domain/usecase/watch_typing_use_case.dart' as _i181;
import 'package:connect_hub/domain/usecase/watch_unread_message_count_use_case.dart'
    as _i640;
import 'package:connect_hub/domain/usecase/watch_unread_notification_count_use_case.dart'
    as _i443;
import 'package:connect_hub/domain/usecase/watch_user_posts_use_case.dart'
    as _i780;
import 'package:connect_hub/domain/usecase/watch_user_use_case.dart' as _i43;
import 'package:connect_hub/features/activity/cubit/activity_cubit.dart'
    as _i675;
import 'package:connect_hub/features/auth/bloc/auth_bloc.dart' as _i854;
import 'package:connect_hub/features/auth/login/bloc/login_bloc.dart' as _i837;
import 'package:connect_hub/features/auth/sign_up/bloc/sign_up_bloc.dart'
    as _i611;
import 'package:connect_hub/features/bookmarks/cubit/bookmarks_cubit.dart'
    as _i599;
import 'package:connect_hub/features/chat_detail/cubit/chat_detail_cubit.dart'
    as _i732;
import 'package:connect_hub/features/chats/cubit/chats_cubit.dart' as _i833;
import 'package:connect_hub/features/comments/cubit/comments_cubit.dart'
    as _i852;
import 'package:connect_hub/features/create_post/cubit/create_post_cubit.dart'
    as _i576;
import 'package:connect_hub/features/edit_profile/cubit/edit_profile_cubit.dart'
    as _i604;
import 'package:connect_hub/features/feed/cubit/feed_cubit.dart' as _i829;
import 'package:connect_hub/features/post_detail/cubit/post_detail_cubit.dart'
    as _i726;
import 'package:connect_hub/features/profile/cubit/profile_cubit.dart' as _i682;
import 'package:connect_hub/features/search/bloc/search_bloc.dart' as _i896;
import 'package:connect_hub/features/settings/cubit/settings_cubit.dart'
    as _i272;
import 'package:connect_hub/features/settings/cubit/settings_tools_cubit.dart'
    as _i6;
import 'package:connect_hub/features/shell/cubit/badges_cubit.dart' as _i81;
import 'package:flutter/services.dart' as _i281;
import 'package:flutter_secure_storage/flutter_secure_storage.dart' as _i558;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:package_info_plus/package_info_plus.dart' as _i655;
import 'package:shared_preferences/shared_preferences.dart' as _i460;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  Future<_i174.GetIt> init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) async {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final appModule = _$AppModule();
    gh.lazySingleton<_i613.IdGenerator>(() => _i613.IdGenerator());
    gh.lazySingleton<_i608.NetworkSimulator>(() => _i608.NetworkSimulator());
    gh.lazySingleton<_i891.ReplyScheduler>(() => _i891.ReplyScheduler());
    gh.lazySingleton<_i281.AssetBundle>(() => appModule.assetBundle);
    gh.lazySingleton<_i558.FlutterSecureStorage>(() => appModule.secureStorage);
    gh.lazySingleton<_i454.Clock>(() => appModule.clock);
    gh.lazySingleton<_i131.AppDatabase>(() => appModule.appDatabase);
    await gh.lazySingletonAsync<_i460.SharedPreferencesWithCache>(
      () => appModule.preferences,
      preResolve: true,
    );
    await gh.lazySingletonAsync<_i655.PackageInfo>(
      () => appModule.packageInfo,
      preResolve: true,
    );
    gh.lazySingleton<_i355.PostsDao>(
      () => appModule.postsDao(gh<_i131.AppDatabase>()),
    );
    gh.lazySingleton<_i324.FeedDao>(
      () => appModule.feedDao(gh<_i131.AppDatabase>()),
    );
    gh.lazySingleton<_i99.CommentsDao>(
      () => appModule.commentsDao(gh<_i131.AppDatabase>()),
    );
    gh.lazySingleton<_i897.UsersDao>(
      () => appModule.usersDao(gh<_i131.AppDatabase>()),
    );
    gh.lazySingleton<_i193.BookmarksDao>(
      () => appModule.bookmarksDao(gh<_i131.AppDatabase>()),
    );
    gh.lazySingleton<_i146.SearchDao>(
      () => appModule.searchDao(gh<_i131.AppDatabase>()),
    );
    gh.lazySingleton<_i676.ChatDao>(
      () => appModule.chatDao(gh<_i131.AppDatabase>()),
    );
    gh.lazySingleton<_i325.NotificationsDao>(
      () => appModule.notificationsDao(gh<_i131.AppDatabase>()),
    );
    gh.lazySingleton<_i423.CacheDao>(
      () => appModule.cacheDao(gh<_i131.AppDatabase>()),
    );
    gh.lazySingleton<_i988.SettingsLocalDataSource>(
      () =>
          _i988.SettingsLocalDataSource(gh<_i460.SharedPreferencesWithCache>()),
    );
    gh.lazySingleton<_i370.SessionStorage>(
      () => _i370.SessionStorage(gh<_i558.FlutterSecureStorage>()),
    );
    gh.lazySingleton<_i409.AssetJsonLoader>(
      () => _i409.AssetJsonLoader(gh<_i281.AssetBundle>()),
    );
    gh.lazySingleton<_i688.SettingsRepository>(
      () => _i2.SettingsRepositoryImpl(gh<_i988.SettingsLocalDataSource>()),
    );
    gh.lazySingleton<_i483.SeedLoader>(
      () => _i483.SeedLoader(gh<_i409.AssetJsonLoader>()),
    );
    gh.lazySingleton<_i596.SessionRepository>(
      () => _i1055.SessionRepositoryImpl(
        gh<_i370.SessionStorage>(),
        gh<_i423.CacheDao>(),
      ),
    );
    gh.factory<_i427.GetSettingsUseCase>(
      () => _i427.GetSettingsUseCase(gh<_i688.SettingsRepository>()),
    );
    gh.factory<_i486.UpdateLanguageUseCase>(
      () => _i486.UpdateLanguageUseCase(gh<_i688.SettingsRepository>()),
    );
    gh.factory<_i1034.UpdateNotificationsEnabledUseCase>(
      () => _i1034.UpdateNotificationsEnabledUseCase(
        gh<_i688.SettingsRepository>(),
      ),
    );
    gh.factory<_i1013.UpdateThemeModeUseCase>(
      () => _i1013.UpdateThemeModeUseCase(gh<_i688.SettingsRepository>()),
    );
    gh.factory<_i535.WatchSettingsUseCase>(
      () => _i535.WatchSettingsUseCase(gh<_i688.SettingsRepository>()),
    );
    gh.lazySingleton<_i698.FakeServer>(
      () => _i698.FakeServer(
        gh<_i483.SeedLoader>(),
        gh<_i613.IdGenerator>(),
        gh<_i454.Clock>(),
        gh<_i891.ReplyScheduler>(),
      ),
      dispose: (i) => i.dispose(),
    );
    gh.factory<_i272.SettingsCubit>(
      () => _i272.SettingsCubit(
        gh<_i427.GetSettingsUseCase>(),
        gh<_i535.WatchSettingsUseCase>(),
        gh<_i1013.UpdateThemeModeUseCase>(),
        gh<_i1034.UpdateNotificationsEnabledUseCase>(),
        gh<_i486.UpdateLanguageUseCase>(),
      ),
    );
    gh.lazySingleton<_i899.DeveloperToolsService>(
      () => _i887.FakeDeveloperToolsService(
        gh<_i608.NetworkSimulator>(),
        gh<_i698.FakeServer>(),
        gh<_i370.SessionStorage>(),
      ),
    );
    gh.lazySingleton<_i412.FakeApiClient>(
      () => _i412.FakeApiClient(
        gh<_i370.SessionStorage>(),
        gh<_i608.NetworkSimulator>(),
        gh<_i698.FakeServer>(),
      ),
    );
    gh.lazySingleton<_i895.UserApiService>(
      () => _i139.FakeUserApiService(
        gh<_i412.FakeApiClient>(),
        gh<_i698.FakeServer>(),
      ),
    );
    gh.lazySingleton<_i525.ApiGuard>(
      () => _i525.ApiGuard(gh<_i596.SessionRepository>()),
    );
    gh.factory<_i5.WatchSessionUseCase>(
      () => _i5.WatchSessionUseCase(gh<_i596.SessionRepository>()),
    );
    gh.lazySingleton<_i1062.CacheRepository>(
      () => _i105.CacheRepositoryImpl(
        gh<_i423.CacheDao>(),
        gh<_i596.SessionRepository>(),
      ),
    );
    gh.lazySingleton<_i976.SearchApiService>(
      () => _i428.FakeSearchApiService(
        gh<_i412.FakeApiClient>(),
        gh<_i698.FakeServer>(),
      ),
    );
    gh.lazySingleton<_i779.ChatApiService>(
      () => _i609.FakeChatApiService(
        gh<_i412.FakeApiClient>(),
        gh<_i698.FakeServer>(),
      ),
    );
    gh.lazySingleton<_i816.SearchRepository>(
      () => _i292.SearchRepositoryImpl(
        gh<_i976.SearchApiService>(),
        gh<_i146.SearchDao>(),
        gh<_i525.ApiGuard>(),
        gh<_i454.Clock>(),
      ),
    );
    gh.lazySingleton<_i632.FeedApiService>(
      () => _i610.FakeFeedApiService(
        gh<_i412.FakeApiClient>(),
        gh<_i698.FakeServer>(),
      ),
    );
    gh.lazySingleton<_i441.BookmarkRepository>(
      () => _i868.BookmarkRepositoryImpl(
        gh<_i632.FeedApiService>(),
        gh<_i193.BookmarksDao>(),
        gh<_i525.ApiGuard>(),
      ),
    );
    gh.lazySingleton<_i436.NotificationApiService>(
      () => _i536.FakeNotificationApiService(
        gh<_i412.FakeApiClient>(),
        gh<_i698.FakeServer>(),
      ),
    );
    gh.factory<_i79.ClearCacheUseCase>(
      () => _i79.ClearCacheUseCase(gh<_i1062.CacheRepository>()),
    );
    gh.factory<_i952.WatchCacheClearedUseCase>(
      () => _i952.WatchCacheClearedUseCase(gh<_i1062.CacheRepository>()),
    );
    gh.lazySingleton<_i557.CommentApiService>(
      () => _i724.FakeCommentApiService(
        gh<_i412.FakeApiClient>(),
        gh<_i698.FakeServer>(),
      ),
    );
    gh.lazySingleton<_i721.PostRepository>(
      () => _i945.PostRepositoryImpl(
        gh<_i632.FeedApiService>(),
        gh<_i355.PostsDao>(),
        gh<_i324.FeedDao>(),
        gh<_i525.ApiGuard>(),
        gh<_i454.Clock>(),
      ),
    );
    gh.factory<_i311.ClearRecentSearchesUseCase>(
      () => _i311.ClearRecentSearchesUseCase(gh<_i816.SearchRepository>()),
    );
    gh.factory<_i531.SaveRecentSearchUseCase>(
      () => _i531.SaveRecentSearchUseCase(gh<_i816.SearchRepository>()),
    );
    gh.factory<_i467.SearchUseCase>(
      () => _i467.SearchUseCase(gh<_i816.SearchRepository>()),
    );
    gh.factory<_i667.WatchRecentSearchesUseCase>(
      () => _i667.WatchRecentSearchesUseCase(gh<_i816.SearchRepository>()),
    );
    gh.factory<_i180.WatchSearchResultsUseCase>(
      () => _i180.WatchSearchResultsUseCase(gh<_i816.SearchRepository>()),
    );
    gh.lazySingleton<_i690.DemoToolsRepository>(
      () => _i493.DemoToolsRepositoryImpl(gh<_i899.DeveloperToolsService>()),
    );
    gh.lazySingleton<_i1000.AuthApiService>(
      () => _i270.FakeAuthApiService(
        gh<_i698.FakeServer>(),
        gh<_i608.NetworkSimulator>(),
      ),
    );
    gh.lazySingleton<_i288.AuthRepository>(
      () => _i410.AuthRepositoryImpl(
        gh<_i1000.AuthApiService>(),
        gh<_i596.SessionRepository>(),
        gh<_i525.ApiGuard>(),
      ),
    );
    gh.lazySingleton<_i869.NotificationRepository>(
      () => _i1071.NotificationRepositoryImpl(
        gh<_i436.NotificationApiService>(),
        gh<_i325.NotificationsDao>(),
        gh<_i525.ApiGuard>(),
      ),
    );
    gh.lazySingleton<_i603.ProfileRepository>(
      () => _i222.ProfileRepositoryImpl(
        gh<_i895.UserApiService>(),
        gh<_i897.UsersDao>(),
        gh<_i355.PostsDao>(),
        gh<_i525.ApiGuard>(),
      ),
    );
    gh.factory<_i766.RefreshBookmarksUseCase>(
      () => _i766.RefreshBookmarksUseCase(gh<_i441.BookmarkRepository>()),
    );
    gh.factory<_i345.WatchBookmarksUseCase>(
      () => _i345.WatchBookmarksUseCase(gh<_i441.BookmarkRepository>()),
    );
    gh.factory<_i633.RefreshUserPostsUseCase>(
      () => _i633.RefreshUserPostsUseCase(gh<_i603.ProfileRepository>()),
    );
    gh.factory<_i818.RefreshUserUseCase>(
      () => _i818.RefreshUserUseCase(gh<_i603.ProfileRepository>()),
    );
    gh.factory<_i568.UpdateProfileUseCase>(
      () => _i568.UpdateProfileUseCase(gh<_i603.ProfileRepository>()),
    );
    gh.factory<_i780.WatchUserPostsUseCase>(
      () => _i780.WatchUserPostsUseCase(gh<_i603.ProfileRepository>()),
    );
    gh.factory<_i43.WatchUserUseCase>(
      () => _i43.WatchUserUseCase(gh<_i603.ProfileRepository>()),
    );
    gh.lazySingleton<_i23.ChatRepository>(
      () => _i278.ChatRepositoryImpl(
        gh<_i779.ChatApiService>(),
        gh<_i676.ChatDao>(),
        gh<_i596.SessionRepository>(),
        gh<_i525.ApiGuard>(),
        gh<_i613.IdGenerator>(),
        gh<_i454.Clock>(),
      ),
    );
    gh.factoryParam<_i604.EditProfileCubit, String, dynamic>(
      (userId, _) => _i604.EditProfileCubit(
        userId,
        gh<_i43.WatchUserUseCase>(),
        gh<_i818.RefreshUserUseCase>(),
        gh<_i568.UpdateProfileUseCase>(),
      ),
    );
    gh.factory<_i787.ExpireSessionUseCase>(
      () => _i787.ExpireSessionUseCase(gh<_i690.DemoToolsRepository>()),
    );
    gh.factory<_i504.GetNetworkFailureUseCase>(
      () => _i504.GetNetworkFailureUseCase(gh<_i690.DemoToolsRepository>()),
    );
    gh.factory<_i12.SetNetworkFailureUseCase>(
      () => _i12.SetNetworkFailureUseCase(gh<_i690.DemoToolsRepository>()),
    );
    gh.factory<_i6.SettingsToolsCubit>(
      () => _i6.SettingsToolsCubit(
        gh<_i504.GetNetworkFailureUseCase>(),
        gh<_i12.SetNetworkFailureUseCase>(),
        gh<_i79.ClearCacheUseCase>(),
        gh<_i787.ExpireSessionUseCase>(),
      ),
    );
    gh.lazySingleton<_i677.FeedRepository>(
      () => _i233.FeedRepositoryImpl(
        gh<_i632.FeedApiService>(),
        gh<_i324.FeedDao>(),
        gh<_i525.ApiGuard>(),
      ),
    );
    gh.factory<_i737.LoadMoreFeedUseCase>(
      () => _i737.LoadMoreFeedUseCase(gh<_i677.FeedRepository>()),
    );
    gh.factory<_i663.RefreshFeedUseCase>(
      () => _i663.RefreshFeedUseCase(gh<_i677.FeedRepository>()),
    );
    gh.factory<_i735.WatchFeedUseCase>(
      () => _i735.WatchFeedUseCase(gh<_i677.FeedRepository>()),
    );
    gh.factory<_i644.MarkAllNotificationsReadUseCase>(
      () => _i644.MarkAllNotificationsReadUseCase(
        gh<_i869.NotificationRepository>(),
      ),
    );
    gh.factory<_i166.MarkNotificationReadUseCase>(
      () =>
          _i166.MarkNotificationReadUseCase(gh<_i869.NotificationRepository>()),
    );
    gh.factory<_i693.RefreshNotificationsUseCase>(
      () =>
          _i693.RefreshNotificationsUseCase(gh<_i869.NotificationRepository>()),
    );
    gh.factory<_i1059.WatchNotificationsUseCase>(
      () =>
          _i1059.WatchNotificationsUseCase(gh<_i869.NotificationRepository>()),
    );
    gh.factory<_i443.WatchUnreadNotificationCountUseCase>(
      () => _i443.WatchUnreadNotificationCountUseCase(
        gh<_i869.NotificationRepository>(),
      ),
    );
    gh.factory<_i547.MarkConversationReadUseCase>(
      () => _i547.MarkConversationReadUseCase(gh<_i23.ChatRepository>()),
    );
    gh.factory<_i524.RefreshConversationsUseCase>(
      () => _i524.RefreshConversationsUseCase(gh<_i23.ChatRepository>()),
    );
    gh.factory<_i830.RefreshMessagesUseCase>(
      () => _i830.RefreshMessagesUseCase(gh<_i23.ChatRepository>()),
    );
    gh.factory<_i491.RetryMessageUseCase>(
      () => _i491.RetryMessageUseCase(gh<_i23.ChatRepository>()),
    );
    gh.factory<_i529.SendMessageUseCase>(
      () => _i529.SendMessageUseCase(gh<_i23.ChatRepository>()),
    );
    gh.factory<_i748.WatchConversationUseCase>(
      () => _i748.WatchConversationUseCase(gh<_i23.ChatRepository>()),
    );
    gh.factory<_i1001.WatchConversationsUseCase>(
      () => _i1001.WatchConversationsUseCase(gh<_i23.ChatRepository>()),
    );
    gh.factory<_i773.WatchMessagesUseCase>(
      () => _i773.WatchMessagesUseCase(gh<_i23.ChatRepository>()),
    );
    gh.factory<_i181.WatchTypingUseCase>(
      () => _i181.WatchTypingUseCase(gh<_i23.ChatRepository>()),
    );
    gh.factory<_i640.WatchUnreadMessageCountUseCase>(
      () => _i640.WatchUnreadMessageCountUseCase(gh<_i23.ChatRepository>()),
    );
    gh.lazySingleton<_i862.CommentRepository>(
      () => _i1052.CommentRepositoryImpl(
        gh<_i557.CommentApiService>(),
        gh<_i99.CommentsDao>(),
        gh<_i355.PostsDao>(),
        gh<_i721.PostRepository>(),
        gh<_i596.SessionRepository>(),
        gh<_i525.ApiGuard>(),
      ),
    );
    gh.factory<_i459.BookmarkPostUseCase>(
      () => _i459.BookmarkPostUseCase(gh<_i721.PostRepository>()),
    );
    gh.factory<_i387.CreatePostUseCase>(
      () => _i387.CreatePostUseCase(gh<_i721.PostRepository>()),
    );
    gh.factory<_i1008.LikePostUseCase>(
      () => _i1008.LikePostUseCase(gh<_i721.PostRepository>()),
    );
    gh.factory<_i466.RefreshPostUseCase>(
      () => _i466.RefreshPostUseCase(gh<_i721.PostRepository>()),
    );
    gh.factory<_i835.WatchPostUseCase>(
      () => _i835.WatchPostUseCase(gh<_i721.PostRepository>()),
    );
    gh.factory<_i199.LoginUseCase>(
      () => _i199.LoginUseCase(gh<_i288.AuthRepository>()),
    );
    gh.factory<_i696.LogoutUseCase>(
      () => _i696.LogoutUseCase(gh<_i288.AuthRepository>()),
    );
    gh.factory<_i958.SignUpUseCase>(
      () => _i958.SignUpUseCase(gh<_i288.AuthRepository>()),
    );
    gh.factory<_i144.AddCommentUseCase>(
      () => _i144.AddCommentUseCase(gh<_i862.CommentRepository>()),
    );
    gh.factory<_i67.DeleteCommentUseCase>(
      () => _i67.DeleteCommentUseCase(gh<_i862.CommentRepository>()),
    );
    gh.factory<_i985.RefreshCommentsUseCase>(
      () => _i985.RefreshCommentsUseCase(gh<_i862.CommentRepository>()),
    );
    gh.factory<_i845.WatchCommentsUseCase>(
      () => _i845.WatchCommentsUseCase(gh<_i862.CommentRepository>()),
    );
    gh.factory<_i833.ChatsCubit>(
      () => _i833.ChatsCubit(
        gh<_i1001.WatchConversationsUseCase>(),
        gh<_i524.RefreshConversationsUseCase>(),
      ),
    );
    gh.factory<_i837.LoginBloc>(
      () => _i837.LoginBloc(gh<_i199.LoginUseCase>()),
    );
    gh.factoryParam<_i682.ProfileCubit, String, dynamic>(
      (userId, _) => _i682.ProfileCubit(
        userId,
        gh<_i43.WatchUserUseCase>(),
        gh<_i818.RefreshUserUseCase>(),
        gh<_i780.WatchUserPostsUseCase>(),
        gh<_i633.RefreshUserPostsUseCase>(),
        gh<_i1008.LikePostUseCase>(),
        gh<_i459.BookmarkPostUseCase>(),
        gh<_i952.WatchCacheClearedUseCase>(),
      ),
    );
    gh.factory<_i829.FeedCubit>(
      () => _i829.FeedCubit(
        gh<_i735.WatchFeedUseCase>(),
        gh<_i663.RefreshFeedUseCase>(),
        gh<_i737.LoadMoreFeedUseCase>(),
        gh<_i1008.LikePostUseCase>(),
        gh<_i459.BookmarkPostUseCase>(),
        gh<_i952.WatchCacheClearedUseCase>(),
      ),
    );
    gh.factory<_i675.ActivityCubit>(
      () => _i675.ActivityCubit(
        gh<_i1059.WatchNotificationsUseCase>(),
        gh<_i693.RefreshNotificationsUseCase>(),
        gh<_i166.MarkNotificationReadUseCase>(),
        gh<_i644.MarkAllNotificationsReadUseCase>(),
        gh<_i952.WatchCacheClearedUseCase>(),
      ),
    );
    gh.factory<_i81.BadgesCubit>(
      () => _i81.BadgesCubit(
        gh<_i427.GetSettingsUseCase>(),
        gh<_i535.WatchSettingsUseCase>(),
        gh<_i443.WatchUnreadNotificationCountUseCase>(),
        gh<_i640.WatchUnreadMessageCountUseCase>(),
        gh<_i693.RefreshNotificationsUseCase>(),
        gh<_i524.RefreshConversationsUseCase>(),
        gh<_i952.WatchCacheClearedUseCase>(),
      ),
    );
    gh.factoryParam<_i732.ChatDetailCubit, String, dynamic>(
      (conversationId, _) => _i732.ChatDetailCubit(
        conversationId,
        gh<_i748.WatchConversationUseCase>(),
        gh<_i773.WatchMessagesUseCase>(),
        gh<_i181.WatchTypingUseCase>(),
        gh<_i830.RefreshMessagesUseCase>(),
        gh<_i547.MarkConversationReadUseCase>(),
        gh<_i529.SendMessageUseCase>(),
        gh<_i491.RetryMessageUseCase>(),
      ),
    );
    gh.factoryParam<_i852.CommentsCubit, String, dynamic>(
      (postId, _) => _i852.CommentsCubit(
        postId,
        gh<_i845.WatchCommentsUseCase>(),
        gh<_i985.RefreshCommentsUseCase>(),
        gh<_i144.AddCommentUseCase>(),
        gh<_i67.DeleteCommentUseCase>(),
      ),
    );
    gh.factoryParam<_i726.PostDetailCubit, String, dynamic>(
      (postId, _) => _i726.PostDetailCubit(
        postId,
        gh<_i835.WatchPostUseCase>(),
        gh<_i466.RefreshPostUseCase>(),
        gh<_i845.WatchCommentsUseCase>(),
        gh<_i985.RefreshCommentsUseCase>(),
        gh<_i144.AddCommentUseCase>(),
        gh<_i1008.LikePostUseCase>(),
        gh<_i459.BookmarkPostUseCase>(),
      ),
    );
    gh.factory<_i576.CreatePostCubit>(
      () => _i576.CreatePostCubit(gh<_i387.CreatePostUseCase>()),
    );
    gh.factory<_i854.AuthBloc>(
      () => _i854.AuthBloc(
        gh<_i5.WatchSessionUseCase>(),
        gh<_i696.LogoutUseCase>(),
      ),
    );
    gh.factory<_i611.SignUpBloc>(
      () => _i611.SignUpBloc(gh<_i958.SignUpUseCase>()),
    );
    gh.factory<_i599.BookmarksCubit>(
      () => _i599.BookmarksCubit(
        gh<_i345.WatchBookmarksUseCase>(),
        gh<_i766.RefreshBookmarksUseCase>(),
        gh<_i459.BookmarkPostUseCase>(),
        gh<_i1008.LikePostUseCase>(),
      ),
    );
    gh.factory<_i896.SearchBloc>(
      () => _i896.SearchBloc(
        gh<_i467.SearchUseCase>(),
        gh<_i180.WatchSearchResultsUseCase>(),
        gh<_i667.WatchRecentSearchesUseCase>(),
        gh<_i531.SaveRecentSearchUseCase>(),
        gh<_i311.ClearRecentSearchesUseCase>(),
        gh<_i1008.LikePostUseCase>(),
        gh<_i459.BookmarkPostUseCase>(),
        gh<_i952.WatchCacheClearedUseCase>(),
      ),
    );
    return this;
  }
}

class _$AppModule extends _i781.AppModule {}
