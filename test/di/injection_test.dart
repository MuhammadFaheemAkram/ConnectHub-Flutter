import 'package:connect_hub/di/injection.dart';
import 'package:connect_hub/domain/repository/auth_repository.dart';
import 'package:connect_hub/domain/repository/feed_repository.dart';
import 'package:connect_hub/domain/repository/post_repository.dart';
import 'package:connect_hub/domain/repository/session_repository.dart';
import 'package:connect_hub/features/auth/bloc/auth_bloc.dart';
import 'package:connect_hub/features/auth/login/bloc/login_bloc.dart';
import 'package:connect_hub/features/auth/sign_up/bloc/sign_up_bloc.dart';
import 'package:connect_hub/features/feed/cubit/feed_cubit.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_dependencies.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(getIt.reset);

  // A smoke test of the real composition root (with the database in memory).
  // A constructor parameter that injectable can't resolve (e.g. a missing
  // `@ignoreParam`) only fails when its type is first resolved, at runtime.
  // Resolving the top of each graph here catches it in CI.
  test(
    'the real container resolves every Bloc, Cubit and repository',
    () async {
      await configureTestDependencies();

      expect(getIt<SessionRepository>(), isNotNull);
      expect(getIt<AuthRepository>(), isNotNull);
      expect(getIt<FeedRepository>(), isNotNull);
      expect(getIt<PostRepository>(), isNotNull);
      await getIt<AuthBloc>().close();
      await getIt<LoginBloc>().close();
      await getIt<SignUpBloc>().close();
      await getIt<FeedCubit>().close();
    },
  );

  test('repositories are singletons, Blocs are new for every screen', () async {
    await configureTestDependencies();

    expect(getIt<SessionRepository>(), same(getIt<SessionRepository>()));
    expect(getIt<FeedRepository>(), same(getIt<FeedRepository>()));
    final first = getIt<LoginBloc>();
    final second = getIt<LoginBloc>();
    expect(first, isNot(same(second)));
    await first.close();
    await second.close();
  });
}
