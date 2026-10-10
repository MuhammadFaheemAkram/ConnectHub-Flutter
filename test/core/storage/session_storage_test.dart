import 'package:connect_hub/core/storage/session_storage.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const storage = SessionStorage(FlutterSecureStorage());
  const session = (token: 'fake.u_demo.abc', userId: 'u_demo', email: 'a@b.co');

  setUp(() => FlutterSecureStorage.setMockInitialValues({}));

  test('reads nothing until a session is written', () async {
    expect(await storage.read(), isNull);
  });

  test('round-trips a session', () async {
    await storage.write(session);

    expect(await storage.read(), session);
  });

  test('delete removes it', () async {
    await storage.write(session);
    await storage.delete();

    expect(await storage.read(), isNull);
  });

  test('a corrupt entry reads as signed out, and is removed', () async {
    FlutterSecureStorage.setMockInitialValues({'session': 'not json'});

    expect(await storage.read(), isNull);
    expect(await const FlutterSecureStorage().read(key: 'session'), isNull);
  });
}
