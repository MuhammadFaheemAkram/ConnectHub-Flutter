import 'dart:math';

import 'package:connect_hub/core/common/app_exception.dart';
import 'package:connect_hub/core/common/demo_account.dart';
import 'package:connect_hub/core/common/id_generator.dart';
import 'package:connect_hub/core/network/api/fake_auth_api_service.dart';
import 'package:connect_hub/core/network/asset_json_loader.dart';
import 'package:connect_hub/core/network/fake_server/fake_server.dart';
import 'package:connect_hub/core/network/fake_server/network_simulator.dart';
import 'package:connect_hub/core/network/fake_server/seed_loader.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late NetworkSimulator network;
  late FakeAuthApiService api;

  setUp(() {
    network = NetworkSimulator(latencyFactor: 0);
    api = FakeAuthApiService(
      FakeServer(
        SeedLoader(AssetJsonLoader(rootBundle)),
        IdGenerator(random: Random(1)),
      ),
      network,
    );
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
