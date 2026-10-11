import 'package:connect_hub/core/common/form_status.dart';
import 'package:connect_hub/core/common/validators.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'create_post_state.freezed.dart';

@freezed
abstract class CreatePostState with _$CreatePostState {
  const CreatePostState._();

  const factory CreatePostState({
    @Default('') String content,
    @Default('') String imageUrl,
    @Default(FormStatus.idle) FormStatus status,

    /// Why the last submit failed, from the server.
    String? errorMessage,
  }) = _CreatePostState;

  /// What the counter shows: characters as people count them.
  int get length => Validators.lengthOf(content);

  /// Errors appear once there is something to judge. An untouched form is
  /// not an error, so its Post button is simply disabled.
  String? get contentError =>
      content.isEmpty ? null : Validators.postContent(content);

  String? get imageUrlError => Validators.imageUrl(imageUrl);

  bool get isValid =>
      Validators.postContent(content) == null && imageUrlError == null;

  bool get isBusy =>
      status == FormStatus.submitting || status == FormStatus.success;

  bool get canSubmit => isValid && !isBusy;

  /// Whether leaving would lose something worth a "Discard post?".
  bool get hasDraft => content.trim().isNotEmpty || imageUrl.trim().isNotEmpty;
}
