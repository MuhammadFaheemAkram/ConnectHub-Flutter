// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: type=lint

part of 'cache_dao.dart';

// ignore_for_file: type=lint
mixin _$CacheDaoMixin on DatabaseAccessor<AppDatabase> {
  $UsersTable get users => attachedDatabase.users;
  $PostsTable get posts => attachedDatabase.posts;
  $CommentsTable get comments => attachedDatabase.comments;
  $FeedItemsTable get feedItems => attachedDatabase.feedItems;
  $BookmarksTable get bookmarks => attachedDatabase.bookmarks;
  CacheDaoManager get managers => CacheDaoManager(this);
}

class CacheDaoManager {
  final _$CacheDaoMixin _db;
  CacheDaoManager(this._db);
  $$UsersTableTableManager get users =>
      $$UsersTableTableManager(_db.attachedDatabase, _db.users);
  $$PostsTableTableManager get posts =>
      $$PostsTableTableManager(_db.attachedDatabase, _db.posts);
  $$CommentsTableTableManager get comments =>
      $$CommentsTableTableManager(_db.attachedDatabase, _db.comments);
  $$FeedItemsTableTableManager get feedItems =>
      $$FeedItemsTableTableManager(_db.attachedDatabase, _db.feedItems);
  $$BookmarksTableTableManager get bookmarks =>
      $$BookmarksTableTableManager(_db.attachedDatabase, _db.bookmarks);
}
