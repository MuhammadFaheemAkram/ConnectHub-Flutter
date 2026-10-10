import 'package:connect_hub/core/network/dto/user_dto.dart';
import 'package:json_annotation/json_annotation.dart';

part 'post_dto.g.dart';

/// A post as the API sends it, seen by one viewer: [isLiked] and
/// [bookmarkedAt] describe the signed-in user's own like and bookmark.
///
/// The seed file uses the same shape, minus the viewer fields.
@JsonSerializable(createToJson: false, checked: true)
class PostDto {
  const PostDto({
    required this.id,
    required this.author,
    required this.content,
    this.imageUrl,
    required this.createdAt,
    required this.likeCount,
    required this.commentCount,
    this.isLiked = false,
    this.bookmarkedAt,
  });

  factory PostDto.fromJson(Map<String, dynamic> json) =>
      _$PostDtoFromJson(json);

  final String id;
  final UserDto author;
  final String content;

  @JsonKey(name: 'imageURL')
  final String? imageUrl;

  final DateTime createdAt;
  final int likeCount;
  final int commentCount;
  final bool isLiked;

  /// When the viewer bookmarked the post, or `null` if they haven't.
  final DateTime? bookmarkedAt;
}
