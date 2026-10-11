import 'package:connect_hub/core/database/app_database.dart';
import 'package:connect_hub/core/database/daos/chat_dao.dart';
import 'package:connect_hub/core/database/daos/comments_dao.dart';
import 'package:connect_hub/core/database/daos/posts_dao.dart';
import 'package:connect_hub/core/database/tables/messages_table.dart';
import 'package:connect_hub/core/database/tables/notifications_table.dart';

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

/// A comment on [postId] by [authorId], [minutesAgo] minutes before
/// [testNow].
CachedComment cachedComment(
  String id, {
  String postId = 'p1',
  String authorId = 'u_grace',
  int minutesAgo = 0,
}) => (
  comment: CommentRow(
    id: id,
    postId: postId,
    authorId: authorId,
    content: 'Comment $id',
    createdAt: testNow.subtract(Duration(minutes: minutesAgo)),
  ),
  author: userRow(authorId),
);

/// A conversation with [participantId], last active [minutesAgo] minutes
/// before [testNow].
CachedConversation cachedConversation(
  String id, {
  String participantId = 'u_grace',
  String? participantName,
  int unreadCount = 0,
  int minutesAgo = 0,
  String lastMessage = 'Hello',
}) => (
  conversation: ConversationRow(
    id: id,
    participantId: participantId,
    lastMessage: lastMessage,
    unreadCount: unreadCount,
    updatedAt: testNow.subtract(Duration(minutes: minutesAgo)),
  ),
  participant: userRow(participantId, name: participantName),
);

/// A message in [conversationId], [minutesAgo] minutes before [testNow].
MessageRow messageRow(
  String id, {
  String conversationId = 'c1',
  String senderId = 'u_grace',
  MessageRowStatus status = MessageRowStatus.sent,
  int minutesAgo = 0,
}) => MessageRow(
  id: id,
  conversationId: conversationId,
  senderId: senderId,
  content: 'Message $id',
  createdAt: testNow.subtract(Duration(minutes: minutesAgo)),
  status: status,
);

/// A notification, [minutesAgo] minutes before [testNow].
NotificationRow notificationRow(
  String id, {
  bool isRead = false,
  int minutesAgo = 0,
  NotificationRowKind kind = NotificationRowKind.like,
  String? postId,
  String? userId,
}) => NotificationRow(
  id: id,
  kind: kind,
  content: 'Notification $id',
  createdAt: testNow.subtract(Duration(minutes: minutesAgo)),
  isRead: isRead,
  postId: postId,
  userId: userId,
);
