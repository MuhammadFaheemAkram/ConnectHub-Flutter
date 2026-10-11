import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:connect_hub/core/design_system/design_system.dart';
import 'package:connect_hub/domain/model/comment.dart';
import 'package:connect_hub/features/comments/comments_view.dart';
import 'package:connect_hub/features/comments/cubit/comments_cubit.dart';
import 'package:connect_hub/features/comments/cubit/comments_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/fixtures.dart';
import '../../helpers/pump_app.dart';

class _MockCommentsCubit extends MockCubit<CommentsState>
    implements CommentsCubit {}

void main() {
  late _MockCommentsCubit cubit;
  late List<String> opened;

  final theirs = sampleComment('c1', minutesAgo: 10);
  final mine = sampleComment('c2', isMine: true);

  setUpAll(() => registerFallbackValue(sampleComment('fallback')));

  setUp(() {
    cubit = _MockCommentsCubit();
    opened = [];
    when(() => cubit.load()).thenAnswer((_) async {});
    when(() => cubit.refresh()).thenAnswer((_) async {});
    when(() => cubit.send(any())).thenAnswer((_) async {});
    when(() => cubit.delete(any())).thenAnswer((_) async {});
  });

  Future<void> pumpView(WidgetTester tester, CommentsState state) async {
    when(() => cubit.state).thenReturn(state);
    tester.usePhoneSurface();
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: BlocProvider<CommentsCubit>.value(
          value: cubit,
          child: CommentsView(onOpenProfile: (id) => opened.add(id)),
        ),
      ),
    );
  }

  CommentsState loaded(List<Comment> comments) =>
      CommentsState(status: CommentsStatus.loaded, comments: comments);

  Finder commentField() => find.widgetWithText(TextField, 'Add a comment…');

  testWidgets('loading shows the spinner', (tester) async {
    await pumpView(tester, const CommentsState());

    expect(find.text('Loading comments…'), findsOneWidget);
  });

  testWidgets('a failure offers Try again, and no input', (tester) async {
    await pumpView(
      tester,
      const CommentsState(
        status: CommentsStatus.failure,
        errorMessage: 'No connection.',
      ),
    );

    expect(commentField(), findsNothing);
    await tester.tap(find.text('Try again'));

    verify(() => cubit.load()).called(1);
  });

  testWidgets('no comments invites the first one, with the input ready', (
    tester,
  ) async {
    await pumpView(tester, loaded([]));

    expect(find.text('No comments yet'), findsOneWidget);
    expect(find.text('Be the first to comment.'), findsOneWidget);
    expect(commentField(), findsOneWidget);
  });

  testWidgets('my comments say "You" and are the only ones with a menu', (
    tester,
  ) async {
    await pumpView(tester, loaded([theirs, mine]));

    expect(find.text('Ada Lovelace'), findsOneWidget);
    expect(find.text('You'), findsOneWidget);
    expect(find.byTooltip('Comment options'), findsOneWidget);
  });

  testWidgets('deleting asks first: Cancel keeps it, Delete removes it', (
    tester,
  ) async {
    await pumpView(tester, loaded([theirs, mine]));

    await tester.tap(find.byTooltip('Comment options'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();
    expect(find.text('Delete comment?'), findsOneWidget);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    verifyNever(() => cubit.delete(any()));

    await tester.tap(find.byTooltip('Comment options'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Delete'));
    await tester.pumpAndSettle();

    verify(() => cubit.delete(mine)).called(1);
  });

  testWidgets("an author's picture opens their profile", (tester) async {
    await pumpView(tester, loaded([theirs]));

    await tester.tap(find.byType(UserAvatar));

    expect(opened, ['u_ada']);
  });

  testWidgets('sending passes the text on, and a sent comment clears it', (
    tester,
  ) async {
    final states = StreamController<CommentsState>();
    addTearDown(states.close);
    whenListen(cubit, states.stream, initialState: loaded([theirs]));
    await pumpView(tester, loaded([theirs]));

    await tester.enterText(commentField(), 'Me too');
    await tester.pump();
    await tester.tap(find.byTooltip('Send'));
    verify(() => cubit.send('Me too')).called(1);

    states.add(loaded([theirs, mine]).copyWith(sentCount: 1));
    await tester.pumpAndSettle();
    expect(find.text('Me too'), findsNothing);
  });
}
