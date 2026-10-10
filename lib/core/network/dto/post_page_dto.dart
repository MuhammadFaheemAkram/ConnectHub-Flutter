import 'package:connect_hub/core/network/dto/post_dto.dart';
import 'package:json_annotation/json_annotation.dart';

part 'post_page_dto.g.dart';

/// One page of the feed, newest first.
///
/// [nextCursor] is opaque: the client only hands it back to ask for the page
/// after this one. `null` means there are no older posts.
@JsonSerializable(createToJson: false, checked: true)
class PostPageDto {
  const PostPageDto({required this.posts, this.nextCursor});

  factory PostPageDto.fromJson(Map<String, dynamic> json) =>
      _$PostPageDtoFromJson(json);

  final List<PostDto> posts;
  final String? nextCursor;
}
