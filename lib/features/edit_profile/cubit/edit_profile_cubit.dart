import 'package:connect_hub/core/common/first_value.dart';
import 'package:connect_hub/core/common/form_status.dart';
import 'package:connect_hub/core/common/result.dart';
import 'package:connect_hub/domain/usecase/refresh_user_use_case.dart';
import 'package:connect_hub/domain/usecase/update_profile_use_case.dart';
import 'package:connect_hub/domain/usecase/watch_user_use_case.dart';
import 'package:connect_hub/features/edit_profile/cubit/edit_profile_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

/// Drives the Edit Profile form, for the signed-in user ([userId], from the
/// session, through `@factoryParam`).
///
/// The form starts from the cached profile. My Profile has just loaded it,
/// so that is normally instant; arriving some other way (e.g. back here after
/// signing in again, with the cache wiped), it fetches the profile first.
@injectable
class EditProfileCubit extends Cubit<EditProfileState> {
  EditProfileCubit(
    @factoryParam this.userId,
    this._watchUser,
    this._refreshUser,
    this._updateProfile,
  ) : super(const EditProfileState());

  final String userId;
  final WatchUserUseCase _watchUser;
  final RefreshUserUseCase _refreshUser;
  final UpdateProfileUseCase _updateProfile;

  static const notLoadedMessage = "Couldn't load your profile.";

  /// Fills the form with the profile, and "Try again" after that failed.
  Future<void> load() async {
    // A retry shows the spinner again. (Only then: a Cubit's first emit is
    // never skipped, even when it repeats the initial state, §11.12.)
    if (state.loadError != null) emit(state.copyWith(loadError: null));
    var user = await _watchUser(userId).firstValue;
    if (isClosed) return;
    if (user == null) {
      final result = await _refreshUser(userId);
      if (isClosed) return;
      if (result case Err(:final exception)) {
        emit(state.copyWith(loadError: exception.message));
        return;
      }
      user = await _watchUser(userId).firstValue;
      if (isClosed) return;
    }
    if (user == null) {
      emit(state.copyWith(loadError: notLoadedMessage));
      return;
    }
    emit(
      state.copyWith(
        original: user,
        name: user.name,
        bio: user.bio,
        avatarUrl: user.avatarUrl ?? '',
      ),
    );
  }

  void nameChanged(String value) => emit(_edited(state.copyWith(name: value)));

  void bioChanged(String value) => emit(_edited(state.copyWith(bio: value)));

  void avatarUrlChanged(String value) =>
      emit(_edited(state.copyWith(avatarUrl: value)));

  /// Saves the profile. On success the status becomes `success` and the View
  /// closes the page; on failure the input stays and the message shows.
  Future<void> save() async {
    if (!state.canSave) return;
    emit(state.copyWith(status: FormStatus.submitting, errorMessage: null));
    final result = await _updateProfile(
      name: state.name,
      bio: state.bio,
      avatarUrl: state.avatarUrl,
    );
    if (isClosed) return;
    emit(switch (result) {
      Ok() => state.copyWith(status: FormStatus.success),
      Err(:final exception) => state.copyWith(
        status: FormStatus.failure,
        errorMessage: exception.message,
      ),
    });
  }

  /// Editing after a failure starts over: the old error no longer applies.
  EditProfileState _edited(EditProfileState next) =>
      next.status == FormStatus.failure
      ? next.copyWith(status: FormStatus.idle, errorMessage: null)
      : next;
}
