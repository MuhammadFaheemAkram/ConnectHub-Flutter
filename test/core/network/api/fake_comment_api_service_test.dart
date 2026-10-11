import 'package:connect_hub/core/common/app_exception.dart';
import 'package:connect_hub/core/network/api/fake_api_client.dart';
import 'package:connect_hub/core/network/api/fake_comment_api_service.dart';
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
  late FakeCommentApiService api;

  setUp(() {
    server = newFakeServer();
    network = NetworkSimulator(latencyFactor: 0);
    api = FakeCommentApiService(
      FakeApiClient(
        const SessionStorage(FlutterSecureStorage()),
        network,
        server,
      ),
      server,
    );
  });

  test('a comment is written as the signed-in user', () async {
    FlutterSecureStorage.setMockInitialValues(storedDemoSession());

    final comment = await api.addComment('p4', 'Hello');

    expect(comment.author.id, 'u_demo');
  });

  test('without a session, every call is a 401', () {
    FlutterSecureStorage.setMockInitialValues({});

    expect(api.getComments('p1'), throwsA(isA<UnauthorizedException>()));
    expect(api.deleteComment('c1'), throwsA(isA<UnauthorizedException>()));
  });

  test('every call fails while the network is down', () {
    FlutterSecureStorage.setMockInitialValues(storedDemoSession());
    network.failRequests = true;

    expect(api.getComments('p1'), throwsA(isA<NetworkException>()));
  });
}
