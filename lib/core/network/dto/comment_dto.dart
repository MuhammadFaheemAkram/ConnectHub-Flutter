import 'package:connect_hub/core/network/dto/user_dto.dart';
import 'package:json_annotation/json_annotation.dart';

part 'comment_dto.g.dart';

/// A comment on a post, as the API (and the seed file) describes it.
@JsonSerializable(createToJson: false, checked: true)
class CommentDto {
  const CommentDto({
    required this.id,
    required this.postId,
    required this.author,
    required this.text,
    required this.createdAt,
  });

  factory CommentDto.fromJson(Map<String, dynamic> json) =>
      _$CommentDtoFromJson(json);

  final String id;
  final String postId;
  final UserDto author;
  final String text;
  final DateTime createdAt;
}
