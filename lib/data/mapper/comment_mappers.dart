import 'package:connect_hub/core/database/app_database.dart';
import 'package:connect_hub/core/database/daos/comments_dao.dart';
import 'package:connect_hub/core/network/dto/comment_dto.dart';
import 'package:connect_hub/data/mapper/user_mappers.dart';
import 'package:connect_hub/domain/model/comment.dart';

extension CommentDtoMapper on CommentDto {
  /// The comment split into the rows it is cached as.
  CachedComment toCached() => (
    comment: CommentRow(
      id: id,
      postId: postId,
      authorId: author.id,
      content: text,
      createdAt: createdAt.toUtc(),
    ),
    author: author.toRow(),
  );
}

extension CachedCommentMapper on CachedComment {
  /// [signedInUserId] decides [Comment.isMine]: one identity, from the
  /// session, drives it everywhere (Correctness Rule 2).
  Comment toDomain({required String? signedInUserId}) => Comment(
    id: comment.id,
    postId: comment.postId,
    author: author.toDomain(),
    text: comment.content,
    createdAt: comment.createdAt,
    isMine: comment.authorId == signedInUserId,
  );
}
