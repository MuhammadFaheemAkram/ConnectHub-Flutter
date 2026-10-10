import 'package:connect_hub/core/database/app_database.dart';
import 'package:connect_hub/core/database/daos/posts_dao.dart';
import 'package:connect_hub/core/network/dto/post_dto.dart';
import 'package:connect_hub/data/mapper/user_mappers.dart';
import 'package:connect_hub/domain/model/post.dart';

extension PostDtoMapper on PostDto {
  /// The post split into the rows it is cached as.
  CachedPost toCached() => (
    post: PostRow(
      id: id,
      authorId: author.id,
      content: content,
      imageUrl: imageUrl,
      createdAt: createdAt.toUtc(),
      likeCount: likeCount,
      commentCount: commentCount,
      isLiked: isLiked,
    ),
    author: author.toRow(),
    bookmarkedAt: bookmarkedAt?.toUtc(),
  );
}

extension CachedPostMapper on CachedPost {
  Post toDomain() => Post(
    id: post.id,
    author: author.toDomain(),
    content: post.content,
    imageUrl: post.imageUrl,
    createdAt: post.createdAt,
    likeCount: post.likeCount,
    commentCount: post.commentCount,
    isLiked: post.isLiked,
    isBookmarked: bookmarkedAt != null,
  );
}
