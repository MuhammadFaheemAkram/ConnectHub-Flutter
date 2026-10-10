import 'package:connect_hub/domain/model/post.dart';
import 'package:connect_hub/domain/repository/feed_repository.dart';
import 'package:injectable/injectable.dart';

/// The cached feed as a stream: the current window, then every change.
@injectable
class WatchFeedUseCase {
  const WatchFeedUseCase(this._feed);

  final FeedRepository _feed;

  Stream<List<Post>> call() => _feed.watchFeed();
}
