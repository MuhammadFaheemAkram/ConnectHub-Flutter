import 'package:connect_hub/core/common/demo_account.dart';
import 'package:connect_hub/domain/model/post.dart';
import 'package:connect_hub/domain/model/session.dart';
import 'package:connect_hub/domain/model/user.dart';

const demoSession = Session(
  userId: 'u_demo',
  email: DemoAccount.email,
  token: 'fake.u_demo.0123456789abcdef',
);

const ada = User(id: 'u_ada', name: 'Ada Lovelace');

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
