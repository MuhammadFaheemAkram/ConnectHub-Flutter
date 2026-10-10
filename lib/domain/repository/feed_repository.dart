import 'package:connect_hub/core/common/result.dart';
import 'package:connect_hub/domain/model/post.dart';

/// The home feed: a cached window of posts that the server pages in.
///
/// The screen only ever renders [watchFeed]. [refresh] and [loadMore] change
/// the cached window, and the change reaches the screen through that same
/// stream, so the network never drives the UI directly.
abstract interface class FeedRepository {
  /// The cached window, newest first: the current window, then every change.
  Stream<List<Post>> watchFeed();

  /// Fetches the newest page and makes it the whole window.
  ///
  /// Returns whether there are older posts to load.
  Future<Result<bool>> refresh();

  /// Fetches the page after the window and appends it.
  ///
  /// Returns whether there are older posts still to load.
  Future<Result<bool>> loadMore();
}
