import 'package:connect_hub/core/common/app_exception.dart';
import 'package:connect_hub/core/common/demo_account.dart';
import 'package:connect_hub/core/common/id_generator.dart';
import 'package:connect_hub/core/network/dto/auth_response_dto.dart';
import 'package:connect_hub/core/network/dto/user_dto.dart';
import 'package:connect_hub/core/network/fake_server/seed_loader.dart';
import 'package:injectable/injectable.dart';

/// An in-memory stand-in for ConnectHub's backend.
///
/// It plays the role a REST server would: it owns the data and its rules
/// (accounts, tokens; later posts, comments, chats). The rest of the app
/// reaches it **only** through the `…ApiService` interfaces, so a real HTTP
/// client could replace the fake services without changing any caller.
///
/// It lives in memory and seeds itself from the bundled JSON on first use.
/// Every launch therefore starts from the same seed: accounts created by sign
/// up last until the app restarts. That's deliberate, because the backend is
/// not the point of this project; how the app talks to it is.
///
/// Transport concerns (latency, simulated failures) live in the fake API
/// services, not here.
@lazySingleton
class FakeServer {
  FakeServer(this._seeds, this._ids);

  final SeedLoader _seeds;
  final IdGenerator _ids;

  Future<void>? _seeding;

  /// Accounts by normalized (trimmed, lower-case) email.
  final _accounts = <String, _Account>{};

  /// User profiles by id.
  final _users = <String, UserDto>{};

  /// Tokens revoked by "Expire session" (Settings → Developer).
  final _revokedTokens = <String>{};

  /// Signs in with an email and password.
  ///
  /// Throws [InvalidCredentialsException] for an unknown email *and* for a
  /// wrong password, so the response doesn't reveal which emails exist.
  Future<AuthResponseDto> login({
    required String email,
    required String password,
  }) async {
    await _ready();
    final account = _accounts[_normalize(email)];
    if (account == null || account.password != password) {
      throw const InvalidCredentialsException();
    }
    return _authResponse(account.userId);
  }

  /// Creates an account and signs it in.
  ///
  /// Throws [EmailTakenException] when the email (compared
  /// case-insensitively) already has an account.
  Future<AuthResponseDto> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    await _ready();
    final key = _normalize(email);
    if (_accounts.containsKey(key)) throw const EmailTakenException();

    final user = UserDto(
      id: _ids.next('u'),
      name: name.trim(),
      email: key,
      bio: 'New to ConnectHub 👋',
    );
    _users[user.id] = user;
    _accounts[key] = _Account(userId: user.id, password: password);
    return _authResponse(user.id);
  }

  /// Resolves a bearer token to its user id, like an auth middleware.
  ///
  /// Tokens are self-describing (`fake.<userId>.<random>`), so the server
  /// needn't remember the ones it issued: any well-formed token for an
  /// existing user is valid unless it was revoked. The demo user is seeded on
  /// every launch, so the demo session survives restarts; an account created
  /// by sign up doesn't, and its token then fails with
  /// [UnauthorizedException].
  Future<String> authenticate(String? token) async {
    await _ready();
    final userId = _userIdIn(token);
    if (userId == null ||
        _revokedTokens.contains(token) ||
        !_users.containsKey(userId)) {
      throw const UnauthorizedException();
    }
    return userId;
  }

  /// Makes [token] invalid from now on (Settings → Developer → Expire
  /// session).
  void revoke(String token) => _revokedTokens.add(token);

  Future<void> _ready() => _seeding ??= _seed();

  Future<void> _seed() async {
    final demo = await _seeds.loadAuthUser();
    _users[demo.id] = demo;
    _accounts[_normalize(demo.email ?? DemoAccount.email)] = _Account(
      userId: demo.id,
      password: DemoAccount.password,
    );
  }

  AuthResponseDto _authResponse(String userId) => AuthResponseDto(
    token: 'fake.$userId.${_ids.hex(16)}',
    user: _users[userId]!,
  );

  static String _normalize(String email) => email.trim().toLowerCase();

  static String? _userIdIn(String? token) {
    final parts = token?.split('.');
    if (parts == null || parts.length != 3 || parts.first != 'fake') {
      return null;
    }
    return parts[1];
  }
}

/// Server-side account record: which user an email signs in as, and the
/// password it signs in with.
final class _Account {
  const _Account({required this.userId, required this.password});

  final String userId;
  final String password;
}
