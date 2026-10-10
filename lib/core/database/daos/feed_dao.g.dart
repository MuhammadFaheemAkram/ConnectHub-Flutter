// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: type=lint

part of 'feed_dao.dart';

// ignore_for_file: type=lint
mixin _$FeedDaoMixin on DatabaseAccessor<AppDatabase> {
  $UsersTable get users => attachedDatabase.users;
  $PostsTable get posts => attachedDatabase.posts;
  $FeedItemsTable get feedItems => attachedDatabase.feedItems;
  $BookmarksTable get bookmarks => attachedDatabase.bookmarks;
  FeedDaoManager get managers => FeedDaoManager(this);
}

class FeedDaoManager {
  final _$FeedDaoMixin _db;
  FeedDaoManager(this._db);
  $$UsersTableTableManager get users =>
      $$UsersTableTableManager(_db.attachedDatabase, _db.users);
  $$PostsTableTableManager get posts =>
      $$PostsTableTableManager(_db.attachedDatabase, _db.posts);
  $$FeedItemsTableTableManager get feedItems =>
      $$FeedItemsTableTableManager(_db.attachedDatabase, _db.feedItems);
  $$BookmarksTableTableManager get bookmarks =>
      $$BookmarksTableTableManager(_db.attachedDatabase, _db.bookmarks);
}
