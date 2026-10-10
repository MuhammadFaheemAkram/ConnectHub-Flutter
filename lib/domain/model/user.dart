import 'package:freezed_annotation/freezed_annotation.dart';

part 'user.freezed.dart';

/// A person on ConnectHub, as every screen shows them.
@freezed
abstract class User with _$User {
  const factory User({
    required String id,
    required String name,
    String? avatarUrl,
    @Default('') String bio,
    @Default(0) int followersCount,
    @Default(0) int followingCount,
  }) = _User;
}
