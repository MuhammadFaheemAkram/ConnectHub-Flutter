import 'package:connect_hub/core/common/ui_message.dart';
import 'package:connect_hub/domain/model/post.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'feed_state.freezed.dart';

/// Where loading the next page stands. The list's footer shows it.
enum LoadMoreStatus { idle, loading, failed }

@freezed
sealed class FeedState with _$FeedState {
  /// Nothing is cached yet, and the server hasn't answered.
  const factory FeedState.loading() = FeedLoading;

  /// The server has no posts.
  const factory FeedState.empty() = FeedEmpty;

  /// Nothing is cached, and the refresh failed.
  const factory FeedState.error(String message) = FeedError;

  /// Posts to show, from the cache. They stay on screen when a refresh fails:
  /// the failure is reported through [message] instead.
  const factory FeedState.loaded({
    required List<Post> posts,

    /// Whether older posts can still be loaded.
    @Default(true) bool hasMore,
    @Default(LoadMoreStatus.idle) LoadMoreStatus loadMore,

    /// A one-time SnackBar.
    UiMessage? message,
  }) = FeedLoaded;
}
