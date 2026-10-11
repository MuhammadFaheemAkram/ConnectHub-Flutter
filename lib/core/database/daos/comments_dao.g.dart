// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: type=lint

part of 'comments_dao.dart';

// ignore_for_file: type=lint
mixin _$CommentsDaoMixin on DatabaseAccessor<AppDatabase> {
  $UsersTable get users => attachedDatabase.users;
  $PostsTable get posts => attachedDatabase.posts;
  $CommentsTable get comments => attachedDatabase.comments;
  CommentsDaoManager get managers => CommentsDaoManager(this);
}

class CommentsDaoManager {
  final _$CommentsDaoMixin _db;
  CommentsDaoManager(this._db);
  $$UsersTableTableManager get users =>
      $$UsersTableTableManager(_db.attachedDatabase, _db.users);
  $$PostsTableTableManager get posts =>
      $$PostsTableTableManager(_db.attachedDatabase, _db.posts);
  $$CommentsTableTableManager get comments =>
      $$CommentsTableTableManager(_db.attachedDatabase, _db.comments);
}
