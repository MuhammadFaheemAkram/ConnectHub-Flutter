// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: type=lint

part of 'app_database.dart';

// ignore_for_file: type=lint
class $UsersTable extends Users with TableInfo<$UsersTable, UserRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UsersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _avatarUrlMeta = const VerificationMeta(
    'avatarUrl',
  );
  @override
  late final GeneratedColumn<String> avatarUrl = GeneratedColumn<String>(
    'avatar_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _bioMeta = const VerificationMeta('bio');
  @override
  late final GeneratedColumn<String> bio = GeneratedColumn<String>(
    'bio',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _followersCountMeta = const VerificationMeta(
    'followersCount',
  );
  @override
  late final GeneratedColumn<int> followersCount = GeneratedColumn<int>(
    'followers_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _followingCountMeta = const VerificationMeta(
    'followingCount',
  );
  @override
  late final GeneratedColumn<int> followingCount = GeneratedColumn<int>(
    'following_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    avatarUrl,
    bio,
    followersCount,
    followingCount,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'users';
  @override
  VerificationContext validateIntegrity(
    Insertable<UserRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('avatar_url')) {
      context.handle(
        _avatarUrlMeta,
        avatarUrl.isAcceptableOrUnknown(data['avatar_url']!, _avatarUrlMeta),
      );
    }
    if (data.containsKey('bio')) {
      context.handle(
        _bioMeta,
        bio.isAcceptableOrUnknown(data['bio']!, _bioMeta),
      );
    } else if (isInserting) {
      context.missing(_bioMeta);
    }
    if (data.containsKey('followers_count')) {
      context.handle(
        _followersCountMeta,
        followersCount.isAcceptableOrUnknown(
          data['followers_count']!,
          _followersCountMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_followersCountMeta);
    }
    if (data.containsKey('following_count')) {
      context.handle(
        _followingCountMeta,
        followingCount.isAcceptableOrUnknown(
          data['following_count']!,
          _followingCountMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_followingCountMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  UserRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      avatarUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}avatar_url'],
      ),
      bio: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}bio'],
      )!,
      followersCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}followers_count'],
      )!,
      followingCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}following_count'],
      )!,
    );
  }

  @override
  $UsersTable createAlias(String alias) {
    return $UsersTable(attachedDatabase, alias);
  }
}

class UserRow extends DataClass implements Insertable<UserRow> {
  final String id;
  final String name;
  final String? avatarUrl;
  final String bio;
  final int followersCount;
  final int followingCount;
  const UserRow({
    required this.id,
    required this.name,
    this.avatarUrl,
    required this.bio,
    required this.followersCount,
    required this.followingCount,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || avatarUrl != null) {
      map['avatar_url'] = Variable<String>(avatarUrl);
    }
    map['bio'] = Variable<String>(bio);
    map['followers_count'] = Variable<int>(followersCount);
    map['following_count'] = Variable<int>(followingCount);
    return map;
  }

  UsersCompanion toCompanion(bool nullToAbsent) {
    return UsersCompanion(
      id: Value(id),
      name: Value(name),
      avatarUrl: avatarUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(avatarUrl),
      bio: Value(bio),
      followersCount: Value(followersCount),
      followingCount: Value(followingCount),
    );
  }

  factory UserRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserRow(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      avatarUrl: serializer.fromJson<String?>(json['avatarUrl']),
      bio: serializer.fromJson<String>(json['bio']),
      followersCount: serializer.fromJson<int>(json['followersCount']),
      followingCount: serializer.fromJson<int>(json['followingCount']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'avatarUrl': serializer.toJson<String?>(avatarUrl),
      'bio': serializer.toJson<String>(bio),
      'followersCount': serializer.toJson<int>(followersCount),
      'followingCount': serializer.toJson<int>(followingCount),
    };
  }

  UserRow copyWith({
    String? id,
    String? name,
    Value<String?> avatarUrl = const Value.absent(),
    String? bio,
    int? followersCount,
    int? followingCount,
  }) => UserRow(
    id: id ?? this.id,
    name: name ?? this.name,
    avatarUrl: avatarUrl.present ? avatarUrl.value : this.avatarUrl,
    bio: bio ?? this.bio,
    followersCount: followersCount ?? this.followersCount,
    followingCount: followingCount ?? this.followingCount,
  );
  UserRow copyWithCompanion(UsersCompanion data) {
    return UserRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      avatarUrl: data.avatarUrl.present ? data.avatarUrl.value : this.avatarUrl,
      bio: data.bio.present ? data.bio.value : this.bio,
      followersCount: data.followersCount.present
          ? data.followersCount.value
          : this.followersCount,
      followingCount: data.followingCount.present
          ? data.followingCount.value
          : this.followingCount,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('avatarUrl: $avatarUrl, ')
          ..write('bio: $bio, ')
          ..write('followersCount: $followersCount, ')
          ..write('followingCount: $followingCount')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, name, avatarUrl, bio, followersCount, followingCount);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.avatarUrl == this.avatarUrl &&
          other.bio == this.bio &&
          other.followersCount == this.followersCount &&
          other.followingCount == this.followingCount);
}

class UsersCompanion extends UpdateCompanion<UserRow> {
  final Value<String> id;
  final Value<String> name;
  final Value<String?> avatarUrl;
  final Value<String> bio;
  final Value<int> followersCount;
  final Value<int> followingCount;
  final Value<int> rowid;
  const UsersCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.avatarUrl = const Value.absent(),
    this.bio = const Value.absent(),
    this.followersCount = const Value.absent(),
    this.followingCount = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UsersCompanion.insert({
    required String id,
    required String name,
    this.avatarUrl = const Value.absent(),
    required String bio,
    required int followersCount,
    required int followingCount,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       bio = Value(bio),
       followersCount = Value(followersCount),
       followingCount = Value(followingCount);
  static Insertable<UserRow> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? avatarUrl,
    Expression<String>? bio,
    Expression<int>? followersCount,
    Expression<int>? followingCount,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (avatarUrl != null) 'avatar_url': avatarUrl,
      if (bio != null) 'bio': bio,
      if (followersCount != null) 'followers_count': followersCount,
      if (followingCount != null) 'following_count': followingCount,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UsersCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String?>? avatarUrl,
    Value<String>? bio,
    Value<int>? followersCount,
    Value<int>? followingCount,
    Value<int>? rowid,
  }) {
    return UsersCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      bio: bio ?? this.bio,
      followersCount: followersCount ?? this.followersCount,
      followingCount: followingCount ?? this.followingCount,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (avatarUrl.present) {
      map['avatar_url'] = Variable<String>(avatarUrl.value);
    }
    if (bio.present) {
      map['bio'] = Variable<String>(bio.value);
    }
    if (followersCount.present) {
      map['followers_count'] = Variable<int>(followersCount.value);
    }
    if (followingCount.present) {
      map['following_count'] = Variable<int>(followingCount.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UsersCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('avatarUrl: $avatarUrl, ')
          ..write('bio: $bio, ')
          ..write('followersCount: $followersCount, ')
          ..write('followingCount: $followingCount, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PostsTable extends Posts with TableInfo<$PostsTable, PostRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PostsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _authorIdMeta = const VerificationMeta(
    'authorId',
  );
  @override
  late final GeneratedColumn<String> authorId = GeneratedColumn<String>(
    'author_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES users (id)',
    ),
  );
  static const VerificationMeta _contentMeta = const VerificationMeta(
    'content',
  );
  @override
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
    'content',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _imageUrlMeta = const VerificationMeta(
    'imageUrl',
  );
  @override
  late final GeneratedColumn<String> imageUrl = GeneratedColumn<String>(
    'image_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _likeCountMeta = const VerificationMeta(
    'likeCount',
  );
  @override
  late final GeneratedColumn<int> likeCount = GeneratedColumn<int>(
    'like_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _commentCountMeta = const VerificationMeta(
    'commentCount',
  );
  @override
  late final GeneratedColumn<int> commentCount = GeneratedColumn<int>(
    'comment_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isLikedMeta = const VerificationMeta(
    'isLiked',
  );
  @override
  late final GeneratedColumn<bool> isLiked = GeneratedColumn<bool>(
    'is_liked',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_liked" IN (0, 1))',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    authorId,
    content,
    imageUrl,
    createdAt,
    likeCount,
    commentCount,
    isLiked,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'posts';
  @override
  VerificationContext validateIntegrity(
    Insertable<PostRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('author_id')) {
      context.handle(
        _authorIdMeta,
        authorId.isAcceptableOrUnknown(data['author_id']!, _authorIdMeta),
      );
    } else if (isInserting) {
      context.missing(_authorIdMeta);
    }
    if (data.containsKey('content')) {
      context.handle(
        _contentMeta,
        content.isAcceptableOrUnknown(data['content']!, _contentMeta),
      );
    } else if (isInserting) {
      context.missing(_contentMeta);
    }
    if (data.containsKey('image_url')) {
      context.handle(
        _imageUrlMeta,
        imageUrl.isAcceptableOrUnknown(data['image_url']!, _imageUrlMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('like_count')) {
      context.handle(
        _likeCountMeta,
        likeCount.isAcceptableOrUnknown(data['like_count']!, _likeCountMeta),
      );
    } else if (isInserting) {
      context.missing(_likeCountMeta);
    }
    if (data.containsKey('comment_count')) {
      context.handle(
        _commentCountMeta,
        commentCount.isAcceptableOrUnknown(
          data['comment_count']!,
          _commentCountMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_commentCountMeta);
    }
    if (data.containsKey('is_liked')) {
      context.handle(
        _isLikedMeta,
        isLiked.isAcceptableOrUnknown(data['is_liked']!, _isLikedMeta),
      );
    } else if (isInserting) {
      context.missing(_isLikedMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PostRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PostRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      authorId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}author_id'],
      )!,
      content: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content'],
      )!,
      imageUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}image_url'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      likeCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}like_count'],
      )!,
      commentCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}comment_count'],
      )!,
      isLiked: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_liked'],
      )!,
    );
  }

  @override
  $PostsTable createAlias(String alias) {
    return $PostsTable(attachedDatabase, alias);
  }
}

class PostRow extends DataClass implements Insertable<PostRow> {
  final String id;
  final String authorId;
  final String content;
  final String? imageUrl;

  /// UTC, stored as ISO-8601 text (see `build.yaml`).
  final DateTime createdAt;
  final int likeCount;
  final int commentCount;

  /// Whether the signed-in user likes the post. The cache only ever holds one
  /// user's data: logout wipes it.
  final bool isLiked;
  const PostRow({
    required this.id,
    required this.authorId,
    required this.content,
    this.imageUrl,
    required this.createdAt,
    required this.likeCount,
    required this.commentCount,
    required this.isLiked,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['author_id'] = Variable<String>(authorId);
    map['content'] = Variable<String>(content);
    if (!nullToAbsent || imageUrl != null) {
      map['image_url'] = Variable<String>(imageUrl);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['like_count'] = Variable<int>(likeCount);
    map['comment_count'] = Variable<int>(commentCount);
    map['is_liked'] = Variable<bool>(isLiked);
    return map;
  }

  PostsCompanion toCompanion(bool nullToAbsent) {
    return PostsCompanion(
      id: Value(id),
      authorId: Value(authorId),
      content: Value(content),
      imageUrl: imageUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(imageUrl),
      createdAt: Value(createdAt),
      likeCount: Value(likeCount),
      commentCount: Value(commentCount),
      isLiked: Value(isLiked),
    );
  }

  factory PostRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PostRow(
      id: serializer.fromJson<String>(json['id']),
      authorId: serializer.fromJson<String>(json['authorId']),
      content: serializer.fromJson<String>(json['content']),
      imageUrl: serializer.fromJson<String?>(json['imageUrl']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      likeCount: serializer.fromJson<int>(json['likeCount']),
      commentCount: serializer.fromJson<int>(json['commentCount']),
      isLiked: serializer.fromJson<bool>(json['isLiked']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'authorId': serializer.toJson<String>(authorId),
      'content': serializer.toJson<String>(content),
      'imageUrl': serializer.toJson<String?>(imageUrl),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'likeCount': serializer.toJson<int>(likeCount),
      'commentCount': serializer.toJson<int>(commentCount),
      'isLiked': serializer.toJson<bool>(isLiked),
    };
  }

  PostRow copyWith({
    String? id,
    String? authorId,
    String? content,
    Value<String?> imageUrl = const Value.absent(),
    DateTime? createdAt,
    int? likeCount,
    int? commentCount,
    bool? isLiked,
  }) => PostRow(
    id: id ?? this.id,
    authorId: authorId ?? this.authorId,
    content: content ?? this.content,
    imageUrl: imageUrl.present ? imageUrl.value : this.imageUrl,
    createdAt: createdAt ?? this.createdAt,
    likeCount: likeCount ?? this.likeCount,
    commentCount: commentCount ?? this.commentCount,
    isLiked: isLiked ?? this.isLiked,
  );
  PostRow copyWithCompanion(PostsCompanion data) {
    return PostRow(
      id: data.id.present ? data.id.value : this.id,
      authorId: data.authorId.present ? data.authorId.value : this.authorId,
      content: data.content.present ? data.content.value : this.content,
      imageUrl: data.imageUrl.present ? data.imageUrl.value : this.imageUrl,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      likeCount: data.likeCount.present ? data.likeCount.value : this.likeCount,
      commentCount: data.commentCount.present
          ? data.commentCount.value
          : this.commentCount,
      isLiked: data.isLiked.present ? data.isLiked.value : this.isLiked,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PostRow(')
          ..write('id: $id, ')
          ..write('authorId: $authorId, ')
          ..write('content: $content, ')
          ..write('imageUrl: $imageUrl, ')
          ..write('createdAt: $createdAt, ')
          ..write('likeCount: $likeCount, ')
          ..write('commentCount: $commentCount, ')
          ..write('isLiked: $isLiked')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    authorId,
    content,
    imageUrl,
    createdAt,
    likeCount,
    commentCount,
    isLiked,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PostRow &&
          other.id == this.id &&
          other.authorId == this.authorId &&
          other.content == this.content &&
          other.imageUrl == this.imageUrl &&
          other.createdAt == this.createdAt &&
          other.likeCount == this.likeCount &&
          other.commentCount == this.commentCount &&
          other.isLiked == this.isLiked);
}

class PostsCompanion extends UpdateCompanion<PostRow> {
  final Value<String> id;
  final Value<String> authorId;
  final Value<String> content;
  final Value<String?> imageUrl;
  final Value<DateTime> createdAt;
  final Value<int> likeCount;
  final Value<int> commentCount;
  final Value<bool> isLiked;
  final Value<int> rowid;
  const PostsCompanion({
    this.id = const Value.absent(),
    this.authorId = const Value.absent(),
    this.content = const Value.absent(),
    this.imageUrl = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.likeCount = const Value.absent(),
    this.commentCount = const Value.absent(),
    this.isLiked = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PostsCompanion.insert({
    required String id,
    required String authorId,
    required String content,
    this.imageUrl = const Value.absent(),
    required DateTime createdAt,
    required int likeCount,
    required int commentCount,
    required bool isLiked,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       authorId = Value(authorId),
       content = Value(content),
       createdAt = Value(createdAt),
       likeCount = Value(likeCount),
       commentCount = Value(commentCount),
       isLiked = Value(isLiked);
  static Insertable<PostRow> custom({
    Expression<String>? id,
    Expression<String>? authorId,
    Expression<String>? content,
    Expression<String>? imageUrl,
    Expression<DateTime>? createdAt,
    Expression<int>? likeCount,
    Expression<int>? commentCount,
    Expression<bool>? isLiked,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (authorId != null) 'author_id': authorId,
      if (content != null) 'content': content,
      if (imageUrl != null) 'image_url': imageUrl,
      if (createdAt != null) 'created_at': createdAt,
      if (likeCount != null) 'like_count': likeCount,
      if (commentCount != null) 'comment_count': commentCount,
      if (isLiked != null) 'is_liked': isLiked,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PostsCompanion copyWith({
    Value<String>? id,
    Value<String>? authorId,
    Value<String>? content,
    Value<String?>? imageUrl,
    Value<DateTime>? createdAt,
    Value<int>? likeCount,
    Value<int>? commentCount,
    Value<bool>? isLiked,
    Value<int>? rowid,
  }) {
    return PostsCompanion(
      id: id ?? this.id,
      authorId: authorId ?? this.authorId,
      content: content ?? this.content,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
      likeCount: likeCount ?? this.likeCount,
      commentCount: commentCount ?? this.commentCount,
      isLiked: isLiked ?? this.isLiked,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (authorId.present) {
      map['author_id'] = Variable<String>(authorId.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (imageUrl.present) {
      map['image_url'] = Variable<String>(imageUrl.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (likeCount.present) {
      map['like_count'] = Variable<int>(likeCount.value);
    }
    if (commentCount.present) {
      map['comment_count'] = Variable<int>(commentCount.value);
    }
    if (isLiked.present) {
      map['is_liked'] = Variable<bool>(isLiked.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PostsCompanion(')
          ..write('id: $id, ')
          ..write('authorId: $authorId, ')
          ..write('content: $content, ')
          ..write('imageUrl: $imageUrl, ')
          ..write('createdAt: $createdAt, ')
          ..write('likeCount: $likeCount, ')
          ..write('commentCount: $commentCount, ')
          ..write('isLiked: $isLiked, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $FeedItemsTable extends FeedItems
    with TableInfo<$FeedItemsTable, FeedItemRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FeedItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _postIdMeta = const VerificationMeta('postId');
  @override
  late final GeneratedColumn<String> postId = GeneratedColumn<String>(
    'post_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES posts (id) ON DELETE CASCADE',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [postId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'feed_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<FeedItemRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('post_id')) {
      context.handle(
        _postIdMeta,
        postId.isAcceptableOrUnknown(data['post_id']!, _postIdMeta),
      );
    } else if (isInserting) {
      context.missing(_postIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {postId};
  @override
  FeedItemRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FeedItemRow(
      postId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}post_id'],
      )!,
    );
  }

  @override
  $FeedItemsTable createAlias(String alias) {
    return $FeedItemsTable(attachedDatabase, alias);
  }
}

class FeedItemRow extends DataClass implements Insertable<FeedItemRow> {
  final String postId;
  const FeedItemRow({required this.postId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['post_id'] = Variable<String>(postId);
    return map;
  }

  FeedItemsCompanion toCompanion(bool nullToAbsent) {
    return FeedItemsCompanion(postId: Value(postId));
  }

  factory FeedItemRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FeedItemRow(postId: serializer.fromJson<String>(json['postId']));
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{'postId': serializer.toJson<String>(postId)};
  }

  FeedItemRow copyWith({String? postId}) =>
      FeedItemRow(postId: postId ?? this.postId);
  FeedItemRow copyWithCompanion(FeedItemsCompanion data) {
    return FeedItemRow(
      postId: data.postId.present ? data.postId.value : this.postId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FeedItemRow(')
          ..write('postId: $postId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => postId.hashCode;
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FeedItemRow && other.postId == this.postId);
}

class FeedItemsCompanion extends UpdateCompanion<FeedItemRow> {
  final Value<String> postId;
  final Value<int> rowid;
  const FeedItemsCompanion({
    this.postId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FeedItemsCompanion.insert({
    required String postId,
    this.rowid = const Value.absent(),
  }) : postId = Value(postId);
  static Insertable<FeedItemRow> custom({
    Expression<String>? postId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (postId != null) 'post_id': postId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FeedItemsCompanion copyWith({Value<String>? postId, Value<int>? rowid}) {
    return FeedItemsCompanion(
      postId: postId ?? this.postId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (postId.present) {
      map['post_id'] = Variable<String>(postId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FeedItemsCompanion(')
          ..write('postId: $postId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $BookmarksTable extends Bookmarks
    with TableInfo<$BookmarksTable, BookmarkRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BookmarksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _postIdMeta = const VerificationMeta('postId');
  @override
  late final GeneratedColumn<String> postId = GeneratedColumn<String>(
    'post_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES posts (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _bookmarkedAtMeta = const VerificationMeta(
    'bookmarkedAt',
  );
  @override
  late final GeneratedColumn<DateTime> bookmarkedAt = GeneratedColumn<DateTime>(
    'bookmarked_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [postId, bookmarkedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'bookmarks';
  @override
  VerificationContext validateIntegrity(
    Insertable<BookmarkRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('post_id')) {
      context.handle(
        _postIdMeta,
        postId.isAcceptableOrUnknown(data['post_id']!, _postIdMeta),
      );
    } else if (isInserting) {
      context.missing(_postIdMeta);
    }
    if (data.containsKey('bookmarked_at')) {
      context.handle(
        _bookmarkedAtMeta,
        bookmarkedAt.isAcceptableOrUnknown(
          data['bookmarked_at']!,
          _bookmarkedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_bookmarkedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {postId};
  @override
  BookmarkRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BookmarkRow(
      postId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}post_id'],
      )!,
      bookmarkedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}bookmarked_at'],
      )!,
    );
  }

  @override
  $BookmarksTable createAlias(String alias) {
    return $BookmarksTable(attachedDatabase, alias);
  }
}

class BookmarkRow extends DataClass implements Insertable<BookmarkRow> {
  final String postId;

  /// UTC. The Bookmarks tab lists the most recent first.
  final DateTime bookmarkedAt;
  const BookmarkRow({required this.postId, required this.bookmarkedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['post_id'] = Variable<String>(postId);
    map['bookmarked_at'] = Variable<DateTime>(bookmarkedAt);
    return map;
  }

  BookmarksCompanion toCompanion(bool nullToAbsent) {
    return BookmarksCompanion(
      postId: Value(postId),
      bookmarkedAt: Value(bookmarkedAt),
    );
  }

  factory BookmarkRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BookmarkRow(
      postId: serializer.fromJson<String>(json['postId']),
      bookmarkedAt: serializer.fromJson<DateTime>(json['bookmarkedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'postId': serializer.toJson<String>(postId),
      'bookmarkedAt': serializer.toJson<DateTime>(bookmarkedAt),
    };
  }

  BookmarkRow copyWith({String? postId, DateTime? bookmarkedAt}) => BookmarkRow(
    postId: postId ?? this.postId,
    bookmarkedAt: bookmarkedAt ?? this.bookmarkedAt,
  );
  BookmarkRow copyWithCompanion(BookmarksCompanion data) {
    return BookmarkRow(
      postId: data.postId.present ? data.postId.value : this.postId,
      bookmarkedAt: data.bookmarkedAt.present
          ? data.bookmarkedAt.value
          : this.bookmarkedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BookmarkRow(')
          ..write('postId: $postId, ')
          ..write('bookmarkedAt: $bookmarkedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(postId, bookmarkedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BookmarkRow &&
          other.postId == this.postId &&
          other.bookmarkedAt == this.bookmarkedAt);
}

class BookmarksCompanion extends UpdateCompanion<BookmarkRow> {
  final Value<String> postId;
  final Value<DateTime> bookmarkedAt;
  final Value<int> rowid;
  const BookmarksCompanion({
    this.postId = const Value.absent(),
    this.bookmarkedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BookmarksCompanion.insert({
    required String postId,
    required DateTime bookmarkedAt,
    this.rowid = const Value.absent(),
  }) : postId = Value(postId),
       bookmarkedAt = Value(bookmarkedAt);
  static Insertable<BookmarkRow> custom({
    Expression<String>? postId,
    Expression<DateTime>? bookmarkedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (postId != null) 'post_id': postId,
      if (bookmarkedAt != null) 'bookmarked_at': bookmarkedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BookmarksCompanion copyWith({
    Value<String>? postId,
    Value<DateTime>? bookmarkedAt,
    Value<int>? rowid,
  }) {
    return BookmarksCompanion(
      postId: postId ?? this.postId,
      bookmarkedAt: bookmarkedAt ?? this.bookmarkedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (postId.present) {
      map['post_id'] = Variable<String>(postId.value);
    }
    if (bookmarkedAt.present) {
      map['bookmarked_at'] = Variable<DateTime>(bookmarkedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BookmarksCompanion(')
          ..write('postId: $postId, ')
          ..write('bookmarkedAt: $bookmarkedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CommentsTable extends Comments
    with TableInfo<$CommentsTable, CommentRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CommentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _postIdMeta = const VerificationMeta('postId');
  @override
  late final GeneratedColumn<String> postId = GeneratedColumn<String>(
    'post_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES posts (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _authorIdMeta = const VerificationMeta(
    'authorId',
  );
  @override
  late final GeneratedColumn<String> authorId = GeneratedColumn<String>(
    'author_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES users (id)',
    ),
  );
  static const VerificationMeta _contentMeta = const VerificationMeta(
    'content',
  );
  @override
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
    'content',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    postId,
    authorId,
    content,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'comments';
  @override
  VerificationContext validateIntegrity(
    Insertable<CommentRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('post_id')) {
      context.handle(
        _postIdMeta,
        postId.isAcceptableOrUnknown(data['post_id']!, _postIdMeta),
      );
    } else if (isInserting) {
      context.missing(_postIdMeta);
    }
    if (data.containsKey('author_id')) {
      context.handle(
        _authorIdMeta,
        authorId.isAcceptableOrUnknown(data['author_id']!, _authorIdMeta),
      );
    } else if (isInserting) {
      context.missing(_authorIdMeta);
    }
    if (data.containsKey('content')) {
      context.handle(
        _contentMeta,
        content.isAcceptableOrUnknown(data['content']!, _contentMeta),
      );
    } else if (isInserting) {
      context.missing(_contentMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CommentRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CommentRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      postId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}post_id'],
      )!,
      authorId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}author_id'],
      )!,
      content: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $CommentsTable createAlias(String alias) {
    return $CommentsTable(attachedDatabase, alias);
  }
}

class CommentRow extends DataClass implements Insertable<CommentRow> {
  final String id;
  final String postId;
  final String authorId;

  /// The comment's text. (A column named `text` would hide drift's `text()`
  /// column builder inside this class.)
  final String content;

  /// UTC, stored as ISO-8601 text (see `build.yaml`).
  final DateTime createdAt;
  const CommentRow({
    required this.id,
    required this.postId,
    required this.authorId,
    required this.content,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['post_id'] = Variable<String>(postId);
    map['author_id'] = Variable<String>(authorId);
    map['content'] = Variable<String>(content);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  CommentsCompanion toCompanion(bool nullToAbsent) {
    return CommentsCompanion(
      id: Value(id),
      postId: Value(postId),
      authorId: Value(authorId),
      content: Value(content),
      createdAt: Value(createdAt),
    );
  }

  factory CommentRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CommentRow(
      id: serializer.fromJson<String>(json['id']),
      postId: serializer.fromJson<String>(json['postId']),
      authorId: serializer.fromJson<String>(json['authorId']),
      content: serializer.fromJson<String>(json['content']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'postId': serializer.toJson<String>(postId),
      'authorId': serializer.toJson<String>(authorId),
      'content': serializer.toJson<String>(content),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  CommentRow copyWith({
    String? id,
    String? postId,
    String? authorId,
    String? content,
    DateTime? createdAt,
  }) => CommentRow(
    id: id ?? this.id,
    postId: postId ?? this.postId,
    authorId: authorId ?? this.authorId,
    content: content ?? this.content,
    createdAt: createdAt ?? this.createdAt,
  );
  CommentRow copyWithCompanion(CommentsCompanion data) {
    return CommentRow(
      id: data.id.present ? data.id.value : this.id,
      postId: data.postId.present ? data.postId.value : this.postId,
      authorId: data.authorId.present ? data.authorId.value : this.authorId,
      content: data.content.present ? data.content.value : this.content,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CommentRow(')
          ..write('id: $id, ')
          ..write('postId: $postId, ')
          ..write('authorId: $authorId, ')
          ..write('content: $content, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, postId, authorId, content, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CommentRow &&
          other.id == this.id &&
          other.postId == this.postId &&
          other.authorId == this.authorId &&
          other.content == this.content &&
          other.createdAt == this.createdAt);
}

class CommentsCompanion extends UpdateCompanion<CommentRow> {
  final Value<String> id;
  final Value<String> postId;
  final Value<String> authorId;
  final Value<String> content;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const CommentsCompanion({
    this.id = const Value.absent(),
    this.postId = const Value.absent(),
    this.authorId = const Value.absent(),
    this.content = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CommentsCompanion.insert({
    required String id,
    required String postId,
    required String authorId,
    required String content,
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       postId = Value(postId),
       authorId = Value(authorId),
       content = Value(content),
       createdAt = Value(createdAt);
  static Insertable<CommentRow> custom({
    Expression<String>? id,
    Expression<String>? postId,
    Expression<String>? authorId,
    Expression<String>? content,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (postId != null) 'post_id': postId,
      if (authorId != null) 'author_id': authorId,
      if (content != null) 'content': content,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CommentsCompanion copyWith({
    Value<String>? id,
    Value<String>? postId,
    Value<String>? authorId,
    Value<String>? content,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return CommentsCompanion(
      id: id ?? this.id,
      postId: postId ?? this.postId,
      authorId: authorId ?? this.authorId,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (postId.present) {
      map['post_id'] = Variable<String>(postId.value);
    }
    if (authorId.present) {
      map['author_id'] = Variable<String>(authorId.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CommentsCompanion(')
          ..write('id: $id, ')
          ..write('postId: $postId, ')
          ..write('authorId: $authorId, ')
          ..write('content: $content, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RecentSearchesTable extends RecentSearches
    with TableInfo<$RecentSearchesTable, RecentSearchRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RecentSearchesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _normalizedQueryMeta = const VerificationMeta(
    'normalizedQuery',
  );
  @override
  late final GeneratedColumn<String> normalizedQuery = GeneratedColumn<String>(
    'normalized_query',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _displayTextMeta = const VerificationMeta(
    'displayText',
  );
  @override
  late final GeneratedColumn<String> displayText = GeneratedColumn<String>(
    'display_text',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _searchedAtMeta = const VerificationMeta(
    'searchedAt',
  );
  @override
  late final GeneratedColumn<DateTime> searchedAt = GeneratedColumn<DateTime>(
    'searched_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    normalizedQuery,
    displayText,
    searchedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'recent_searches';
  @override
  VerificationContext validateIntegrity(
    Insertable<RecentSearchRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('normalized_query')) {
      context.handle(
        _normalizedQueryMeta,
        normalizedQuery.isAcceptableOrUnknown(
          data['normalized_query']!,
          _normalizedQueryMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_normalizedQueryMeta);
    }
    if (data.containsKey('display_text')) {
      context.handle(
        _displayTextMeta,
        displayText.isAcceptableOrUnknown(
          data['display_text']!,
          _displayTextMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_displayTextMeta);
    }
    if (data.containsKey('searched_at')) {
      context.handle(
        _searchedAtMeta,
        searchedAt.isAcceptableOrUnknown(data['searched_at']!, _searchedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_searchedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {normalizedQuery};
  @override
  RecentSearchRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RecentSearchRow(
      normalizedQuery: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}normalized_query'],
      )!,
      displayText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}display_text'],
      )!,
      searchedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}searched_at'],
      )!,
    );
  }

  @override
  $RecentSearchesTable createAlias(String alias) {
    return $RecentSearchesTable(attachedDatabase, alias);
  }
}

class RecentSearchRow extends DataClass implements Insertable<RecentSearchRow> {
  /// The trimmed, lower-case query: what makes two spellings one entry.
  final String normalizedQuery;

  /// The query as last searched (trimmed): what the list shows.
  final String displayText;

  /// UTC. The list shows the most recent first.
  final DateTime searchedAt;
  const RecentSearchRow({
    required this.normalizedQuery,
    required this.displayText,
    required this.searchedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['normalized_query'] = Variable<String>(normalizedQuery);
    map['display_text'] = Variable<String>(displayText);
    map['searched_at'] = Variable<DateTime>(searchedAt);
    return map;
  }

  RecentSearchesCompanion toCompanion(bool nullToAbsent) {
    return RecentSearchesCompanion(
      normalizedQuery: Value(normalizedQuery),
      displayText: Value(displayText),
      searchedAt: Value(searchedAt),
    );
  }

  factory RecentSearchRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RecentSearchRow(
      normalizedQuery: serializer.fromJson<String>(json['normalizedQuery']),
      displayText: serializer.fromJson<String>(json['displayText']),
      searchedAt: serializer.fromJson<DateTime>(json['searchedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'normalizedQuery': serializer.toJson<String>(normalizedQuery),
      'displayText': serializer.toJson<String>(displayText),
      'searchedAt': serializer.toJson<DateTime>(searchedAt),
    };
  }

  RecentSearchRow copyWith({
    String? normalizedQuery,
    String? displayText,
    DateTime? searchedAt,
  }) => RecentSearchRow(
    normalizedQuery: normalizedQuery ?? this.normalizedQuery,
    displayText: displayText ?? this.displayText,
    searchedAt: searchedAt ?? this.searchedAt,
  );
  RecentSearchRow copyWithCompanion(RecentSearchesCompanion data) {
    return RecentSearchRow(
      normalizedQuery: data.normalizedQuery.present
          ? data.normalizedQuery.value
          : this.normalizedQuery,
      displayText: data.displayText.present
          ? data.displayText.value
          : this.displayText,
      searchedAt: data.searchedAt.present
          ? data.searchedAt.value
          : this.searchedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RecentSearchRow(')
          ..write('normalizedQuery: $normalizedQuery, ')
          ..write('displayText: $displayText, ')
          ..write('searchedAt: $searchedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(normalizedQuery, displayText, searchedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RecentSearchRow &&
          other.normalizedQuery == this.normalizedQuery &&
          other.displayText == this.displayText &&
          other.searchedAt == this.searchedAt);
}

class RecentSearchesCompanion extends UpdateCompanion<RecentSearchRow> {
  final Value<String> normalizedQuery;
  final Value<String> displayText;
  final Value<DateTime> searchedAt;
  final Value<int> rowid;
  const RecentSearchesCompanion({
    this.normalizedQuery = const Value.absent(),
    this.displayText = const Value.absent(),
    this.searchedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RecentSearchesCompanion.insert({
    required String normalizedQuery,
    required String displayText,
    required DateTime searchedAt,
    this.rowid = const Value.absent(),
  }) : normalizedQuery = Value(normalizedQuery),
       displayText = Value(displayText),
       searchedAt = Value(searchedAt);
  static Insertable<RecentSearchRow> custom({
    Expression<String>? normalizedQuery,
    Expression<String>? displayText,
    Expression<DateTime>? searchedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (normalizedQuery != null) 'normalized_query': normalizedQuery,
      if (displayText != null) 'display_text': displayText,
      if (searchedAt != null) 'searched_at': searchedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RecentSearchesCompanion copyWith({
    Value<String>? normalizedQuery,
    Value<String>? displayText,
    Value<DateTime>? searchedAt,
    Value<int>? rowid,
  }) {
    return RecentSearchesCompanion(
      normalizedQuery: normalizedQuery ?? this.normalizedQuery,
      displayText: displayText ?? this.displayText,
      searchedAt: searchedAt ?? this.searchedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (normalizedQuery.present) {
      map['normalized_query'] = Variable<String>(normalizedQuery.value);
    }
    if (displayText.present) {
      map['display_text'] = Variable<String>(displayText.value);
    }
    if (searchedAt.present) {
      map['searched_at'] = Variable<DateTime>(searchedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RecentSearchesCompanion(')
          ..write('normalizedQuery: $normalizedQuery, ')
          ..write('displayText: $displayText, ')
          ..write('searchedAt: $searchedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $UsersTable users = $UsersTable(this);
  late final $PostsTable posts = $PostsTable(this);
  late final $FeedItemsTable feedItems = $FeedItemsTable(this);
  late final $BookmarksTable bookmarks = $BookmarksTable(this);
  late final $CommentsTable comments = $CommentsTable(this);
  late final $RecentSearchesTable recentSearches = $RecentSearchesTable(this);
  late final PostsDao postsDao = PostsDao(this as AppDatabase);
  late final FeedDao feedDao = FeedDao(this as AppDatabase);
  late final CommentsDao commentsDao = CommentsDao(this as AppDatabase);
  late final UsersDao usersDao = UsersDao(this as AppDatabase);
  late final BookmarksDao bookmarksDao = BookmarksDao(this as AppDatabase);
  late final SearchDao searchDao = SearchDao(this as AppDatabase);
  late final CacheDao cacheDao = CacheDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    users,
    posts,
    feedItems,
    bookmarks,
    comments,
    recentSearches,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'posts',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('feed_items', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'posts',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('bookmarks', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'posts',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('comments', kind: UpdateKind.delete)],
    ),
  ]);
  @override
  DriftDatabaseOptions get options =>
      const DriftDatabaseOptions(storeDateTimeAsText: true);
}

typedef $$UsersTableCreateCompanionBuilder = UsersCompanion Function({
  required String id,
  required String name,
  Value<String?> avatarUrl,
  required String bio,
  required int followersCount,
  required int followingCount,
  Value<int> rowid,
});
typedef $$UsersTableUpdateCompanionBuilder = UsersCompanion Function({
  Value<String> id,
  Value<String> name,
  Value<String?> avatarUrl,
  Value<String> bio,
  Value<int> followersCount,
  Value<int> followingCount,
  Value<int> rowid,
});

final class $$UsersTableReferences
    extends BaseReferences<_$AppDatabase, $UsersTable, UserRow> {
  $$UsersTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$PostsTable, List<PostRow>> _postsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.posts,
    aliasName: 'users__id__posts__author_id',
  );

  $$PostsTableProcessedTableManager get postsRefs {
    final manager = $$PostsTableTableManager(
      $_db,
      $_db.posts,
    ).filter((f) => f.authorId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_postsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$CommentsTable, List<CommentRow>>
  _commentsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.comments,
    aliasName: 'users__id__comments__author_id',
  );

  $$CommentsTableProcessedTableManager get commentsRefs {
    final manager = $$CommentsTableTableManager(
      $_db,
      $_db.comments,
    ).filter((f) => f.authorId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_commentsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$UsersTableFilterComposer extends Composer<_$AppDatabase, $UsersTable> {
  $$UsersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get avatarUrl => $composableBuilder(
    column: $table.avatarUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get bio => $composableBuilder(
    column: $table.bio,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get followersCount => $composableBuilder(
    column: $table.followersCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get followingCount => $composableBuilder(
    column: $table.followingCount,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> postsRefs(
    Expression<bool> Function($$PostsTableFilterComposer f) f,
  ) {
    final $$PostsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.posts,
      getReferencedColumn: (t) => t.authorId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PostsTableFilterComposer(
            $db: $db,
            $table: $db.posts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> commentsRefs(
    Expression<bool> Function($$CommentsTableFilterComposer f) f,
  ) {
    final $$CommentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.comments,
      getReferencedColumn: (t) => t.authorId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CommentsTableFilterComposer(
            $db: $db,
            $table: $db.comments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$UsersTableOrderingComposer
    extends Composer<_$AppDatabase, $UsersTable> {
  $$UsersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get avatarUrl => $composableBuilder(
    column: $table.avatarUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get bio => $composableBuilder(
    column: $table.bio,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get followersCount => $composableBuilder(
    column: $table.followersCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get followingCount => $composableBuilder(
    column: $table.followingCount,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$UsersTableAnnotationComposer
    extends Composer<_$AppDatabase, $UsersTable> {
  $$UsersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get avatarUrl =>
      $composableBuilder(column: $table.avatarUrl, builder: (column) => column);

  GeneratedColumn<String> get bio =>
      $composableBuilder(column: $table.bio, builder: (column) => column);

  GeneratedColumn<int> get followersCount => $composableBuilder(
    column: $table.followersCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get followingCount => $composableBuilder(
    column: $table.followingCount,
    builder: (column) => column,
  );

  Expression<T> postsRefs<T extends Object>(
    Expression<T> Function($$PostsTableAnnotationComposer a) f,
  ) {
    final $$PostsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.posts,
      getReferencedColumn: (t) => t.authorId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PostsTableAnnotationComposer(
            $db: $db,
            $table: $db.posts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> commentsRefs<T extends Object>(
    Expression<T> Function($$CommentsTableAnnotationComposer a) f,
  ) {
    final $$CommentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.comments,
      getReferencedColumn: (t) => t.authorId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CommentsTableAnnotationComposer(
            $db: $db,
            $table: $db.comments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$UsersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UsersTable,
          UserRow,
          $$UsersTableFilterComposer,
          $$UsersTableOrderingComposer,
          $$UsersTableAnnotationComposer,
          $$UsersTableCreateCompanionBuilder,
          $$UsersTableUpdateCompanionBuilder,
          (UserRow, $$UsersTableReferences),
          UserRow,
          PrefetchHooks Function({bool postsRefs, bool commentsRefs})
        > {
  $$UsersTableTableManager(_$AppDatabase db, $UsersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UsersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UsersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UsersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> avatarUrl = const Value.absent(),
                Value<String> bio = const Value.absent(),
                Value<int> followersCount = const Value.absent(),
                Value<int> followingCount = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UsersCompanion(
                id: id,
                name: name,
                avatarUrl: avatarUrl,
                bio: bio,
                followersCount: followersCount,
                followingCount: followingCount,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                Value<String?> avatarUrl = const Value.absent(),
                required String bio,
                required int followersCount,
                required int followingCount,
                Value<int> rowid = const Value.absent(),
              }) => UsersCompanion.insert(
                id: id,
                name: name,
                avatarUrl: avatarUrl,
                bio: bio,
                followersCount: followersCount,
                followingCount: followingCount,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$UsersTable, UserRow>(table),
                  $$UsersTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({postsRefs = false, commentsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (postsRefs) db.posts,
                if (commentsRefs) db.comments,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (postsRefs)
                    await $_getPrefetchedData<UserRow, $UsersTable, PostRow>(
                      currentTable: table,
                      referencedTable: $$UsersTableReferences._postsRefsTable(
                        db,
                      ),
                      managerFromTypedResult: (p0) =>
                          $$UsersTableReferences(db, table, p0).postsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.authorId == item.id),
                      typedResults: items,
                    ),
                  if (commentsRefs)
                    await $_getPrefetchedData<UserRow, $UsersTable, CommentRow>(
                      currentTable: table,
                      referencedTable: $$UsersTableReferences
                          ._commentsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$UsersTableReferences(db, table, p0).commentsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.authorId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$UsersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $UsersTable,
      UserRow,
      $$UsersTableFilterComposer,
      $$UsersTableOrderingComposer,
      $$UsersTableAnnotationComposer,
      $$UsersTableCreateCompanionBuilder,
      $$UsersTableUpdateCompanionBuilder,
      (UserRow, $$UsersTableReferences),
      UserRow,
      PrefetchHooks Function({bool postsRefs, bool commentsRefs})
    >;
typedef $$PostsTableCreateCompanionBuilder = PostsCompanion Function({
  required String id,
  required String authorId,
  required String content,
  Value<String?> imageUrl,
  required DateTime createdAt,
  required int likeCount,
  required int commentCount,
  required bool isLiked,
  Value<int> rowid,
});
typedef $$PostsTableUpdateCompanionBuilder = PostsCompanion Function({
  Value<String> id,
  Value<String> authorId,
  Value<String> content,
  Value<String?> imageUrl,
  Value<DateTime> createdAt,
  Value<int> likeCount,
  Value<int> commentCount,
  Value<bool> isLiked,
  Value<int> rowid,
});

final class $$PostsTableReferences
    extends BaseReferences<_$AppDatabase, $PostsTable, PostRow> {
  $$PostsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $UsersTable _authorIdTable(_$AppDatabase db) =>
      db.users.createAlias('posts__author_id__users__id');

  $$UsersTableProcessedTableManager get authorId {
    final $_column = $_itemColumn<String>('author_id')!;

    final manager = $$UsersTableTableManager(
      $_db,
      $_db.users,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_authorIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$FeedItemsTable, List<FeedItemRow>>
  _feedItemsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.feedItems,
    aliasName: 'posts__id__feed_items__post_id',
  );

  $$FeedItemsTableProcessedTableManager get feedItemsRefs {
    final manager = $$FeedItemsTableTableManager(
      $_db,
      $_db.feedItems,
    ).filter((f) => f.postId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_feedItemsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$BookmarksTable, List<BookmarkRow>>
  _bookmarksRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.bookmarks,
    aliasName: 'posts__id__bookmarks__post_id',
  );

  $$BookmarksTableProcessedTableManager get bookmarksRefs {
    final manager = $$BookmarksTableTableManager(
      $_db,
      $_db.bookmarks,
    ).filter((f) => f.postId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_bookmarksRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$CommentsTable, List<CommentRow>>
  _commentsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.comments,
    aliasName: 'posts__id__comments__post_id',
  );

  $$CommentsTableProcessedTableManager get commentsRefs {
    final manager = $$CommentsTableTableManager(
      $_db,
      $_db.comments,
    ).filter((f) => f.postId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_commentsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$PostsTableFilterComposer extends Composer<_$AppDatabase, $PostsTable> {
  $$PostsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get imageUrl => $composableBuilder(
    column: $table.imageUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get likeCount => $composableBuilder(
    column: $table.likeCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get commentCount => $composableBuilder(
    column: $table.commentCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isLiked => $composableBuilder(
    column: $table.isLiked,
    builder: (column) => ColumnFilters(column),
  );

  $$UsersTableFilterComposer get authorId {
    final $$UsersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.authorId,
      referencedTable: $db.users,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsersTableFilterComposer(
            $db: $db,
            $table: $db.users,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> feedItemsRefs(
    Expression<bool> Function($$FeedItemsTableFilterComposer f) f,
  ) {
    final $$FeedItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.feedItems,
      getReferencedColumn: (t) => t.postId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FeedItemsTableFilterComposer(
            $db: $db,
            $table: $db.feedItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> bookmarksRefs(
    Expression<bool> Function($$BookmarksTableFilterComposer f) f,
  ) {
    final $$BookmarksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.bookmarks,
      getReferencedColumn: (t) => t.postId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BookmarksTableFilterComposer(
            $db: $db,
            $table: $db.bookmarks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> commentsRefs(
    Expression<bool> Function($$CommentsTableFilterComposer f) f,
  ) {
    final $$CommentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.comments,
      getReferencedColumn: (t) => t.postId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CommentsTableFilterComposer(
            $db: $db,
            $table: $db.comments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PostsTableOrderingComposer
    extends Composer<_$AppDatabase, $PostsTable> {
  $$PostsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get imageUrl => $composableBuilder(
    column: $table.imageUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get likeCount => $composableBuilder(
    column: $table.likeCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get commentCount => $composableBuilder(
    column: $table.commentCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isLiked => $composableBuilder(
    column: $table.isLiked,
    builder: (column) => ColumnOrderings(column),
  );

  $$UsersTableOrderingComposer get authorId {
    final $$UsersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.authorId,
      referencedTable: $db.users,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsersTableOrderingComposer(
            $db: $db,
            $table: $db.users,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PostsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PostsTable> {
  $$PostsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);

  GeneratedColumn<String> get imageUrl =>
      $composableBuilder(column: $table.imageUrl, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get likeCount =>
      $composableBuilder(column: $table.likeCount, builder: (column) => column);

  GeneratedColumn<int> get commentCount => $composableBuilder(
    column: $table.commentCount,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isLiked =>
      $composableBuilder(column: $table.isLiked, builder: (column) => column);

  $$UsersTableAnnotationComposer get authorId {
    final $$UsersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.authorId,
      referencedTable: $db.users,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsersTableAnnotationComposer(
            $db: $db,
            $table: $db.users,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> feedItemsRefs<T extends Object>(
    Expression<T> Function($$FeedItemsTableAnnotationComposer a) f,
  ) {
    final $$FeedItemsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.feedItems,
      getReferencedColumn: (t) => t.postId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FeedItemsTableAnnotationComposer(
            $db: $db,
            $table: $db.feedItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> bookmarksRefs<T extends Object>(
    Expression<T> Function($$BookmarksTableAnnotationComposer a) f,
  ) {
    final $$BookmarksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.bookmarks,
      getReferencedColumn: (t) => t.postId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BookmarksTableAnnotationComposer(
            $db: $db,
            $table: $db.bookmarks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> commentsRefs<T extends Object>(
    Expression<T> Function($$CommentsTableAnnotationComposer a) f,
  ) {
    final $$CommentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.comments,
      getReferencedColumn: (t) => t.postId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CommentsTableAnnotationComposer(
            $db: $db,
            $table: $db.comments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PostsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PostsTable,
          PostRow,
          $$PostsTableFilterComposer,
          $$PostsTableOrderingComposer,
          $$PostsTableAnnotationComposer,
          $$PostsTableCreateCompanionBuilder,
          $$PostsTableUpdateCompanionBuilder,
          (PostRow, $$PostsTableReferences),
          PostRow,
          PrefetchHooks Function({
            bool authorId,
            bool feedItemsRefs,
            bool bookmarksRefs,
            bool commentsRefs,
          })
        > {
  $$PostsTableTableManager(_$AppDatabase db, $PostsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PostsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PostsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PostsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> authorId = const Value.absent(),
                Value<String> content = const Value.absent(),
                Value<String?> imageUrl = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> likeCount = const Value.absent(),
                Value<int> commentCount = const Value.absent(),
                Value<bool> isLiked = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PostsCompanion(
                id: id,
                authorId: authorId,
                content: content,
                imageUrl: imageUrl,
                createdAt: createdAt,
                likeCount: likeCount,
                commentCount: commentCount,
                isLiked: isLiked,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String authorId,
                required String content,
                Value<String?> imageUrl = const Value.absent(),
                required DateTime createdAt,
                required int likeCount,
                required int commentCount,
                required bool isLiked,
                Value<int> rowid = const Value.absent(),
              }) => PostsCompanion.insert(
                id: id,
                authorId: authorId,
                content: content,
                imageUrl: imageUrl,
                createdAt: createdAt,
                likeCount: likeCount,
                commentCount: commentCount,
                isLiked: isLiked,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PostsTable, PostRow>(table),
                  $$PostsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                authorId = false,
                feedItemsRefs = false,
                bookmarksRefs = false,
                commentsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (feedItemsRefs) db.feedItems,
                    if (bookmarksRefs) db.bookmarks,
                    if (commentsRefs) db.comments,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (authorId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.authorId,
                            referencedTable: $$PostsTableReferences
                                ._authorIdTable(db),
                            referencedColumn: $$PostsTableReferences
                                ._authorIdTable(db)
                                .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (feedItemsRefs)
                        await $_getPrefetchedData<
                          PostRow,
                          $PostsTable,
                          FeedItemRow
                        >(
                          currentTable: table,
                          referencedTable: $$PostsTableReferences
                              ._feedItemsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$PostsTableReferences(
                                db,
                                table,
                                p0,
                              ).feedItemsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.postId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (bookmarksRefs)
                        await $_getPrefetchedData<
                          PostRow,
                          $PostsTable,
                          BookmarkRow
                        >(
                          currentTable: table,
                          referencedTable: $$PostsTableReferences
                              ._bookmarksRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$PostsTableReferences(
                                db,
                                table,
                                p0,
                              ).bookmarksRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.postId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (commentsRefs)
                        await $_getPrefetchedData<
                          PostRow,
                          $PostsTable,
                          CommentRow
                        >(
                          currentTable: table,
                          referencedTable: $$PostsTableReferences
                              ._commentsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$PostsTableReferences(
                                db,
                                table,
                                p0,
                              ).commentsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.postId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$PostsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PostsTable,
      PostRow,
      $$PostsTableFilterComposer,
      $$PostsTableOrderingComposer,
      $$PostsTableAnnotationComposer,
      $$PostsTableCreateCompanionBuilder,
      $$PostsTableUpdateCompanionBuilder,
      (PostRow, $$PostsTableReferences),
      PostRow,
      PrefetchHooks Function({
        bool authorId,
        bool feedItemsRefs,
        bool bookmarksRefs,
        bool commentsRefs,
      })
    >;
typedef $$FeedItemsTableCreateCompanionBuilder = FeedItemsCompanion Function({
  required String postId,
  Value<int> rowid,
});
typedef $$FeedItemsTableUpdateCompanionBuilder = FeedItemsCompanion Function({
  Value<String> postId,
  Value<int> rowid,
});

final class $$FeedItemsTableReferences
    extends BaseReferences<_$AppDatabase, $FeedItemsTable, FeedItemRow> {
  $$FeedItemsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $PostsTable _postIdTable(_$AppDatabase db) =>
      db.posts.createAlias('feed_items__post_id__posts__id');

  $$PostsTableProcessedTableManager get postId {
    final $_column = $_itemColumn<String>('post_id')!;

    final manager = $$PostsTableTableManager(
      $_db,
      $_db.posts,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_postIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$FeedItemsTableFilterComposer
    extends Composer<_$AppDatabase, $FeedItemsTable> {
  $$FeedItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$PostsTableFilterComposer get postId {
    final $$PostsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.postId,
      referencedTable: $db.posts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PostsTableFilterComposer(
            $db: $db,
            $table: $db.posts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$FeedItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $FeedItemsTable> {
  $$FeedItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$PostsTableOrderingComposer get postId {
    final $$PostsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.postId,
      referencedTable: $db.posts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PostsTableOrderingComposer(
            $db: $db,
            $table: $db.posts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$FeedItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $FeedItemsTable> {
  $$FeedItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$PostsTableAnnotationComposer get postId {
    final $$PostsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.postId,
      referencedTable: $db.posts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PostsTableAnnotationComposer(
            $db: $db,
            $table: $db.posts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$FeedItemsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FeedItemsTable,
          FeedItemRow,
          $$FeedItemsTableFilterComposer,
          $$FeedItemsTableOrderingComposer,
          $$FeedItemsTableAnnotationComposer,
          $$FeedItemsTableCreateCompanionBuilder,
          $$FeedItemsTableUpdateCompanionBuilder,
          (FeedItemRow, $$FeedItemsTableReferences),
          FeedItemRow,
          PrefetchHooks Function({bool postId})
        > {
  $$FeedItemsTableTableManager(_$AppDatabase db, $FeedItemsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FeedItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FeedItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FeedItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> postId = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) => FeedItemsCompanion(postId: postId, rowid: rowid),
          createCompanionCallback: ({
            required String postId,
            Value<int> rowid = const Value.absent(),
          }) => FeedItemsCompanion.insert(postId: postId, rowid: rowid),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$FeedItemsTable, FeedItemRow>(table),
                  $$FeedItemsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({postId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (postId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.postId,
                        referencedTable: $$FeedItemsTableReferences
                            ._postIdTable(db),
                        referencedColumn: $$FeedItemsTableReferences
                            ._postIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$FeedItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FeedItemsTable,
      FeedItemRow,
      $$FeedItemsTableFilterComposer,
      $$FeedItemsTableOrderingComposer,
      $$FeedItemsTableAnnotationComposer,
      $$FeedItemsTableCreateCompanionBuilder,
      $$FeedItemsTableUpdateCompanionBuilder,
      (FeedItemRow, $$FeedItemsTableReferences),
      FeedItemRow,
      PrefetchHooks Function({bool postId})
    >;
typedef $$BookmarksTableCreateCompanionBuilder = BookmarksCompanion Function({
  required String postId,
  required DateTime bookmarkedAt,
  Value<int> rowid,
});
typedef $$BookmarksTableUpdateCompanionBuilder = BookmarksCompanion Function({
  Value<String> postId,
  Value<DateTime> bookmarkedAt,
  Value<int> rowid,
});

final class $$BookmarksTableReferences
    extends BaseReferences<_$AppDatabase, $BookmarksTable, BookmarkRow> {
  $$BookmarksTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $PostsTable _postIdTable(_$AppDatabase db) =>
      db.posts.createAlias('bookmarks__post_id__posts__id');

  $$PostsTableProcessedTableManager get postId {
    final $_column = $_itemColumn<String>('post_id')!;

    final manager = $$PostsTableTableManager(
      $_db,
      $_db.posts,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_postIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$BookmarksTableFilterComposer
    extends Composer<_$AppDatabase, $BookmarksTable> {
  $$BookmarksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<DateTime> get bookmarkedAt => $composableBuilder(
    column: $table.bookmarkedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$PostsTableFilterComposer get postId {
    final $$PostsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.postId,
      referencedTable: $db.posts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PostsTableFilterComposer(
            $db: $db,
            $table: $db.posts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$BookmarksTableOrderingComposer
    extends Composer<_$AppDatabase, $BookmarksTable> {
  $$BookmarksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<DateTime> get bookmarkedAt => $composableBuilder(
    column: $table.bookmarkedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$PostsTableOrderingComposer get postId {
    final $$PostsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.postId,
      referencedTable: $db.posts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PostsTableOrderingComposer(
            $db: $db,
            $table: $db.posts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$BookmarksTableAnnotationComposer
    extends Composer<_$AppDatabase, $BookmarksTable> {
  $$BookmarksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<DateTime> get bookmarkedAt => $composableBuilder(
    column: $table.bookmarkedAt,
    builder: (column) => column,
  );

  $$PostsTableAnnotationComposer get postId {
    final $$PostsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.postId,
      referencedTable: $db.posts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PostsTableAnnotationComposer(
            $db: $db,
            $table: $db.posts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$BookmarksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BookmarksTable,
          BookmarkRow,
          $$BookmarksTableFilterComposer,
          $$BookmarksTableOrderingComposer,
          $$BookmarksTableAnnotationComposer,
          $$BookmarksTableCreateCompanionBuilder,
          $$BookmarksTableUpdateCompanionBuilder,
          (BookmarkRow, $$BookmarksTableReferences),
          BookmarkRow,
          PrefetchHooks Function({bool postId})
        > {
  $$BookmarksTableTableManager(_$AppDatabase db, $BookmarksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BookmarksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BookmarksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BookmarksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> postId = const Value.absent(),
                Value<DateTime> bookmarkedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BookmarksCompanion(
                postId: postId,
                bookmarkedAt: bookmarkedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String postId,
                required DateTime bookmarkedAt,
                Value<int> rowid = const Value.absent(),
              }) => BookmarksCompanion.insert(
                postId: postId,
                bookmarkedAt: bookmarkedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$BookmarksTable, BookmarkRow>(table),
                  $$BookmarksTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({postId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (postId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.postId,
                        referencedTable: $$BookmarksTableReferences
                            ._postIdTable(db),
                        referencedColumn: $$BookmarksTableReferences
                            ._postIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$BookmarksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BookmarksTable,
      BookmarkRow,
      $$BookmarksTableFilterComposer,
      $$BookmarksTableOrderingComposer,
      $$BookmarksTableAnnotationComposer,
      $$BookmarksTableCreateCompanionBuilder,
      $$BookmarksTableUpdateCompanionBuilder,
      (BookmarkRow, $$BookmarksTableReferences),
      BookmarkRow,
      PrefetchHooks Function({bool postId})
    >;
typedef $$CommentsTableCreateCompanionBuilder = CommentsCompanion Function({
  required String id,
  required String postId,
  required String authorId,
  required String content,
  required DateTime createdAt,
  Value<int> rowid,
});
typedef $$CommentsTableUpdateCompanionBuilder = CommentsCompanion Function({
  Value<String> id,
  Value<String> postId,
  Value<String> authorId,
  Value<String> content,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

final class $$CommentsTableReferences
    extends BaseReferences<_$AppDatabase, $CommentsTable, CommentRow> {
  $$CommentsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $PostsTable _postIdTable(_$AppDatabase db) =>
      db.posts.createAlias('comments__post_id__posts__id');

  $$PostsTableProcessedTableManager get postId {
    final $_column = $_itemColumn<String>('post_id')!;

    final manager = $$PostsTableTableManager(
      $_db,
      $_db.posts,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_postIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $UsersTable _authorIdTable(_$AppDatabase db) =>
      db.users.createAlias('comments__author_id__users__id');

  $$UsersTableProcessedTableManager get authorId {
    final $_column = $_itemColumn<String>('author_id')!;

    final manager = $$UsersTableTableManager(
      $_db,
      $_db.users,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_authorIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$CommentsTableFilterComposer
    extends Composer<_$AppDatabase, $CommentsTable> {
  $$CommentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$PostsTableFilterComposer get postId {
    final $$PostsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.postId,
      referencedTable: $db.posts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PostsTableFilterComposer(
            $db: $db,
            $table: $db.posts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$UsersTableFilterComposer get authorId {
    final $$UsersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.authorId,
      referencedTable: $db.users,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsersTableFilterComposer(
            $db: $db,
            $table: $db.users,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CommentsTableOrderingComposer
    extends Composer<_$AppDatabase, $CommentsTable> {
  $$CommentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$PostsTableOrderingComposer get postId {
    final $$PostsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.postId,
      referencedTable: $db.posts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PostsTableOrderingComposer(
            $db: $db,
            $table: $db.posts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$UsersTableOrderingComposer get authorId {
    final $$UsersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.authorId,
      referencedTable: $db.users,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsersTableOrderingComposer(
            $db: $db,
            $table: $db.users,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CommentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CommentsTable> {
  $$CommentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$PostsTableAnnotationComposer get postId {
    final $$PostsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.postId,
      referencedTable: $db.posts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PostsTableAnnotationComposer(
            $db: $db,
            $table: $db.posts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$UsersTableAnnotationComposer get authorId {
    final $$UsersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.authorId,
      referencedTable: $db.users,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsersTableAnnotationComposer(
            $db: $db,
            $table: $db.users,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CommentsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CommentsTable,
          CommentRow,
          $$CommentsTableFilterComposer,
          $$CommentsTableOrderingComposer,
          $$CommentsTableAnnotationComposer,
          $$CommentsTableCreateCompanionBuilder,
          $$CommentsTableUpdateCompanionBuilder,
          (CommentRow, $$CommentsTableReferences),
          CommentRow,
          PrefetchHooks Function({bool postId, bool authorId})
        > {
  $$CommentsTableTableManager(_$AppDatabase db, $CommentsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CommentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CommentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CommentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> postId = const Value.absent(),
                Value<String> authorId = const Value.absent(),
                Value<String> content = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CommentsCompanion(
                id: id,
                postId: postId,
                authorId: authorId,
                content: content,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String postId,
                required String authorId,
                required String content,
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => CommentsCompanion.insert(
                id: id,
                postId: postId,
                authorId: authorId,
                content: content,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CommentsTable, CommentRow>(table),
                  $$CommentsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({postId = false, authorId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (postId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.postId,
                        referencedTable: $$CommentsTableReferences._postIdTable(
                          db,
                        ),
                        referencedColumn: $$CommentsTableReferences
                            ._postIdTable(db)
                            .id,
                      ) as T;
                    }
                    if (authorId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.authorId,
                        referencedTable: $$CommentsTableReferences
                            ._authorIdTable(db),
                        referencedColumn: $$CommentsTableReferences
                            ._authorIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$CommentsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CommentsTable,
      CommentRow,
      $$CommentsTableFilterComposer,
      $$CommentsTableOrderingComposer,
      $$CommentsTableAnnotationComposer,
      $$CommentsTableCreateCompanionBuilder,
      $$CommentsTableUpdateCompanionBuilder,
      (CommentRow, $$CommentsTableReferences),
      CommentRow,
      PrefetchHooks Function({bool postId, bool authorId})
    >;
typedef $$RecentSearchesTableCreateCompanionBuilder =
    RecentSearchesCompanion Function({
      required String normalizedQuery,
      required String displayText,
      required DateTime searchedAt,
      Value<int> rowid,
    });
typedef $$RecentSearchesTableUpdateCompanionBuilder =
    RecentSearchesCompanion Function({
      Value<String> normalizedQuery,
      Value<String> displayText,
      Value<DateTime> searchedAt,
      Value<int> rowid,
    });

class $$RecentSearchesTableFilterComposer
    extends Composer<_$AppDatabase, $RecentSearchesTable> {
  $$RecentSearchesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get normalizedQuery => $composableBuilder(
    column: $table.normalizedQuery,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get displayText => $composableBuilder(
    column: $table.displayText,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get searchedAt => $composableBuilder(
    column: $table.searchedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$RecentSearchesTableOrderingComposer
    extends Composer<_$AppDatabase, $RecentSearchesTable> {
  $$RecentSearchesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get normalizedQuery => $composableBuilder(
    column: $table.normalizedQuery,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get displayText => $composableBuilder(
    column: $table.displayText,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get searchedAt => $composableBuilder(
    column: $table.searchedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$RecentSearchesTableAnnotationComposer
    extends Composer<_$AppDatabase, $RecentSearchesTable> {
  $$RecentSearchesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get normalizedQuery => $composableBuilder(
    column: $table.normalizedQuery,
    builder: (column) => column,
  );

  GeneratedColumn<String> get displayText => $composableBuilder(
    column: $table.displayText,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get searchedAt => $composableBuilder(
    column: $table.searchedAt,
    builder: (column) => column,
  );
}

class $$RecentSearchesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RecentSearchesTable,
          RecentSearchRow,
          $$RecentSearchesTableFilterComposer,
          $$RecentSearchesTableOrderingComposer,
          $$RecentSearchesTableAnnotationComposer,
          $$RecentSearchesTableCreateCompanionBuilder,
          $$RecentSearchesTableUpdateCompanionBuilder,
          (
            RecentSearchRow,
            BaseReferences<
              _$AppDatabase,
              $RecentSearchesTable,
              RecentSearchRow
            >,
          ),
          RecentSearchRow,
          PrefetchHooks Function()
        > {
  $$RecentSearchesTableTableManager(
    _$AppDatabase db,
    $RecentSearchesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RecentSearchesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RecentSearchesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RecentSearchesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> normalizedQuery = const Value.absent(),
                Value<String> displayText = const Value.absent(),
                Value<DateTime> searchedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RecentSearchesCompanion(
                normalizedQuery: normalizedQuery,
                displayText: displayText,
                searchedAt: searchedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String normalizedQuery,
                required String displayText,
                required DateTime searchedAt,
                Value<int> rowid = const Value.absent(),
              }) => RecentSearchesCompanion.insert(
                normalizedQuery: normalizedQuery,
                displayText: displayText,
                searchedAt: searchedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$RecentSearchesTable, RecentSearchRow>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $RecentSearchesTable,
                    RecentSearchRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$RecentSearchesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RecentSearchesTable,
      RecentSearchRow,
      $$RecentSearchesTableFilterComposer,
      $$RecentSearchesTableOrderingComposer,
      $$RecentSearchesTableAnnotationComposer,
      $$RecentSearchesTableCreateCompanionBuilder,
      $$RecentSearchesTableUpdateCompanionBuilder,
      (
        RecentSearchRow,
        BaseReferences<_$AppDatabase, $RecentSearchesTable, RecentSearchRow>,
      ),
      RecentSearchRow,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$UsersTableTableManager get users =>
      $$UsersTableTableManager(_db, _db.users);
  $$PostsTableTableManager get posts =>
      $$PostsTableTableManager(_db, _db.posts);
  $$FeedItemsTableTableManager get feedItems =>
      $$FeedItemsTableTableManager(_db, _db.feedItems);
  $$BookmarksTableTableManager get bookmarks =>
      $$BookmarksTableTableManager(_db, _db.bookmarks);
  $$CommentsTableTableManager get comments =>
      $$CommentsTableTableManager(_db, _db.comments);
  $$RecentSearchesTableTableManager get recentSearches =>
      $$RecentSearchesTableTableManager(_db, _db.recentSearches);
}
