import 'package:connect_hub/core/common/ui_message.dart';
import 'package:connect_hub/domain/model/post.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'bookmarks_state.freezed.dart';

/// Where the list stands. "Empty" is [loaded] with no posts.
enum BookmarksStatus {
  /// Nothing cached yet, and the server hasn't answered.
  loading,

  /// Showing what's cached (possibly nothing).
  loaded,

  /// Nothing cached, and fetching failed.
  failure,
}

/// One class rather than a union: the message must outlive the list.
/// Removing the last bookmark empties it, and the "Removed from bookmarks"
/// SnackBar must still offer Undo.
@freezed
abstract class BookmarksState with _$BookmarksState {
  const factory BookmarksState({
    @Default(BookmarksStatus.loading) BookmarksStatus status,

    /// The most recently bookmarked first.
    @Default(<Post>[]) List<Post> posts,
    @Default('') String errorMessage,

    /// A one-time SnackBar, possibly with Undo.
    UiMessage? message,
  }) = _BookmarksState;
}
