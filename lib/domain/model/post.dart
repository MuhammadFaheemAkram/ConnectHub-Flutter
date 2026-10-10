import 'package:connect_hub/domain/model/user.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'post.freezed.dart';

/// A post as the signed-in user sees it: [isLiked] and [isBookmarked] are
/// their own like and bookmark.
@freezed
abstract class Post with _$Post {
  const factory Post({
    required String id,
    required User author,
    required String content,
    String? imageUrl,
    required DateTime createdAt,
    required int likeCount,
    required int commentCount,
    @Default(false) bool isLiked,
    @Default(false) bool isBookmarked,
  }) = _Post;
}
