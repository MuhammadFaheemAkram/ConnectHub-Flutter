import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:connect_hub/core/common/ui_message.dart';
import 'package:connect_hub/core/design_system/design_system.dart';
import 'package:connect_hub/features/post_detail/cubit/post_detail_cubit.dart';
import 'package:connect_hub/features/post_detail/cubit/post_detail_state.dart';
import 'package:connect_hub/features/post_detail/post_detail_view.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/fixtures.dart';
import '../../helpers/pump_app.dart';

class _MockPostDetailCubit extends MockCubit<PostDetailState>
    implements PostDetailCubit {}

void main() {
  late _MockPostDetailCubit cubit;
  late List<String> opened;

  final p1 = samplePost('p1', commentCount: 3);
  final recent = [sampleComment('c2'), sampleComment('c3')];

  setUpAll(() => registerFallbackValue(samplePost('fallback')));

  setUp(() {
    cubit = _MockPostDetailCubit();
    opened = [];
    when(() => cubit.load()).thenAnswer((_) async {});
    when(() => cubit.refresh()).thenAnswer((_) async {});
    when(() => cubit.sendComment(any())).thenAnswer((_) async {});
    when(() => cubit.toggleLike(any())).thenAnswer((_) async {});
    when(() => cubit.toggleBookmark(any())).thenAnswer((_) async {});
  });

  Future<void> pumpView(WidgetTester tester, PostDetailState state) async {
    when(() => cubit.state).thenReturn(state);
    tester.usePhoneSurface();
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: BlocProvider<PostDetailCubit>.value(
          value: cubit,
          child: PostDetailView(
            onOpenComments: () => opened.add('comments'),
            onOpenProfile: (id) => opened.add('profile:$id'),
          ),
        ),
      ),
    );
  }

  // The tooltip sits inside the button, so find the button around it.
  IconButton sendButton(WidgetTester tester) => tester.widget<IconButton>(
    find.ancestor(
      of: find.byTooltip('Send'),
      matching: find.byType(IconButton),
    ),
  );
  Finder commentField() => find.widgetWithText(TextField, 'Add a comment…');

  testWidgets('loading shows the spinner', (tester) async {
    await pumpView(tester, const PostDetailState.loading());

    expect(find.text('Loading post…'), findsOneWidget);
  });

  testWidgets('an error offers Try again', (tester) async {
    await pumpView(tester, const PostDetailState.error('No connection.'));

    await tester.tap(find.text('Try again'));

    verify(() => cubit.load()).called(1);
  });

  testWidgets('a post that no longer exists says so', (tester) async {
    await pumpView(tester, const PostDetailState.notFound());

    expect(find.text('This post is no longer available.'), findsOneWidget);
    expect(commentField(), findsNothing);
  });

  testWidgets('shows the post, its latest comments, and a link to all', (
    tester,
  ) async {
    await pumpView(
      tester,
      PostDetailState.loaded(post: p1, recentComments: recent),
    );

    expect(find.text('Post p1'), findsOneWidget);
    expect(find.text('Comment c2'), findsOneWidget);
    expect(find.text('Comment c3'), findsOneWidget);
    await tester.tap(find.text('View all 3 comments'));

    expect(opened, ['comments']);
  });

  testWidgets('with no comments it invites the first one', (tester) async {
    await pumpView(tester, PostDetailState.loaded(post: samplePost('p1')));

    expect(
      find.text('No comments yet. Be the first to comment.'),
      findsOneWidget,
    );
    expect(find.textContaining('View all'), findsNothing);
  });

  testWidgets('like, bookmark and the author reach their handlers', (
    tester,
  ) async {
    await pumpView(tester, PostDetailState.loaded(post: p1));

    await tester.tap(find.byTooltip('Like'));
    await tester.tap(find.byTooltip('Bookmark'));
    await tester.tap(find.text('Ada Lovelace'));

    verify(() => cubit.toggleLike(p1)).called(1);
    verify(() => cubit.toggleBookmark(p1)).called(1);
    expect(opened, ['profile:u_ada']);
  });

  group('the comment input', () {
    testWidgets('Send is disabled while the text is blank', (tester) async {
      await pumpView(tester, PostDetailState.loaded(post: p1));

      expect(sendButton(tester).onPressed, isNull);
      await tester.enterText(commentField(), '   ');
      await tester.pump();
      expect(sendButton(tester).onPressed, isNull);

      await tester.enterText(commentField(), 'Great post');
      await tester.pump();
      await tester.tap(find.byTooltip('Send'));

      verify(() => cubit.sendComment('Great post')).called(1);
    });

    testWidgets('while sending, Send shows progress and is disabled', (
      tester,
    ) async {
      await pumpView(tester, PostDetailState.loaded(post: p1, isSending: true));
      await tester.enterText(commentField(), 'Great post');
      await tester.pump();

      expect(find.bySemanticsLabel('Sending'), findsOneWidget);
      expect(sendButton(tester).onPressed, isNull);
    });

    testWidgets('a sent comment clears the input', (tester) async {
      final states = StreamController<PostDetailState>();
      addTearDown(states.close);
      final sending = PostDetailState.loaded(post: p1, isSending: true);
      whenListen(cubit, states.stream, initialState: sending);
      await pumpView(tester, sending);
      await tester.enterText(commentField(), 'Great post');

      states.add(PostDetailState.loaded(post: p1, sentCount: 1));
      await tester.pump();

      expect(find.text('Great post'), findsNothing);
    });

    testWidgets('a failure shows a SnackBar and keeps the text', (
      tester,
    ) async {
      whenListen(
        cubit,
        Stream.value(
          PostDetailState.loaded(
            post: p1,
            message: const UiMessage(
              id: 1,
              text: PostDetailCubit.sendFailedMessage,
            ),
          ),
        ),
        initialState: PostDetailState.loaded(post: p1),
      );
      await pumpView(tester, PostDetailState.loaded(post: p1));
      await tester.enterText(commentField(), 'Great post');

      await tester.pump();

      expect(find.text(PostDetailCubit.sendFailedMessage), findsOneWidget);
      expect(find.text('Great post'), findsOneWidget);
    });
  });
}
