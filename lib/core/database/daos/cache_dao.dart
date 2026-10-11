import 'package:connect_hub/core/database/app_database.dart';
import 'package:connect_hub/core/database/tables/bookmarks_table.dart';
import 'package:connect_hub/core/database/tables/comments_table.dart';
import 'package:connect_hub/core/database/tables/conversations_table.dart';
import 'package:connect_hub/core/database/tables/feed_items_table.dart';
import 'package:connect_hub/core/database/tables/messages_table.dart';
import 'package:connect_hub/core/database/tables/notifications_table.dart';
import 'package:connect_hub/core/database/tables/posts_table.dart';
import 'package:connect_hub/core/database/tables/recent_searches_table.dart';
import 'package:connect_hub/core/database/tables/users_table.dart';
import 'package:drift/drift.dart';

part 'cache_dao.g.dart';

/// Whole-cache operations.
@DriftAccessor(
  tables: [
    Comments,
    FeedItems,
    Bookmarks,
    Posts,
    Users,
    RecentSearches,
    Conversations,
    Messages,
    Notifications,
  ],
)
class CacheDao extends DatabaseAccessor<AppDatabase> with _$CacheDaoMixin {
  CacheDao(super.attachedDatabase);

  /// Deletes everything cached, and the recent searches. Used when the
  /// session ends (logout or expiry): it all belongs to the signed-in user,
  /// and the next one must never see it (Correctness Rule 2).
  ///
  /// Children before parents, because posts, comments and conversations
  /// reference users without a cascade. A table added in a later schema
  /// version must be added here too (a test checks every table ends up
  /// empty).
  Future<void> clearAll() {
    return transaction(() async {
      await delete(recentSearches).go();
      await delete(notifications).go();
      await delete(messages).go();
      await delete(conversations).go();
      await delete(comments).go();
      await delete(feedItems).go();
      await delete(bookmarks).go();
      await delete(posts).go();
      await delete(users).go();
    });
  }

  /// "Clear cache" in Settings: deletes the cached copy of what the server
  /// owns (the feed, posts, comments, profiles, chats, notifications), which
  /// the screens fetch again. It keeps:
  /// - bookmarked posts and their authors, so Bookmarks still works offline;
  /// - the signed-in user ([keepUserId]);
  /// - unsent and failed messages, with their conversations: they are the
  ///   user's words, not on the server yet (Correctness Rule 7);
  /// - the recent searches, which the client owns.
  Future<void> clearServerData({required String keepUserId}) {
    return transaction(() async {
      await delete(feedItems).go();
      await delete(comments).go();
      await delete(notifications).go();
      await (delete(messages)..where(
            (message) => message.status.equalsValue(MessageRowStatus.sent),
          ))
          .go();
      final withMessages = selectOnly(messages)
        ..addColumns([messages.conversationId]);
      await (delete(conversations)..where(
            (conversation) => conversation.id.isNotInQuery(withMessages),
          ))
          .go();
      final bookmarked = selectOnly(bookmarks)..addColumns([bookmarks.postId]);
      await (delete(
        posts,
      )..where((post) => post.id.isNotInQuery(bookmarked))).go();
      final authors = selectOnly(posts)..addColumns([posts.authorId]);
      final participants = selectOnly(conversations)
        ..addColumns([conversations.participantId]);
      await (delete(users)..where(
            (user) =>
                user.id.equals(keepUserId).not() &
                user.id.isNotInQuery(authors) &
                user.id.isNotInQuery(participants),
          ))
          .go();
    });
  }
}
