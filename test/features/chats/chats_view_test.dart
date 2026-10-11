import 'package:bloc_test/bloc_test.dart';
import 'package:connect_hub/core/design_system/design_system.dart';
import 'package:connect_hub/domain/model/conversation.dart';
import 'package:connect_hub/features/chats/chats_view.dart';
import 'package:connect_hub/features/chats/cubit/chats_cubit.dart';
import 'package:connect_hub/features/chats/cubit/chats_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/fixtures.dart';
import '../../helpers/pump_app.dart';

class _MockChatsCubit extends MockCubit<ChatsState> implements ChatsCubit {}

void main() {
  late _MockChatsCubit cubit;
  late List<String> opened;

  final withGrace = sampleConversation('c1', unreadCount: 2);
  final withAlan = sampleConversation('c2', participant: alan);

  setUp(() {
    cubit = _MockChatsCubit();
    opened = [];
    when(() => cubit.load()).thenAnswer((_) async {});
    when(() => cubit.refresh()).thenAnswer((_) async {});
  });

  Future<void> pumpView(WidgetTester tester, ChatsState state) async {
    when(() => cubit.state).thenReturn(state);
    tester.usePhoneSurface();
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: BlocProvider<ChatsCubit>.value(
          value: cubit,
          child: ChatsView(onOpenChat: opened.add),
        ),
      ),
    );
  }

  ChatsState loaded(List<Conversation> list, {String query = ''}) =>
      ChatsState(status: ChatsStatus.loaded, conversations: list, query: query);

  testWidgets('loading shows the spinner', (tester) async {
    await pumpView(tester, const ChatsState());

    expect(find.text('Loading chats…'), findsOneWidget);
  });

  testWidgets('a failure offers Try again', (tester) async {
    await pumpView(
      tester,
      const ChatsState(
        status: ChatsStatus.failure,
        errorMessage: 'No connection.',
      ),
    );

    await tester.tap(find.text('Try again'));
    verify(() => cubit.load()).called(1);
  });

  // One state per test: a mocked Cubit's state is read once (§11.31).
  testWidgets('no conversations says so', (tester) async {
    await pumpView(tester, loaded(const []));

    expect(find.text('No conversations'), findsOneWidget);
  });

  testWidgets('no matches for the search says so differently', (tester) async {
    await pumpView(tester, loaded([withGrace], query: 'zzz'));

    expect(find.text('No chats match “zzz”.'), findsOneWidget);
  });

  testWidgets('rows open their chat', (tester) async {
    await pumpView(tester, loaded([withGrace, withAlan]));

    await tester.tap(find.text('Alan Turing'));
    expect(opened, ['c2']);
  });

  testWidgets('typing in the search field filters (no debounce needed)', (
    tester,
  ) async {
    await pumpView(tester, loaded([withGrace, withAlan]));

    await tester.enterText(find.byType(AppSearchField), 'gr');
    verify(() => cubit.search('gr')).called(1);
  });
}
