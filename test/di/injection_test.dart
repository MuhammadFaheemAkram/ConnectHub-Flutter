import 'package:connect_hub/di/injection.dart';
import 'package:connect_hub/domain/repository/auth_repository.dart';
import 'package:connect_hub/domain/repository/session_repository.dart';
import 'package:connect_hub/features/auth/bloc/auth_bloc.dart';
import 'package:connect_hub/features/auth/login/bloc/login_bloc.dart';
import 'package:connect_hub/features/auth/sign_up/bloc/sign_up_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => FlutterSecureStorage.setMockInitialValues({}));
  tearDown(getIt.reset);

  // A smoke test of the real composition root. A constructor parameter that
  // injectable can't resolve (e.g. a missing `@ignoreParam`) only fails when
  // its type is first resolved, at runtime. Resolving the top of each graph
  // here catches it in CI.
  test('the real container resolves every Bloc and repository', () async {
    await configureDependencies();

    expect(getIt<SessionRepository>(), isNotNull);
    expect(getIt<AuthRepository>(), isNotNull);
    await getIt<AuthBloc>().close();
    await getIt<LoginBloc>().close();
    await getIt<SignUpBloc>().close();
  });

  test('repositories are singletons, Blocs are new for every screen', () async {
    await configureDependencies();

    expect(getIt<SessionRepository>(), same(getIt<SessionRepository>()));
    final first = getIt<LoginBloc>();
    final second = getIt<LoginBloc>();
    expect(first, isNot(same(second)));
    await first.close();
    await second.close();
  });
}
