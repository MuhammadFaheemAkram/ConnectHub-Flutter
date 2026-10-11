import 'package:connect_hub/core/common/demo_account.dart';
import 'package:connect_hub/domain/model/app_notification.dart';
import 'package:connect_hub/domain/model/comment.dart';
import 'package:connect_hub/domain/model/conversation.dart';
import 'package:connect_hub/domain/model/message.dart';
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

const grace = User(id: 'u_grace', name: 'Grace Hopper');
const alan = User(id: 'u_alan', name: 'Alan Turing');

/// A conversation with [participant], last active [minutesAgo] minutes
/// before noon UTC on the test day.
Conversation sampleConversation(
  String id, {
  User participant = grace,
  String lastMessage = 'Hello',
  int unreadCount = 0,
  int minutesAgo = 0,
}) => Conversation(
  id: id,
  participant: participant,
  lastMessage: lastMessage,
  unreadCount: unreadCount,
  updatedAt: DateTime.utc(
    2026,
    10,
    11,
    12,
  ).subtract(Duration(minutes: minutesAgo)),
);

/// A message in [conversationId]: mine, or from Grace.
Message sampleMessage(
  String id, {
  String conversationId = 'c1',
  bool isMine = false,
  MessageStatus status = MessageStatus.sent,
  int minutesAgo = 0,
}) => Message(
  id: id,
  conversationId: conversationId,
  senderId: isMine ? 'u_demo' : 'u_grace',
  text: 'Message $id',
  createdAt: DateTime.utc(
    2026,
    10,
    11,
    12,
  ).subtract(Duration(minutes: minutesAgo)),
  isMine: isMine,
  status: status,
);

/// A notification, [minutesAgo] minutes before noon UTC on the test day.
AppNotification sampleNotification(
  String id, {
  NotificationKind kind = NotificationKind.like,
  bool isRead = false,
  String? postId,
  String? userId,
  int minutesAgo = 0,
}) => AppNotification(
  id: id,
  kind: kind,
  text: 'Notification $id',
  createdAt: DateTime.utc(
    2026,
    10,
    11,
    12,
  ).subtract(Duration(minutes: minutesAgo)),
  isRead: isRead,
  postId: postId,
  userId: userId,
);
