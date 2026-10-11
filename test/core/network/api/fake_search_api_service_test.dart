import 'package:connect_hub/core/common/app_exception.dart';
import 'package:connect_hub/core/network/api/fake_api_client.dart';
import 'package:connect_hub/core/network/api/fake_search_api_service.dart';
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
  late FakeSearchApiService api;

  setUp(() {
    server = newFakeServer();
    network = NetworkSimulator(latencyFactor: 0);
    api = FakeSearchApiService(
      FakeApiClient(
        const SessionStorage(FlutterSecureStorage()),
        network,
        server,
      ),
      server,
    );
  });

  test(
    'searches as the signed-in user, who is left out of the people',
    () async {
      FlutterSecureStorage.setMockInitialValues(storedDemoSession());

      final response = await api.search('demo');

      expect(response.users, isEmpty);
      expect(response.posts.map((post) => post.id), contains('p16'));
    },
  );

  test('without a session, a search is a 401', () {
    FlutterSecureStorage.setMockInitialValues({});

    expect(api.search('ada'), throwsA(isA<UnauthorizedException>()));
  });

  test('a search fails while the network is down', () {
    FlutterSecureStorage.setMockInitialValues(storedDemoSession());
    network.failRequests = true;

    expect(api.search('ada'), throwsA(isA<NetworkException>()));
  });
}
