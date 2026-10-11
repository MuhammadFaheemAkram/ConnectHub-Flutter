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
import 'package:connect_hub/core/database/daos/cache_dao.dart' as _i423;
import 'package:connect_hub/core/database/daos/comments_dao.dart' as _i99;
import 'package:connect_hub/core/database/daos/feed_dao.dart' as _i324;
import 'package:connect_hub/core/database/daos/posts_dao.dart' as _i355;
import 'package:connect_hub/core/network/api/auth_api_service.dart' as _i1000;
import 'package:connect_hub/core/network/api/comment_api_service.dart' as _i557;
import 'package:connect_hub/core/network/api/fake_api_client.dart' as _i412;
import 'package:connect_hub/core/network/api/fake_auth_api_service.dart'
    as _i270;
import 'package:connect_hub/core/network/api/fake_comment_api_service.dart'
    as _i724;
import 'package:connect_hub/core/network/api/fake_feed_api_service.dart'
    as _i609;
import 'package:connect_hub/core/network/api/feed_api_service.dart' as _i632;
import 'package:connect_hub/core/network/asset_json_loader.dart' as _i409;
import 'package:connect_hub/core/network/fake_server/fake_server.dart' as _i698;
import 'package:connect_hub/core/network/fake_server/network_simulator.dart'
    as _i608;
import 'package:connect_hub/core/network/fake_server/seed_loader.dart' as _i483;
import 'package:connect_hub/core/storage/session_storage.dart' as _i370;
import 'package:connect_hub/data/repository/api_guard.dart' as _i525;
import 'package:connect_hub/data/repository/auth_repository_impl.dart' as _i410;
import 'package:connect_hub/data/repository/comment_repository_impl.dart'
    as _i1052;
import 'package:connect_hub/data/repository/feed_repository_impl.dart' as _i233;
import 'package:connect_hub/data/repository/post_repository_impl.dart' as _i945;
import 'package:connect_hub/data/repository/session_repository_impl.dart'
    as _i1055;
import 'package:connect_hub/di/app_module.dart' as _i781;
import 'package:connect_hub/domain/repository/auth_repository.dart' as _i288;
import 'package:connect_hub/domain/repository/comment_repository.dart' as _i862;
import 'package:connect_hub/domain/repository/feed_repository.dart' as _i676;
import 'package:connect_hub/domain/repository/post_repository.dart' as _i721;
import 'package:connect_hub/domain/repository/session_repository.dart' as _i596;
import 'package:connect_hub/domain/usecase/add_comment_use_case.dart' as _i144;
import 'package:connect_hub/domain/usecase/bookmark_post_use_case.dart'
    as _i459;
import 'package:connect_hub/domain/usecase/create_post_use_case.dart' as _i387;
import 'package:connect_hub/domain/usecase/delete_comment_use_case.dart'
    as _i67;
import 'package:connect_hub/domain/usecase/like_post_use_case.dart' as _i1008;
import 'package:connect_hub/domain/usecase/load_more_feed_use_case.dart'
    as _i737;
import 'package:connect_hub/domain/usecase/login_use_case.dart' as _i199;
import 'package:connect_hub/domain/usecase/logout_use_case.dart' as _i696;
import 'package:connect_hub/domain/usecase/refresh_comments_use_case.dart'
    as _i985;
import 'package:connect_hub/domain/usecase/refresh_feed_use_case.dart' as _i663;
import 'package:connect_hub/domain/usecase/refresh_post_use_case.dart' as _i466;
import 'package:connect_hub/domain/usecase/sign_up_use_case.dart' as _i958;
import 'package:connect_hub/domain/usecase/watch_comments_use_case.dart'
    as _i845;
import 'package:connect_hub/domain/usecase/watch_feed_use_case.dart' as _i735;
import 'package:connect_hub/domain/usecase/watch_post_use_case.dart' as _i835;
import 'package:connect_hub/domain/usecase/watch_session_use_case.dart' as _i5;
import 'package:connect_hub/features/auth/bloc/auth_bloc.dart' as _i854;
import 'package:connect_hub/features/auth/login/bloc/login_bloc.dart' as _i837;
import 'package:connect_hub/features/auth/sign_up/bloc/sign_up_bloc.dart'
    as _i611;
import 'package:connect_hub/features/comments/cubit/comments_cubit.dart'
    as _i852;
import 'package:connect_hub/features/create_post/cubit/create_post_cubit.dart'
    as _i576;
import 'package:connect_hub/features/feed/cubit/feed_cubit.dart' as _i829;
import 'package:connect_hub/features/post_detail/cubit/post_detail_cubit.dart'
    as _i726;
import 'package:flutter/services.dart' as _i281;
import 'package:flutter_secure_storage/flutter_secure_storage.dart' as _i558;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final appModule = _$AppModule();
    gh.lazySingleton<_i613.IdGenerator>(() => _i613.IdGenerator());
    gh.lazySingleton<_i608.NetworkSimulator>(() => _i608.NetworkSimulator());
    gh.lazySingleton<_i281.AssetBundle>(() => appModule.assetBundle);
    gh.lazySingleton<_i558.FlutterSecureStorage>(() => appModule.secureStorage);
    gh.lazySingleton<_i454.Clock>(() => appModule.clock);
    gh.lazySingleton<_i131.AppDatabase>(() => appModule.appDatabase);
    gh.lazySingleton<_i355.PostsDao>(
      () => appModule.postsDao(gh<_i131.AppDatabase>()),
    );
    gh.lazySingleton<_i324.FeedDao>(
      () => appModule.feedDao(gh<_i131.AppDatabase>()),
    );
    gh.lazySingleton<_i99.CommentsDao>(
      () => appModule.commentsDao(gh<_i131.AppDatabase>()),
    );
    gh.lazySingleton<_i423.CacheDao>(
      () => appModule.cacheDao(gh<_i131.AppDatabase>()),
    );
    gh.lazySingleton<_i370.SessionStorage>(
      () => _i370.SessionStorage(gh<_i558.FlutterSecureStorage>()),
    );
    gh.lazySingleton<_i409.AssetJsonLoader>(
      () => _i409.AssetJsonLoader(gh<_i281.AssetBundle>()),
    );
    gh.lazySingleton<_i483.SeedLoader>(
      () => _i483.SeedLoader(gh<_i409.AssetJsonLoader>()),
    );
    gh.lazySingleton<_i698.FakeServer>(
      () => _i698.FakeServer(
        gh<_i483.SeedLoader>(),
        gh<_i613.IdGenerator>(),
        gh<_i454.Clock>(),
      ),
    );
    gh.lazySingleton<_i596.SessionRepository>(
      () => _i1055.SessionRepositoryImpl(
        gh<_i370.SessionStorage>(),
        gh<_i423.CacheDao>(),
      ),
    );
    gh.lazySingleton<_i1000.AuthApiService>(
      () => _i270.FakeAuthApiService(
        gh<_i698.FakeServer>(),
        gh<_i608.NetworkSimulator>(),
      ),
    );
    gh.lazySingleton<_i412.FakeApiClient>(
      () => _i412.FakeApiClient(
        gh<_i370.SessionStorage>(),
        gh<_i608.NetworkSimulator>(),
        gh<_i698.FakeServer>(),
      ),
    );
    gh.lazySingleton<_i525.ApiGuard>(
      () => _i525.ApiGuard(gh<_i596.SessionRepository>()),
    );
    gh.factory<_i5.WatchSessionUseCase>(
      () => _i5.WatchSessionUseCase(gh<_i596.SessionRepository>()),
    );
    gh.lazySingleton<_i632.FeedApiService>(
      () => _i609.FakeFeedApiService(
        gh<_i412.FakeApiClient>(),
        gh<_i698.FakeServer>(),
      ),
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
    gh.lazySingleton<_i288.AuthRepository>(
      () => _i410.AuthRepositoryImpl(
        gh<_i1000.AuthApiService>(),
        gh<_i596.SessionRepository>(),
        gh<_i525.ApiGuard>(),
      ),
    );
    gh.lazySingleton<_i676.FeedRepository>(
      () => _i233.FeedRepositoryImpl(
        gh<_i632.FeedApiService>(),
        gh<_i324.FeedDao>(),
        gh<_i525.ApiGuard>(),
      ),
    );
    gh.factory<_i737.LoadMoreFeedUseCase>(
      () => _i737.LoadMoreFeedUseCase(gh<_i676.FeedRepository>()),
    );
    gh.factory<_i663.RefreshFeedUseCase>(
      () => _i663.RefreshFeedUseCase(gh<_i676.FeedRepository>()),
    );
    gh.factory<_i735.WatchFeedUseCase>(
      () => _i735.WatchFeedUseCase(gh<_i676.FeedRepository>()),
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
    gh.factory<_i837.LoginBloc>(
      () => _i837.LoginBloc(gh<_i199.LoginUseCase>()),
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
    gh.factory<_i829.FeedCubit>(
      () => _i829.FeedCubit(
        gh<_i735.WatchFeedUseCase>(),
        gh<_i663.RefreshFeedUseCase>(),
        gh<_i737.LoadMoreFeedUseCase>(),
        gh<_i1008.LikePostUseCase>(),
        gh<_i459.BookmarkPostUseCase>(),
      ),
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
    return this;
  }
}

class _$AppModule extends _i781.AppModule {}
