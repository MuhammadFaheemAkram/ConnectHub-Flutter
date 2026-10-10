// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: type=lint

part of 'posts_dao.dart';

// ignore_for_file: type=lint
mixin _$PostsDaoMixin on DatabaseAccessor<AppDatabase> {
  $UsersTable get users => attachedDatabase.users;
  $PostsTable get posts => attachedDatabase.posts;
  $BookmarksTable get bookmarks => attachedDatabase.bookmarks;
  PostsDaoManager get managers => PostsDaoManager(this);
}

class PostsDaoManager {
  final _$PostsDaoMixin _db;
  PostsDaoManager(this._db);
  $$UsersTableTableManager get users =>
      $$UsersTableTableManager(_db.attachedDatabase, _db.users);
  $$PostsTableTableManager get posts =>
      $$PostsTableTableManager(_db.attachedDatabase, _db.posts);
  $$BookmarksTableTableManager get bookmarks =>
      $$BookmarksTableTableManager(_db.attachedDatabase, _db.bookmarks);
}
