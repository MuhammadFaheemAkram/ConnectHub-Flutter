import 'package:connect_hub/core/network/dto/post_dto.dart';
import 'package:connect_hub/core/network/dto/user_dto.dart';
import 'package:json_annotation/json_annotation.dart';

part 'search_response_dto.g.dart';

/// What a search found: the matching people, then the matching posts, each
/// in the server's order.
@JsonSerializable(createToJson: false, checked: true)
class SearchResponseDto {
  const SearchResponseDto({required this.users, required this.posts});

  factory SearchResponseDto.fromJson(Map<String, dynamic> json) =>
      _$SearchResponseDtoFromJson(json);

  final List<UserDto> users;
  final List<PostDto> posts;
}
