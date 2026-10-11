import 'package:connect_hub/core/common/app_exception.dart';
import 'package:connect_hub/core/network/api/fake_api_client.dart';
import 'package:connect_hub/core/network/api/fake_user_api_service.dart';
import 'package:connect_hub/core/network/dto/update_profile_request_dto.dart';
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
  late FakeUserApiService api;

  const request = UpdateProfileRequestDto(name: 'Demo Person', bio: 'Hi');

  setUp(() {
    server = newFakeServer();
    network = NetworkSimulator(latencyFactor: 0);
    api = FakeUserApiService(
      FakeApiClient(
        const SessionStorage(FlutterSecureStorage()),
        network,
        server,
      ),
      server,
    );
  });

  test(
    'PATCH /me changes the signed-in user, whoever the token says',
    () async {
      FlutterSecureStorage.setMockInitialValues(storedDemoSession());

      final me = await api.updateMe(request);

      expect(me.id, 'u_demo');
      expect((await server.getUser('u_demo')).name, 'Demo Person');
    },
  );

  test("a user's posts come as the signed-in user sees them", () async {
    FlutterSecureStorage.setMockInitialValues(storedDemoSession());
    await server.setLiked('u_demo', 'p1', liked: true);

    final posts = await api.getUserPosts('u_ada');

    expect(posts.first.id, 'p1');
    expect(posts.first.isLiked, isTrue);
  });

  test('without a session, every call is a 401', () {
    FlutterSecureStorage.setMockInitialValues({});

    expect(api.getUser('u_ada'), throwsA(isA<UnauthorizedException>()));
    expect(api.getUserPosts('u_ada'), throwsA(isA<UnauthorizedException>()));
    expect(api.updateMe(request), throwsA(isA<UnauthorizedException>()));
  });

  test('every call fails while the network is down', () {
    FlutterSecureStorage.setMockInitialValues(storedDemoSession());
    network.failRequests = true;

    expect(api.getUser('u_ada'), throwsA(isA<NetworkException>()));
  });
}
