import 'package:bloc_test/bloc_test.dart';
import 'package:connect_hub/core/common/ui_message.dart';
import 'package:connect_hub/core/design_system/design_system.dart';
import 'package:connect_hub/domain/model/post.dart';
import 'package:connect_hub/features/feed/cubit/feed_cubit.dart';
import 'package:connect_hub/features/feed/cubit/feed_state.dart';
import 'package:connect_hub/features/feed/feed_view.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/fixtures.dart';
import '../../helpers/pump_app.dart';

class _MockFeedCubit extends MockCubit<FeedState> implements FeedCubit {}

void main() {
  late _MockFeedCubit cubit;
  late List<String> opened;

  final p1 = samplePost('p1');
  final p2 = samplePost('p2', commentCount: 2);

  setUpAll(() => registerFallbackValue(samplePost('fallback')));

  setUp(() {
    cubit = _MockFeedCubit();
    opened = [];
    when(() => cubit.load()).thenAnswer((_) async {});
    when(() => cubit.refresh()).thenAnswer((_) async {});
    when(() => cubit.loadMore()).thenAnswer((_) async {});
    when(() => cubit.toggleLike(any())).thenAnswer((_) async {});
    when(() => cubit.toggleBookmark(any())).thenAnswer((_) async {});
  });

  Future<void> pumpView(WidgetTester tester, FeedState state) async {
    when(() => cubit.state).thenReturn(state);
    tester.usePhoneSurface();
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: BlocProvider<FeedCubit>.value(
          value: cubit,
          child: FeedView(
            onOpenPost: (id) => opened.add('post:$id'),
            onOpenComments: (id) => opened.add('comments:$id'),
            onOpenProfile: (id) => opened.add('profile:$id'),
            onOpenChats: () => opened.add('chats'),
            onCreatePost: () => opened.add('compose'),
          ),
        ),
      ),
    );
  }

  FeedState loaded(
    List<Post> posts, {
    bool hasMore = true,
    LoadMoreStatus loadMore = LoadMoreStatus.idle,
  }) => FeedState.loaded(posts: posts, hasMore: hasMore, loadMore: loadMore);

  testWidgets('loading shows the spinner', (tester) async {
    await pumpView(tester, const FeedState.loading());

    expect(find.text('Loading posts…'), findsOneWidget);
  });

  testWidgets('posts render as cards', (tester) async {
    await pumpView(tester, loaded([p1, p2]));

    expect(find.byType(PostCard), findsNWidgets(2));
    expect(find.text('Post p1'), findsOneWidget);
    expect(find.text('Post p2'), findsOneWidget);
  });

  testWidgets('the empty state invites the first post', (tester) async {
    await pumpView(tester, const FeedState.empty());

    expect(find.text('No posts yet'), findsOneWidget);
    expect(
      find.text('Pull to refresh or share the first post.'),
      findsOneWidget,
    );
    await tester.tap(find.widgetWithText(FilledButton, 'New post'));

    expect(opened, ['compose']);
  });

  testWidgets('the error state retries with a full load', (tester) async {
    await pumpView(tester, const FeedState.error('No connection.'));

    expect(find.text('No connection.'), findsOneWidget);
    await tester.tap(find.text('Try again'));

    verify(() => cubit.load()).called(1);
  });

  testWidgets('the like button follows the state, and a tap reaches the '
      'Cubit', (tester) async {
    final liked = p1.copyWith(isLiked: true, likeCount: 11);
    whenListen(
      cubit,
      Stream.value(loaded([liked])),
      initialState: loaded([p1]),
    );
    await pumpView(tester, loaded([p1]));

    await tester.tap(find.byTooltip('Like'));
    verify(() => cubit.toggleLike(p1)).called(1);

    // The repository's write arrives as a new state.
    await tester.pump();
    expect(find.byTooltip('Unlike'), findsOneWidget);
    expect(find.text('11'), findsOneWidget);
  });

  testWidgets('the bookmark button reaches the Cubit', (tester) async {
    await pumpView(tester, loaded([p1]));

    await tester.tap(find.byTooltip('Bookmark'));

    verify(() => cubit.toggleBookmark(p1)).called(1);
  });

  testWidgets('the card, its author and its comments open their screens', (
    tester,
  ) async {
    await pumpView(tester, loaded([p2]));

    await tester.tap(find.text('Post p2'));
    await tester.tap(find.text('Ada Lovelace'));
    await tester.tap(find.byTooltip('2 comments'));
    await tester.tap(find.byTooltip('Chats'));
    await tester.tap(find.byTooltip('New post'));

    expect(opened, [
      'post:p2',
      'profile:u_ada',
      'comments:p2',
      'chats',
      'compose',
    ]);
  });

  testWidgets('a message shows as a SnackBar', (tester) async {
    whenListen(
      cubit,
      Stream.value(
        FeedState.loaded(
          posts: [p1],
          message: const UiMessage(id: 1, text: FeedCubit.refreshFailedMessage),
        ),
      ),
      initialState: loaded([p1]),
    );
    await pumpView(tester, loaded([p1]));
    await tester.pump();

    expect(find.text(FeedCubit.refreshFailedMessage), findsOneWidget);
  });

  testWidgets('pulling down refreshes', (tester) async {
    await pumpView(tester, loaded([p1], hasMore: false));

    await tester.fling(find.text('Post p1'), const Offset(0, 400), 1000);
    await tester.pumpAndSettle();

    verify(() => cubit.refresh()).called(1);
  });

  group('the end of the list', () {
    testWidgets('a short list asks for the next page straight away', (
      tester,
    ) async {
      await pumpView(tester, loaded([p1]));
      await tester.pump();

      verify(() => cubit.loadMore()).called(1);
    });

    testWidgets('a failed page shows Retry, and only Retry loads it again', (
      tester,
    ) async {
      await pumpView(tester, loaded([p1], loadMore: LoadMoreStatus.failed));
      await tester.pump();
      verifyNever(() => cubit.loadMore());

      expect(find.text("Couldn't load more"), findsOneWidget);
      await tester.tap(find.text('Retry'));

      verify(() => cubit.loadMore()).called(1);
    });

    testWidgets('after the last page the user is all caught up', (
      tester,
    ) async {
      await pumpView(tester, loaded([p1], hasMore: false));
      await tester.pump();

      expect(find.text("You're all caught up"), findsOneWidget);
      verifyNever(() => cubit.loadMore());
    });
  });
}
