import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:connect_hub/core/design_system/design_system.dart';
import 'package:connect_hub/domain/model/message.dart';
import 'package:connect_hub/features/chat_detail/chat_detail_view.dart';
import 'package:connect_hub/features/chat_detail/cubit/chat_detail_cubit.dart';
import 'package:connect_hub/features/chat_detail/cubit/chat_detail_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/fixtures.dart';
import '../../helpers/pump_app.dart';

class _MockChatDetailCubit extends MockCubit<ChatDetailState>
    implements ChatDetailCubit {}

void main() {
  late _MockChatDetailCubit cubit;
  late List<String> opened;

  final m1 = sampleMessage('m1', minutesAgo: 10);
  final failed = sampleMessage(
    'm2',
    isMine: true,
    status: MessageStatus.failed,
  );

  setUpAll(() => registerFallbackValue(m1));

  setUp(() {
    cubit = _MockChatDetailCubit();
    opened = [];
    when(() => cubit.load()).thenAnswer((_) async {});
    when(() => cubit.send(any())).thenAnswer((_) async {});
    when(() => cubit.retry(any())).thenAnswer((_) async {});
  });

  Future<void> pumpView(WidgetTester tester, ChatDetailState state) async {
    when(() => cubit.state).thenReturn(state);
    tester.usePhoneSurface();
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: BlocProvider<ChatDetailCubit>.value(
          value: cubit,
          child: ChatDetailView(onOpenProfile: opened.add),
        ),
      ),
    );
  }

  ChatDetailState ready(List<Message> messages, {bool isTyping = false}) =>
      ChatDetailState(
        status: ChatStatus.ready,
        participant: grace,
        messages: messages,
        isTyping: isTyping,
      );

  testWidgets('loading shows the spinner', (tester) async {
    await pumpView(tester, const ChatDetailState());

    expect(find.text('Loading messages…'), findsOneWidget);
    expect(find.byType(ComposerBar), findsNothing);
  });

  testWidgets('a failure offers Try again', (tester) async {
    await pumpView(
      tester,
      const ChatDetailState(
        status: ChatStatus.failure,
        errorMessage: 'No connection.',
      ),
    );

    await tester.tap(find.text('Try again'));
    verify(() => cubit.load()).called(1);
  });

  testWidgets('a conversation that is gone says so', (tester) async {
    await pumpView(tester, const ChatDetailState(status: ChatStatus.notFound));

    expect(find.text("This conversation isn't available."), findsOneWidget);
  });

  testWidgets('an empty chat says hello', (tester) async {
    await pumpView(tester, ready(const []));

    expect(find.text('Say hello 👋'), findsOneWidget);
  });

  testWidgets('the title is the other person; tapping opens their profile', (
    tester,
  ) async {
    await pumpView(tester, ready([m1]));

    await tester.tap(find.text('Grace Hopper'));
    expect(opened, ['u_grace']);
  });

  testWidgets('bubbles, and the typing indicator while a reply is on its '
      'way', (tester) async {
    await pumpView(tester, ready([m1], isTyping: true));

    expect(find.text('Message m1'), findsOneWidget);
    expect(find.byType(TypingIndicator), findsOneWidget);
  });

  testWidgets('no reply on its way: no typing indicator', (tester) async {
    await pumpView(tester, ready([m1]));

    expect(find.byType(TypingIndicator), findsNothing);
  });

  testWidgets('Send hands the text over and clears the field at once', (
    tester,
  ) async {
    await pumpView(tester, ready([m1]));

    await tester.enterText(find.byType(TextField), 'Hello');
    await tester.pump();
    await tester.tap(find.byTooltip('Send'));
    await tester.pump();

    verify(() => cubit.send('Hello')).called(1);
    expect(find.text('Hello'), findsNothing);
  });

  testWidgets('tapping a failed message retries it', (tester) async {
    await pumpView(tester, ready([m1, failed]));

    await tester.tap(find.text('Message m2'));
    verify(() => cubit.retry(failed)).called(1);
  });

  testWidgets('a new message scrolls the list back to it (a one-time '
      'effect)', (tester) async {
    final history = [
      for (var i = 0; i < 30; i++) sampleMessage('h$i', minutesAgo: 60 - i),
    ];
    final states = StreamController<ChatDetailState>();
    addTearDown(states.close);
    whenListen(cubit, states.stream, initialState: ready(history));
    tester.usePhoneSurface();
    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<ChatDetailCubit>.value(
          value: cubit,
          child: ChatDetailView(onOpenProfile: (_) {}),
        ),
      ),
    );
    // Read back up the history (the list is reversed: up is away from 0).
    await tester.drag(find.byType(ListView), const Offset(0, 600));
    await tester.pumpAndSettle();
    // The list's own Scrollable (the composer's text field has one too).
    final position = tester
        .state<ScrollableState>(
          find
              .descendant(
                of: find.byType(ListView),
                matching: find.byType(Scrollable),
              )
              .first,
        )
        .position;
    expect(position.pixels, greaterThan(0));

    states.add(ready([...history, sampleMessage('reply')]));
    await tester.pumpAndSettle();

    expect(position.pixels, 0);
    expect(find.text('Message reply'), findsOneWidget);
  });
}
