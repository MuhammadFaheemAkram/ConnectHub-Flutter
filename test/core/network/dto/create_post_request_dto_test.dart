import 'package:connect_hub/core/network/dto/create_post_request_dto.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('is sent with the API\'s keys, including "imageURL"', () {
    const request = CreatePostRequestDto(
      content: 'Hello',
      imageUrl: 'https://picsum.photos/600/400',
    );

    expect(request.toJson(), {
      'content': 'Hello',
      'imageURL': 'https://picsum.photos/600/400',
    });
  });
}
