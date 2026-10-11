import 'package:connect_hub/core/network/dto/post_dto.dart';
import 'package:connect_hub/core/network/dto/update_profile_request_dto.dart';
import 'package:connect_hub/core/network/dto/user_dto.dart';

/// The profile endpoints, Retrofit-style. Every call is authenticated.
///
/// There is no `GET /me`: `GET /users/{id}` serves the signed-in user's own
/// profile too, and the one private field `/me` would add (the email) is in
/// the session already.
abstract interface class UserApiService {
  /// `GET /users/{userId}`
  Future<UserDto> getUser(String userId);

  /// `GET /users/{userId}/posts`: every post by the user, newest first.
  Future<List<PostDto>> getUserPosts(String userId);

  /// `PATCH /me`: changes the signed-in user's own profile (the token says
  /// whose) and returns it.
  Future<UserDto> updateMe(UpdateProfileRequestDto request);
}
