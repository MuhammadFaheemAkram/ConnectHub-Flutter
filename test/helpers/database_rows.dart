import 'package:connect_hub/core/database/app_database.dart';
import 'package:connect_hub/core/database/daos/posts_dao.dart';

import 'backend.dart';

/// Row builders for the DAO tests: just enough to tell rows apart.

UserRow userRow(String id, {String? name}) => UserRow(
  id: id,
  name: name ?? 'User $id',
  bio: '',
  followersCount: 0,
  followingCount: 0,
);

/// A post by [authorId], [minutesAgo] minutes before [testNow].
CachedPost cachedPost(
  String id, {
  String authorId = 'u_ada',
  int minutesAgo = 0,
  int likeCount = 10,
  bool isLiked = false,
  DateTime? bookmarkedAt,
}) => (
  post: PostRow(
    id: id,
    authorId: authorId,
    content: 'Post $id',
    createdAt: testNow.subtract(Duration(minutes: minutesAgo)),
    likeCount: likeCount,
    commentCount: 0,
    isLiked: isLiked,
  ),
  author: userRow(authorId),
  bookmarkedAt: bookmarkedAt,
);
