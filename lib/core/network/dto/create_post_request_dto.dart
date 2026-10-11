import 'package:json_annotation/json_annotation.dart';

part 'create_post_request_dto.g.dart';

/// The body of `POST /posts`.
///
/// A request DTO only needs `toJson`: a real HTTP client would send it as
/// `{"content": …, "imageURL": …}`. The fake service hands the object to the
/// fake server directly.
@JsonSerializable(createFactory: false)
class CreatePostRequestDto {
  const CreatePostRequestDto({required this.content, this.imageUrl});

  final String content;

  @JsonKey(name: 'imageURL')
  final String? imageUrl;

  Map<String, dynamic> toJson() => _$CreatePostRequestDtoToJson(this);
}
