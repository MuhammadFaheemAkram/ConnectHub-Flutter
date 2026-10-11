import 'package:connect_hub/core/common/ui_message.dart';
import 'package:connect_hub/domain/model/post.dart';
import 'package:connect_hub/domain/model/user.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'profile_state.freezed.dart';

@freezed
sealed class ProfileState with _$ProfileState {
  /// The profile isn't cached, and the server hasn't answered yet.
  const factory ProfileState.loading() = ProfileLoading;

  /// The profile isn't cached, and fetching it failed.
  const factory ProfileState.error(String message) = ProfileError;

  /// The server has no such user: "This profile isn't available."
  const factory ProfileState.notFound() = ProfileNotFound;

  const factory ProfileState.loaded({
    required User user,

    /// Newest first.
    @Default(<Post>[]) List<Post> posts,

    /// No posts are cached yet, and the first fetch is still running.
    @Default(false) bool isLoadingPosts,

    /// A one-time SnackBar.
    UiMessage? message,
  }) = ProfileLoaded;
}
