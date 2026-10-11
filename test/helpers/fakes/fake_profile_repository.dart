import 'dart:async';

import 'package:connect_hub/core/common/result.dart';
import 'package:connect_hub/domain/model/post.dart';
import 'package:connect_hub/domain/model/user.dart';
import 'package:connect_hub/domain/repository/profile_repository.dart';

/// A scriptable [ProfileRepository]. Like drift, the watch methods emit the
/// cached value now, then after every change, announced asynchronously.
class FakeProfileRepository implements ProfileRepository {
  FakeProfileRepository({
    List<User> cachedUsers = const [],
    Map<String, List<Post>> cachedPosts = const {},
  }) {
    for (final user in cachedUsers) {
      _users[user.id] = user;
    }
    _posts.addAll(cachedPosts);
  }

  final _users = <String, User>{};
  final _posts = <String, List<Post>>{};
  final _changes = StreamController<String>.broadcast();

  /// What `refreshUser` answers; a success caches [refreshedUser] (if set).
  Result<void> refreshUserResult = const Ok(null);
  User? refreshedUser;
  Completer<void>? refreshUserGate;
  final refreshUserCalls = <String>[];

  /// What `refreshUserPosts` answers; a success caches [refreshedPosts] (if
  /// set) as that user's posts.
  Result<void> refreshPostsResult = const Ok(null);
  List<Post>? refreshedPosts;
  Completer<void>? refreshPostsGate;

  /// What `updateProfile` answers; a success caches the new profile.
  Result<void> updateResult = const Ok(null);
  Completer<void>? updateGate;
  final updateCalls = <({String name, String bio, String? avatarUrl})>[];

  @override
  Stream<User?> watchUser(String userId) =>
      _watch(userId, () => _users[userId]);

  @override
  Future<Result<void>> refreshUser(String userId) async {
    refreshUserCalls.add(userId);
    await refreshUserGate?.future;
    if (refreshUserResult is Ok<void>) {
      if (refreshedUser case final user?) replaceUser(user);
    }
    return refreshUserResult;
  }

  @override
  Stream<List<Post>> watchUserPosts(String userId) =>
      _watch(userId, () => _posts[userId] ?? const []);

  @override
  Future<Result<void>> refreshUserPosts(String userId) async {
    await refreshPostsGate?.future;
    if (refreshPostsResult is Ok<void>) {
      if (refreshedPosts case final posts?) replacePosts(userId, posts);
    }
    return refreshPostsResult;
  }

  @override
  Future<Result<void>> updateProfile({
    required String name,
    required String bio,
    String? avatarUrl,
  }) async {
    updateCalls.add((name: name, bio: bio, avatarUrl: avatarUrl));
    await updateGate?.future;
    return updateResult;
  }

  /// Changes a cached profile, as a refresh or an edit would.
  void replaceUser(User user) {
    _users[user.id] = user;
    _changes.add(user.id);
  }

  /// Changes a user's cached posts, as a like or a refresh would.
  void replacePosts(String userId, List<Post> posts) {
    _posts[userId] = posts;
    _changes.add(userId);
  }

  Stream<T> _watch<T>(String userId, T Function() read) =>
      Stream.multi((watcher) {
        final subscription = _changes.stream
            .where((id) => id == userId)
            .listen((_) => watcher.add(read()));
        watcher
          ..onCancel = subscription.cancel
          ..add(read());
      });

  Future<void> dispose() => _changes.close();
}
