import 'package:connect_hub/core/common/result.dart';
import 'package:connect_hub/domain/repository/feed_repository.dart';
import 'package:injectable/injectable.dart';

/// Appends the next page to the cached feed. Returns whether there are older
/// posts still to load.
@injectable
class LoadMoreFeedUseCase {
  const LoadMoreFeedUseCase(this._feed);

  final FeedRepository _feed;

  Future<Result<bool>> call() => _feed.loadMore();
}
