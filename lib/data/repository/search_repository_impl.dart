import 'package:clock/clock.dart';
import 'package:connect_hub/core/common/result.dart';
import 'package:connect_hub/core/database/daos/search_dao.dart';
import 'package:connect_hub/core/network/api/search_api_service.dart';
import 'package:connect_hub/data/mapper/post_mappers.dart';
import 'package:connect_hub/data/mapper/user_mappers.dart';
import 'package:connect_hub/data/repository/api_guard.dart';
import 'package:connect_hub/domain/model/search_hits.dart';
import 'package:connect_hub/domain/model/search_results.dart';
import 'package:connect_hub/domain/repository/search_repository.dart';
import 'package:injectable/injectable.dart';
import 'package:stream_transform/stream_transform.dart';

/// Search through the server, with results kept live by the cache.
///
/// The server's answer is cached like any other (people as users, posts as
/// posts; never in the feed), and the screen reads it back by id. So the
/// results follow every change made elsewhere: like a post from its detail
/// screen, come back, and the heart in the results is already red.
@LazySingleton(as: SearchRepository)
class SearchRepositoryImpl implements SearchRepository {
  SearchRepositoryImpl(this._api, this._search, this._guard, this._clock);

  final SearchApiService _api;
  final SearchDao _search;
  final ApiGuard _guard;
  final Clock _clock;

  @override
  Future<Result<SearchHits>> search(String query) async {
    final result = await _guard.run(() => _api.search(query));
    switch (result) {
      case Ok(value: final response):
        await _search.cacheResults(
          people: [for (final user in response.users) user.toRow()],
          posts: [for (final post in response.posts) post.toCached()],
        );
        return Ok(
          SearchHits(
            userIds: [for (final user in response.users) user.id],
            postIds: [for (final post in response.posts) post.id],
          ),
        );
      case Err(:final exception):
        return Err(exception);
    }
  }

  /// Two live queries, one per section, merged with `combineLatest`: it
  /// waits for both to answer once, then emits whenever either changes.
  @override
  Stream<SearchResults> watchResults(SearchHits hits) {
    final users = _search
        .watchUsers(hits.userIds)
        .map((rows) => [for (final row in rows) row.toDomain()]);
    final posts = _search
        .watchPosts(hits.postIds)
        .map((entries) => [for (final entry in entries) entry.toDomain()]);
    return users.combineLatest(
      posts,
      (users, posts) => SearchResults(
        // SQL returns rows in no particular order: put them back in the
        // server's.
        users: _inOrder(hits.userIds, users, (user) => user.id),
        posts: _inOrder(hits.postIds, posts, (post) => post.id),
      ),
    );
  }

  @override
  Stream<List<String>> watchRecentSearches() => _search
      .watchRecentSearches()
      .map((rows) => [for (final row in rows) row.displayText]);

  @override
  Future<void> saveRecentSearch(String query) =>
      _search.saveRecentSearch(query, at: _clock.now().toUtc());

  @override
  Future<void> clearRecentSearches() => _search.clearRecentSearches();

  /// [items] in the order of [ids]. An id that is no longer cached is
  /// skipped.
  static List<T> _inOrder<T>(
    List<String> ids,
    List<T> items,
    String Function(T item) idOf,
  ) {
    final byId = {for (final item in items) idOf(item): item};
    return [for (final id in ids) ?byId[id]];
  }
}
