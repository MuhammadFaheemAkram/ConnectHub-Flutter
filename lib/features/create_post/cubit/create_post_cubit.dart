import 'package:connect_hub/core/common/form_status.dart';
import 'package:connect_hub/core/common/result.dart';
import 'package:connect_hub/domain/usecase/create_post_use_case.dart';
import 'package:connect_hub/features/create_post/cubit/create_post_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

/// Drives the Create Post form.
///
/// A Cubit, unlike the sign-in forms' Blocs: Post is disabled while a submit
/// runs (`canSubmit`), so there is no double tap to drop, and nothing else
/// needs an event transformer. The rules come from `Validators`, shared with
/// the fake server.
@injectable
class CreatePostCubit extends Cubit<CreatePostState> {
  CreatePostCubit(this._createPost) : super(const CreatePostState());

  final CreatePostUseCase _createPost;

  void contentChanged(String value) =>
      emit(_edited(state.copyWith(content: value)));

  void imageUrlChanged(String value) =>
      emit(_edited(state.copyWith(imageUrl: value)));

  /// Publishes the post. On success the status becomes `success` and the
  /// View closes the page; on failure the input stays and the server's
  /// message shows.
  Future<void> submit() async {
    if (!state.canSubmit) return;
    emit(state.copyWith(status: FormStatus.submitting, errorMessage: null));
    final result = await _createPost(
      content: state.content,
      imageUrl: state.imageUrl,
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
  CreatePostState _edited(CreatePostState next) =>
      next.status == FormStatus.failure
      ? next.copyWith(status: FormStatus.idle, errorMessage: null)
      : next;
}
