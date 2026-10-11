import 'package:bloc_test/bloc_test.dart';
import 'package:connect_hub/core/common/ui_message.dart';
import 'package:connect_hub/core/design_system/design_system.dart';
import 'package:connect_hub/domain/model/app_notification.dart';
import 'package:connect_hub/features/activity/activity_view.dart';
import 'package:connect_hub/features/activity/cubit/activity_cubit.dart';
import 'package:connect_hub/features/activity/cubit/activity_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/fixtures.dart';
import '../../helpers/pump_app.dart';

class _MockActivityCubit extends MockCubit<ActivityState>
    implements ActivityCubit {}

void main() {
  late _MockActivityCubit cubit;
  late List<String> opened;

  final toPost = sampleNotification('n1', postId: 'p1');
  final toProfile = sampleNotification(
    'n2',
    kind: NotificationKind.follow,
    userId: 'u_ada',
  );
  final toNothing = sampleNotification(
    'n3',
    kind: NotificationKind.comment,
    isRead: true,
  );

  setUpAll(() {
    registerFallbackValue(toPost);
    registerFallbackValue(ActivityFilter.all);
  });

  setUp(() {
    cubit = _MockActivityCubit();
    opened = [];
    when(() => cubit.load()).thenAnswer((_) async {});
    when(() => cubit.refresh()).thenAnswer((_) async {});
    when(() => cubit.markRead(any())).thenAnswer((_) async {});
    when(() => cubit.markAllRead()).thenAnswer((_) async {});
  });

  Future<void> pumpView(WidgetTester tester, ActivityState state) async {
    when(() => cubit.state).thenReturn(state);
    tester.usePhoneSurface();
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: BlocProvider<ActivityCubit>.value(
          value: cubit,
          child: ActivityView(
            onOpenPost: (id) => opened.add('post:$id'),
            onOpenProfile: (id) => opened.add('profile:$id'),
          ),
        ),
      ),
    );
  }

  ActivityState loaded(
    List<AppNotification> list, {
    ActivityFilter filter = ActivityFilter.all,
  }) => ActivityState(
    status: ActivityStatus.loaded,
    notifications: list,
    filter: filter,
  );

  Finder markAllRead() => find.widgetWithText(TextButton, 'Mark all read');

  testWidgets('loading shows the spinner', (tester) async {
    await pumpView(tester, const ActivityState());

    expect(find.text('Loading activity…'), findsOneWidget);
  });

  testWidgets('a failure offers Try again', (tester) async {
    await pumpView(
      tester,
      const ActivityState(
        status: ActivityStatus.failure,
        errorMessage: 'No connection.',
      ),
    );

    await tester.tap(find.text('Try again'));
    verify(() => cubit.load()).called(1);
  });

  // One state per test: a mocked Cubit's state is read once (§11.31).
  testWidgets('no activity at all says so', (tester) async {
    await pumpView(tester, loaded(const []));

    expect(find.text('No activity yet'), findsOneWidget);
  });

  testWidgets('nothing for the chosen filter says so differently', (
    tester,
  ) async {
    await pumpView(tester, loaded([toNothing], filter: ActivityFilter.unread));

    expect(find.text('Nothing here for this filter.'), findsOneWidget);
  });

  testWidgets('a chip picks the filter', (tester) async {
    await pumpView(tester, loaded([toPost, toProfile, toNothing]));

    await tester.tap(find.widgetWithText(FilterChip, 'Unread'));
    verify(() => cubit.selectFilter(ActivityFilter.unread)).called(1);
  });

  testWidgets('tapping a row marks it read and opens what it links to', (
    tester,
  ) async {
    await pumpView(tester, loaded([toPost, toProfile, toNothing]));

    await tester.tap(find.text('Notification n1'));
    await tester.tap(find.text('Notification n2'));
    await tester.tap(find.text('Notification n3'));

    verify(() => cubit.markRead(toPost)).called(1);
    verify(() => cubit.markRead(toProfile)).called(1);
    verify(() => cubit.markRead(toNothing)).called(1);
    expect(opened, ['post:p1', 'profile:u_ada']);
  });

  testWidgets('"Mark all read" is off with nothing unread', (tester) async {
    await pumpView(tester, loaded([toNothing]));

    expect(tester.widget<TextButton>(markAllRead()).onPressed, isNull);
  });

  testWidgets('"Mark all read" marks everything read', (tester) async {
    await pumpView(tester, loaded([toPost, toNothing]));

    await tester.tap(markAllRead());
    verify(() => cubit.markAllRead()).called(1);
  });

  testWidgets('a message shows in a SnackBar', (tester) async {
    whenListen(
      cubit,
      Stream.value(
        loaded([toPost]).copyWith(
          message: const UiMessage(
            id: 1,
            text: ActivityCubit.markReadFailedMessage,
          ),
        ),
      ),
      initialState: loaded([toPost]),
    );
    tester.usePhoneSurface();
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: BlocProvider<ActivityCubit>.value(
          value: cubit,
          child: ActivityView(onOpenPost: (_) {}, onOpenProfile: (_) {}),
        ),
      ),
    );
    await tester.pump();

    expect(find.text(ActivityCubit.markReadFailedMessage), findsOneWidget);
  });
}
