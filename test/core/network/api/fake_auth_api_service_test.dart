import 'package:connect_hub/core/common/app_exception.dart';
import 'package:connect_hub/core/common/demo_account.dart';
import 'package:connect_hub/core/network/api/fake_auth_api_service.dart';
import 'package:connect_hub/core/network/fake_server/network_simulator.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/backend.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late NetworkSimulator network;
  late FakeAuthApiService api;

  setUp(() {
    network = NetworkSimulator(latencyFactor: 0);
    api = FakeAuthApiService(newFakeServer(), network);
  });

  test('passes requests through to the server', () async {
    final response = await api.login(
      email: DemoAccount.email,
      password: DemoAccount.password,
    );

    expect(response.user.id, 'u_demo');
  });

  test('every request fails while the network simulates a failure', () {
    network.failRequests = true;

    expect(
      api.login(email: DemoAccount.email, password: DemoAccount.password),
      throwsA(isA<NetworkException>()),
    );
    expect(
      api.signUp(name: 'Ada', email: 'ada@example.com', password: 'engines'),
      throwsA(isA<NetworkException>()),
    );
  });
}
