import 'package:connect_hub/core/common/form_status.dart';
import 'package:connect_hub/core/common/validators.dart';
import 'package:connect_hub/domain/model/user.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'edit_profile_state.freezed.dart';

@freezed
abstract class EditProfileState with _$EditProfileState {
  const EditProfileState._();

  const factory EditProfileState({
    /// The profile the form started from; `null` until it has loaded.
    User? original,

    /// Why the profile couldn't be loaded, if it couldn't.
    String? loadError,
    @Default('') String name,
    @Default('') String bio,
    @Default('') String avatarUrl,
    @Default(FormStatus.idle) FormStatus status,

    /// Why the last save failed, from the server.
    String? errorMessage,
  }) = _EditProfileState;

  bool get isLoading => original == null && loadError == null;

  /// What the bio's counter shows: characters as people count them.
  int get bioLength => Validators.lengthOf(bio);

  // The form starts from a valid profile, so errors can show live: one
  // appears the moment an edit breaks a rule.
  String? get nameError => Validators.name(name);
  String? get bioError => Validators.bio(bio);
  String? get avatarUrlError => Validators.imageUrl(avatarUrl);

  bool get isValid =>
      nameError == null && bioError == null && avatarUrlError == null;

  /// Whether saving would change anything, compared as the server would
  /// store it (trimmed).
  bool get hasChanges {
    final original = this.original;
    return original != null &&
        (name.trim() != original.name ||
            bio.trim() != original.bio ||
            avatarUrl.trim() != (original.avatarUrl ?? ''));
  }

  bool get isBusy =>
      status == FormStatus.submitting || status == FormStatus.success;

  bool get canSave => isValid && hasChanges && !isBusy;
}
