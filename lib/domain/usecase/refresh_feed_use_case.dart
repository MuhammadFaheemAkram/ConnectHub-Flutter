import 'package:connect_hub/core/common/result.dart';
import 'package:connect_hub/domain/repository/feed_repository.dart';
import 'package:injectable/injectable.dart';

/// Replaces the cached feed with the newest page. Returns whether there are
/// older posts to load.
@injectable
class RefreshFeedUseCase {
  const RefreshFeedUseCase(this._feed);

  final FeedRepository _feed;

  Future<Result<bool>> call() => _feed.refresh();
}
