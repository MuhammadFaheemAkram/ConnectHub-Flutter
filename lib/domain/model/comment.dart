import 'package:connect_hub/domain/model/user.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'comment.freezed.dart';

/// A comment on a post. [isMine] is worked out from the signed-in user when
/// comments are read, never stored, so it can't go stale after an account
/// switch.
@freezed
abstract class Comment with _$Comment {
  const factory Comment({
    required String id,
    required String postId,
    required User author,
    required String text,
    required DateTime createdAt,
    required bool isMine,
  }) = _Comment;
}
