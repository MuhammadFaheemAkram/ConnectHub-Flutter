import 'package:connect_hub/core/common/app_exception.dart';
import 'package:connect_hub/core/network/api/fake_api_client.dart';
import 'package:connect_hub/core/network/api/fake_notification_api_service.dart';
import 'package:connect_hub/core/network/fake_server/fake_server.dart';
import 'package:connect_hub/core/network/fake_server/network_simulator.dart';
import 'package:connect_hub/core/storage/session_storage.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/backend.dart';
import '../../../helpers/test_dependencies.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakeServer server;
  late NetworkSimulator network;
  late FakeNotificationApiService api;

  setUp(() {
    server = newFakeServer();
    network = NetworkSimulator(latencyFactor: 0);
    api = FakeNotificationApiService(
      FakeApiClient(
        const SessionStorage(FlutterSecureStorage()),
        network,
        server,
      ),
      server,
    );
  });

  tearDown(() => server.dispose());

  test(
    "the signed-in user's notifications; marking read reaches the server",
    () async {
      FlutterSecureStorage.setMockInitialValues(storedDemoSession());

      expect(await api.getNotifications(), hasLength(8));
      await api.markRead('n1');
      expect((await api.getNotifications()).first.isRead, isTrue);

      await api.markAllRead();
      expect((await api.getNotifications()).every((n) => n.isRead), isTrue);
    },
  );

  test('without a session, every call is a 401', () {
    FlutterSecureStorage.setMockInitialValues({});

    expect(api.getNotifications(), throwsA(isA<UnauthorizedException>()));
    expect(api.markAllRead(), throwsA(isA<UnauthorizedException>()));
  });

  test('every call fails while the network is down', () {
    FlutterSecureStorage.setMockInitialValues(storedDemoSession());
    network.failRequests = true;

    expect(api.markRead('n1'), throwsA(isA<NetworkException>()));
  });
}
