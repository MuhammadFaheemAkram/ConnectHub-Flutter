import 'package:connect_hub/core/common/app_exception.dart';
import 'package:connect_hub/core/network/asset_json_loader.dart';
import 'package:connect_hub/core/network/dto/comment_dto.dart';
import 'package:connect_hub/core/network/dto/conversation_dto.dart';
import 'package:connect_hub/core/network/dto/message_dto.dart';
import 'package:connect_hub/core/network/dto/notification_dto.dart';
import 'package:connect_hub/core/network/dto/post_dto.dart';
import 'package:connect_hub/core/network/dto/user_dto.dart';
import 'package:injectable/injectable.dart';
import 'package:json_annotation/json_annotation.dart';

/// Reads the fake server's seed data: the iOS edition's bundled JSON, plus
/// a few Flutter-only additions (two posts by the demo user, the two comments
/// on them, and what each notification links to).
@lazySingleton
class SeedLoader {
  const SeedLoader(this._json);

  final AssetJsonLoader _json;

  static const authUserPath = 'assets/json/auth_user.json';
  static const postsPath = 'assets/json/feed_posts.json';
  static const commentsPath = 'assets/json/comments.json';
  static const conversationsPath = 'assets/json/conversations.json';
  static const messagesPath = 'assets/json/messages.json';
  static const notificationsPath = 'assets/json/notifications.json';

  /// In the seed's messages, the sender id that stands for the demo user.
  static const demoSenderId = 'me';

  /// The demo user, including the email it signs in with.
  Future<UserDto> loadAuthUser() => _decode(
    () async => UserDto.fromJson(await _json.loadObject(authUserPath)),
  );

  /// Every seed post, each with its author embedded.
  Future<List<PostDto>> loadPosts() => _decode(
    () async => [
      for (final json in await _json.loadObjectList(postsPath))
        PostDto.fromJson(json),
    ],
  );

  /// Every seed comment, each with its author embedded.
  Future<List<CommentDto>> loadComments() => _decode(
    () async => [
      for (final json in await _json.loadObjectList(commentsPath))
        CommentDto.fromJson(json),
    ],
  );

  /// The demo user's conversations, each with the other person embedded.
  Future<List<ConversationDto>> loadConversations() => _decode(
    () async => [
      for (final json in await _json.loadObjectList(conversationsPath))
        ConversationDto.fromJson(json),
    ],
  );

  /// Every seed message. [demoSenderId] marks the demo user's own.
  Future<List<MessageDto>> loadMessages() => _decode(
    () async => [
      for (final json in await _json.loadObjectList(messagesPath))
        MessageDto.fromJson(json),
    ],
  );

  /// The demo user's notifications.
  Future<List<NotificationDto>> loadNotifications() => _decode(
    () async => [
      for (final json in await _json.loadObjectList(notificationsPath))
        NotificationDto.fromJson(json),
    ],
  );

  /// Malformed seed data surfaces as the app's own [DataFormatException].
  Future<T> _decode<T>(Future<T> Function() load) async {
    try {
      return await load();
    } on FormatException {
      throw const DataFormatException();
    } on CheckedFromJsonException {
      throw const DataFormatException();
    }
  }
}
