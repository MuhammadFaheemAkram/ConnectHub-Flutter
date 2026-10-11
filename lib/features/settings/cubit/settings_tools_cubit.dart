import 'package:connect_hub/core/common/ui_message.dart';
import 'package:connect_hub/domain/usecase/clear_cache_use_case.dart';
import 'package:connect_hub/domain/usecase/expire_session_use_case.dart';
import 'package:connect_hub/domain/usecase/get_network_failure_use_case.dart';
import 'package:connect_hub/domain/usecase/set_network_failure_use_case.dart';
import 'package:connect_hub/features/settings/cubit/settings_tools_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

/// Drives the Settings screen's actions: "Clear cache" and the Developer
/// switches.
///
/// Unlike `SettingsCubit`'s preferences, none of this is persisted or
/// app-wide, so it lives with the screen. The preferences stay in their
/// app-scoped Cubit, which also restyles the app.
@injectable
class SettingsToolsCubit extends Cubit<SettingsToolsState> {
  SettingsToolsCubit(
    GetNetworkFailureUseCase getNetworkFailure,
    this._setNetworkFailure,
    this._clearCache,
    this._expireSession,
  ) : super(SettingsToolsState(failsRequests: getNetworkFailure()));

  final SetNetworkFailureUseCase _setNetworkFailure;
  final ClearCacheUseCase _clearCache;
  final ExpireSessionUseCase _expireSession;

  static const cacheClearedMessage = 'Cache cleared.';
  static const sessionExpiredMessage =
      'Session expired. Your next request will sign you out.';

  int _messageCount = 0;

  /// Deletes the cached server data; the screens fetch it again.
  Future<void> clearCache() async {
    if (state.isClearingCache) return;
    emit(state.copyWith(isClearingCache: true));
    await _clearCache();
    if (isClosed) return;
    emit(
      state.copyWith(
        isClearingCache: false,
        message: _nextMessage(cacheClearedMessage),
      ),
    );
  }

  /// Every request fails while this is on, as if offline.
  void setNetworkFailure({required bool fail}) {
    _setNetworkFailure(fail: fail);
    emit(state.copyWith(failsRequests: fail));
  }

  /// The server stops accepting the session's token. Nothing happens until
  /// the next request: its 401 signs the user out, with the expiry message.
  Future<void> expireSession() async {
    await _expireSession();
    if (isClosed) return;
    emit(state.copyWith(message: _nextMessage(sessionExpiredMessage)));
  }

  UiMessage _nextMessage(String text) =>
      UiMessage(id: ++_messageCount, text: text);
}
