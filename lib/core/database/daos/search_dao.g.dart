// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: type=lint

part of 'search_dao.dart';

// ignore_for_file: type=lint
mixin _$SearchDaoMixin on DatabaseAccessor<AppDatabase> {
  $UsersTable get users => attachedDatabase.users;
  $PostsTable get posts => attachedDatabase.posts;
  $BookmarksTable get bookmarks => attachedDatabase.bookmarks;
  $RecentSearchesTable get recentSearches => attachedDatabase.recentSearches;
  SearchDaoManager get managers => SearchDaoManager(this);
}

class SearchDaoManager {
  final _$SearchDaoMixin _db;
  SearchDaoManager(this._db);
  $$UsersTableTableManager get users =>
      $$UsersTableTableManager(_db.attachedDatabase, _db.users);
  $$PostsTableTableManager get posts =>
      $$PostsTableTableManager(_db.attachedDatabase, _db.posts);
  $$BookmarksTableTableManager get bookmarks =>
      $$BookmarksTableTableManager(_db.attachedDatabase, _db.bookmarks);
  $$RecentSearchesTableTableManager get recentSearches =>
      $$RecentSearchesTableTableManager(
        _db.attachedDatabase,
        _db.recentSearches,
      );
}
