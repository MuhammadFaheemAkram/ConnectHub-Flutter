import 'package:async/async.dart';
import 'package:connect_hub/core/common/app_exception.dart';
import 'package:connect_hub/core/network/api/fake_api_client.dart';
import 'package:connect_hub/core/network/api/fake_chat_api_service.dart';
import 'package:connect_hub/core/network/dto/chat_event_dto.dart';
import 'package:connect_hub/core/network/fake_server/fake_server.dart';
import 'package:connect_hub/core/network/fake_server/network_simulator.dart';
import 'package:connect_hub/core/storage/session_storage.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/backend.dart';
import '../../../helpers/stream_helpers.dart';
import '../../../helpers/test_dependencies.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakeServer server;
  late NetworkSimulator network;
  late FakeChatApiService api;

  setUp(() {
    server = newFakeServer(replies: quickReplies());
    network = NetworkSimulator(latencyFactor: 0);
    api = FakeChatApiService(
      FakeApiClient(
        const SessionStorage(FlutterSecureStorage()),
        network,
        server,
      ),
      server,
    );
  });

  tearDown(() => server.dispose());

  test("the signed-in user's conversations and messages", () async {
    FlutterSecureStorage.setMockInitialValues(storedDemoSession());

    expect((await api.getConversations()).map((c) => c.id), ['c1', 'c2', 'c3']);
    expect(await api.getMessages('c1'), hasLength(4));
  });

  test(
    "a message is sent as the signed-in user, with the client's id",
    () async {
      FlutterSecureStorage.setMockInitialValues(storedDemoSession());

      final message = await api.sendMessage('c2', clientId: 'm_a', text: 'Hi');

      expect(message.id, 'm_a');
      expect(message.senderId, 'u_demo');
    },
  );

  test(
    'the realtime channel delivers what happens in my conversations',
    () async {
      FlutterSecureStorage.setMockInitialValues(storedDemoSession());
      final events = StreamQueue(api.events());
      addTearDown(events.cancel);
      // Connecting is asynchronous: wait until the channel is listening.
      await pumpEventQueue();

      await api.sendMessage('c2', clientId: 'm_a', text: 'Hi');

      expect(await nextEvent(events), isA<TypingStartedEvent>());
      expect(await nextEvent(events), isA<MessageReceivedEvent>());
      expect(await nextEvent(events), isA<TypingStoppedEvent>());
    },
  );

  test('without a session, every call is a 401, and so is connecting', () {
    FlutterSecureStorage.setMockInitialValues({});

    expect(api.getConversations(), throwsA(isA<UnauthorizedException>()));
    expect(
      api.sendMessage('c2', clientId: 'm_a', text: 'Hi'),
      throwsA(isA<UnauthorizedException>()),
    );
    expect(api.events(), emitsError(isA<UnauthorizedException>()));
  });

  test(
    'every call fails while the network is down, and so does connecting',
    () {
      FlutterSecureStorage.setMockInitialValues(storedDemoSession());
      network.failRequests = true;

      expect(api.getMessages('c1'), throwsA(isA<NetworkException>()));
      expect(api.markRead('c1'), throwsA(isA<NetworkException>()));
      expect(api.events(), emitsError(isA<NetworkException>()));
    },
  );
}
