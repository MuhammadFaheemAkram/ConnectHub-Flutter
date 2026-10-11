import 'dart:async';

import 'package:connect_hub/core/common/result.dart';
import 'package:connect_hub/domain/model/post.dart';
import 'package:connect_hub/domain/model/search_hits.dart';
import 'package:connect_hub/domain/model/search_results.dart';
import 'package:connect_hub/domain/model/user.dart';
import 'package:connect_hub/domain/repository/search_repository.dart';

/// A scriptable [SearchRepository] for the Search Bloc's tests.
///
/// Like the real one, `search` "caches" what it finds and answers with ids,
/// and `watchResults` reads them back live: [replacePost] changes a cached
/// post the way a like on another screen would.
class FakeSearchRepository implements SearchRepository {
  FakeSearchRepository({List<String> recentSearches = const []})
    : _recent = recentSearches;

  /// What the server finds for each (trimmed) query; any other query finds
  /// nothing.
  final answers = <String, SearchResults>{};

  /// While set, every search fails with it.
  Result<SearchHits>? failure;

  /// Holds a search for that query in flight until the completer completes.
  final gates = <String, Completer<void>>{};

  final searchCalls = <String>[];
  final saved = <String>[];
  int clearCalls = 0;

  final _users = <String, User>{};
  final _posts = <String, Post>{};
  final _changes = StreamController<void>.broadcast();

  List<String> _recent;
  final _recentChanges = StreamController<List<String>>.broadcast();

  @override
  Future<Result<SearchHits>> search(String query) async {
    searchCalls.add(query);
    await gates[query]?.future;
    if (failure case final failure?) return failure;
    final answer = answers[query] ?? const SearchResults();
    for (final user in answer.users) {
      _users[user.id] = user;
    }
    for (final post in answer.posts) {
      _posts[post.id] = post;
    }
    return Ok(
      SearchHits(
        userIds: [for (final user in answer.users) user.id],
        postIds: [for (final post in answer.posts) post.id],
      ),
    );
  }

  @override
  Stream<SearchResults> watchResults(SearchHits hits) {
    SearchResults read() => SearchResults(
      users: [for (final id in hits.userIds) ?_users[id]],
      posts: [for (final id in hits.postIds) ?_posts[id]],
    );
    return Stream.multi((watcher) {
      final subscription = _changes.stream.listen((_) => watcher.add(read()));
      watcher
        ..onCancel = subscription.cancel
        ..add(read());
    });
  }

  /// Changes a cached post, as another screen (a like, say) would.
  void replacePost(Post post) {
    _posts[post.id] = post;
    _changes.add(null);
  }

  @override
  Stream<List<String>> watchRecentSearches() => Stream.multi((watcher) {
    final subscription = _recentChanges.stream.listen(watcher.add);
    watcher
      ..onCancel = subscription.cancel
      ..add(_recent);
  });

  /// Records the save and, roughly like the real one, puts the query on top.
  @override
  Future<void> saveRecentSearch(String query) async {
    saved.add(query);
    _writeRecent([
      query,
      for (final recent in _recent)
        if (recent.toLowerCase() != query.toLowerCase()) recent,
    ]);
  }

  @override
  Future<void> clearRecentSearches() async {
    clearCalls++;
    _writeRecent(const []);
  }

  void _writeRecent(List<String> recent) {
    _recent = recent;
    _recentChanges.add(recent);
  }

  Future<void> dispose() async {
    await _changes.close();
    await _recentChanges.close();
  }
}
