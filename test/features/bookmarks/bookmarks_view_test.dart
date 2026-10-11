import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:connect_hub/core/common/ui_message.dart';
import 'package:connect_hub/core/design_system/design_system.dart';
import 'package:connect_hub/domain/model/post.dart';
import 'package:connect_hub/features/bookmarks/bookmarks_view.dart';
import 'package:connect_hub/features/bookmarks/cubit/bookmarks_cubit.dart';
import 'package:connect_hub/features/bookmarks/cubit/bookmarks_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/fixtures.dart';
import '../../helpers/pump_app.dart';

class _MockBookmarksCubit extends MockCubit<BookmarksState>
    implements BookmarksCubit {}

void main() {
  late _MockBookmarksCubit cubit;
  late List<String> opened;

  final p1 = samplePost('p1', isBookmarked: true);

  setUpAll(() => registerFallbackValue(samplePost('fallback')));

  setUp(() {
    cubit = _MockBookmarksCubit();
    opened = [];
    when(() => cubit.load()).thenAnswer((_) async {});
    when(() => cubit.refresh()).thenAnswer((_) async {});
    when(() => cubit.remove(any())).thenAnswer((_) async {});
    when(() => cubit.undoRemove()).thenAnswer((_) async {});
    when(() => cubit.toggleLike(any())).thenAnswer((_) async {});
  });

  Future<void> pumpView(WidgetTester tester, BookmarksState state) async {
    when(() => cubit.state).thenReturn(state);
    tester.usePhoneSurface();
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: BlocProvider<BookmarksCubit>.value(
          value: cubit,
          child: BookmarksView(
            onOpenPost: opened.add,
            onOpenComments: opened.add,
            onOpenProfile: opened.add,
          ),
        ),
      ),
    );
  }

  BookmarksState loaded(List<Post> posts, {UiMessage? message}) =>
      BookmarksState(
        status: BookmarksStatus.loaded,
        posts: posts,
        message: message,
      );

  testWidgets('loading shows the spinner', (tester) async {
    await pumpView(tester, const BookmarksState());

    expect(find.text('Loading bookmarks…'), findsOneWidget);
  });

  testWidgets('none yet explains how to add one', (tester) async {
    await pumpView(tester, loaded(const []));

    expect(find.text('No bookmarks yet'), findsOneWidget);
    expect(
      find.text('Tap the bookmark icon on a post to save it here.'),
      findsOneWidget,
    );
  });

  testWidgets('a failure offers Try again', (tester) async {
    await pumpView(
      tester,
      const BookmarksState(
        status: BookmarksStatus.failure,
        errorMessage: 'No connection.',
      ),
    );

    await tester.tap(find.text('Try again'));

    verify(() => cubit.load()).called(1);
  });

  testWidgets('each post works as everywhere: open, like, and the bookmark '
      'button removes it', (tester) async {
    await pumpView(tester, loaded([p1]));

    await tester.tap(find.text('Post p1'));
    await tester.tap(find.byTooltip('Like'));
    await tester.tap(find.byTooltip('Remove bookmark'));

    expect(opened, ['p1']);
    verify(() => cubit.toggleLike(p1)).called(1);
    verify(() => cubit.remove(p1)).called(1);
  });

  testWidgets('"Removed from bookmarks" offers Undo', (tester) async {
    final states = StreamController<BookmarksState>();
    addTearDown(states.close);
    whenListen(cubit, states.stream, initialState: loaded([p1]));
    await pumpView(tester, loaded([p1]));

    states.add(
      loaded(
        const [],
        message: const UiMessage(
          id: 1,
          text: BookmarksCubit.removedMessage,
          action: UiMessageAction.undo,
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 750));

    expect(find.text('Removed from bookmarks'), findsOneWidget);
    await tester.tap(find.widgetWithText(SnackBarAction, 'Undo'));
    verify(() => cubit.undoRemove()).called(1);
  });
}
