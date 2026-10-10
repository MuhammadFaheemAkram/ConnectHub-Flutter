import 'package:connect_hub/core/network/dto/auth_response_dto.dart';
import 'package:connect_hub/core/storage/session_storage.dart';
import 'package:connect_hub/domain/model/session.dart';

extension AuthResponseDtoMapper on AuthResponseDto {
  /// The session this sign-in grants. The server always includes the email
  /// for the user's own record; [fallbackEmail] (what was typed) covers a
  /// response that doesn't.
  Session toSession({required String fallbackEmail}) => Session(
    userId: user.id,
    email: user.email ?? fallbackEmail,
    token: token,
  );
}

extension StoredSessionMapper on StoredSession {
  Session toSession() => Session(userId: userId, email: email, token: token);
}

extension SessionStorageMapper on Session {
  StoredSession toStored() => (token: token, userId: userId, email: email);
}
