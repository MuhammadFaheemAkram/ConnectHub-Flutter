import 'package:freezed_annotation/freezed_annotation.dart';

part 'session.freezed.dart';

/// Who is signed in, and the bearer token the API accepts for them.
@freezed
abstract class Session with _$Session {
  const factory Session({
    required String userId,
    required String email,
    required String token,
  }) = _Session;
}
