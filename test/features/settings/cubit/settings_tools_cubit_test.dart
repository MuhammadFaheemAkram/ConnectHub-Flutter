import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:connect_hub/core/common/ui_message.dart';
import 'package:connect_hub/domain/usecase/clear_cache_use_case.dart';
import 'package:connect_hub/domain/usecase/expire_session_use_case.dart';
import 'package:connect_hub/domain/usecase/get_network_failure_use_case.dart';
import 'package:connect_hub/domain/usecase/set_network_failure_use_case.dart';
import 'package:connect_hub/features/settings/cubit/settings_tools_cubit.dart';
import 'package:connect_hub/features/settings/cubit/settings_tools_state.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fakes/fake_cache_repository.dart';
import '../../../helpers/fakes/fake_demo_tools_repository.dart';

void main() {
  late FakeCacheRepository cache;
  late FakeDemoToolsRepository tools;

  setUp(() {
    cache = FakeCacheRepository();
    tools = FakeDemoToolsRepository();
  });

  tearDown(() => cache.dispose());

  SettingsToolsCubit buildCubit() => SettingsToolsCubit(
    GetNetworkFailureUseCase(tools),
    SetNetworkFailureUseCase(tools),
    ClearCacheUseCase(cache),
    ExpireSessionUseCase(tools),
  );

  test('the network switch starts where it is (it lives in memory)', () {
    tools.failsRequests = true;

    final cubit = buildCubit();
    addTearDown(cubit.close);

    expect(cubit.state.failsRequests, isTrue);
  });

  blocTest<SettingsToolsCubit, SettingsToolsState>(
    'Clear cache: busy while it runs, then "Cache cleared."',
    build: buildCubit,
    act: (cubit) => cubit.clearCache(),
    expect: () => [
      const SettingsToolsState(isClearingCache: true),
      const SettingsToolsState(
        message: UiMessage(id: 1, text: SettingsToolsCubit.cacheClearedMessage),
      ),
    ],
    verify: (_) => expect(cache.clearCalls, 1),
  );

  blocTest<SettingsToolsCubit, SettingsToolsState>(
    'a second Clear while the first runs is ignored',
    setUp: () => cache.gate = Completer<void>(),
    build: buildCubit,
    act: (cubit) async {
      final first = cubit.clearCache();
      await cubit.clearCache();
      cache.gate!.complete();
      await first;
    },
    skip: 1,
    expect: () => [
      const SettingsToolsState(
        message: UiMessage(id: 1, text: SettingsToolsCubit.cacheClearedMessage),
      ),
    ],
    verify: (_) => expect(cache.clearCalls, 1),
  );

  blocTest<SettingsToolsCubit, SettingsToolsState>(
    '"Simulate network failure" turns the failures on and off',
    build: buildCubit,
    act: (cubit) {
      cubit.setNetworkFailure(fail: true);
      expect(tools.failsRequests, isTrue);
      cubit.setNetworkFailure(fail: false);
    },
    expect: () => [
      const SettingsToolsState(failsRequests: true),
      const SettingsToolsState(),
    ],
    verify: (_) => expect(tools.failsRequests, isFalse),
  );

  blocTest<SettingsToolsCubit, SettingsToolsState>(
    '"Expire session" says what happens next',
    build: buildCubit,
    act: (cubit) => cubit.expireSession(),
    expect: () => [
      const SettingsToolsState(
        message: UiMessage(
          id: 1,
          text: SettingsToolsCubit.sessionExpiredMessage,
        ),
      ),
    ],
    verify: (_) => expect(tools.expireCalls, 1),
  );
}
