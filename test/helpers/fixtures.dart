import 'package:connect_hub/core/common/demo_account.dart';
import 'package:connect_hub/domain/model/comment.dart';
import 'package:connect_hub/domain/model/post.dart';
import 'package:connect_hub/domain/model/session.dart';
import 'package:connect_hub/domain/model/user.dart';

const demoSession = Session(
  userId: 'u_demo',
  email: DemoAccount.email,
  token: 'fake.u_demo.0123456789abcdef',
);

const ada = User(id: 'u_ada', name: 'Ada Lovelace');
const demoUser = User(id: 'u_demo', name: 'Demo User');

/// A post by [ada], posted at [createdAt] (default: 11:00 UTC on the test
/// day), with only what a test needs to tell it apart.
Post samplePost(
  String id, {
  int likeCount = 10,
  int commentCount = 0,
  bool isLiked = false,
  bool isBookmarked = false,
  String? imageUrl,
  DateTime? createdAt,
}) => Post(
  id: id,
  author: ada,
  content: 'Post $id',
  imageUrl: imageUrl,
  createdAt: createdAt ?? DateTime.utc(2026, 10, 11, 11),
  likeCount: likeCount,
  commentCount: commentCount,
  isLiked: isLiked,
  isBookmarked: isBookmarked,
);

/// A comment on `p1`, by [ada] or (when [isMine]) by the demo user, posted
/// [minutesAgo] minutes before noon UTC on the test day.
Comment sampleComment(
  String id, {
  String postId = 'p1',
  bool isMine = false,
  int minutesAgo = 0,
}) => Comment(
  id: id,
  postId: postId,
  author: isMine ? demoUser : ada,
  text: 'Comment $id',
  createdAt: DateTime.utc(
    2026,
    10,
    11,
    12,
  ).subtract(Duration(minutes: minutesAgo)),
  isMine: isMine,
);
