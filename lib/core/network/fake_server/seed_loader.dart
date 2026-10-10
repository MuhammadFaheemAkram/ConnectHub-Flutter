import 'package:connect_hub/core/common/app_exception.dart';
import 'package:connect_hub/core/network/asset_json_loader.dart';
import 'package:connect_hub/core/network/dto/user_dto.dart';
import 'package:injectable/injectable.dart';
import 'package:json_annotation/json_annotation.dart';

/// Reads the fake server's seed data: the iOS edition's bundled JSON.
///
/// Later phases add the posts, comments, chats and notifications files.
@lazySingleton
class SeedLoader {
  const SeedLoader(this._json);

  final AssetJsonLoader _json;

  static const authUserPath = 'assets/json/auth_user.json';

  /// The demo user, including the email it signs in with.
  Future<UserDto> loadAuthUser() => _decode(
    () async => UserDto.fromJson(await _json.loadObject(authUserPath)),
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
