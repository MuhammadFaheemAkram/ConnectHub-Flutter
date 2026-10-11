import 'package:bloc_test/bloc_test.dart';
import 'package:connect_hub/core/design_system/design_system.dart';
import 'package:connect_hub/domain/model/user.dart';
import 'package:connect_hub/features/profile/cubit/profile_cubit.dart';
import 'package:connect_hub/features/profile/cubit/profile_state.dart';
import 'package:connect_hub/features/profile/profile_view.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/fixtures.dart';
import '../../helpers/pump_app.dart';

class _MockProfileCubit extends MockCubit<ProfileState>
    implements ProfileCubit {}

void main() {
  late _MockProfileCubit cubit;
  late List<String> calls;

  const adaProfile = User(
    id: 'u_ada',
    name: 'Ada Lovelace',
    bio: 'Enchantress of numbers.',
    followersCount: 4820,
    followingCount: 312,
  );
  final p1 = samplePost('p1');

  setUpAll(() => registerFallbackValue(samplePost('fallback')));

  setUp(() {
    cubit = _MockProfileCubit();
    calls = [];
    when(() => cubit.load()).thenAnswer((_) async {});
    when(() => cubit.refresh()).thenAnswer((_) async {});
    when(() => cubit.toggleLike(any())).thenAnswer((_) async {});
    when(() => cubit.toggleBookmark(any())).thenAnswer((_) async {});
  });

  Future<void> pumpView(
    WidgetTester tester,
    ProfileState state, {
    bool isMine = false,
  }) async {
    when(() => cubit.state).thenReturn(state);
    tester.usePhoneSurface();
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: BlocProvider<ProfileCubit>.value(
          value: cubit,
          child: ProfileView(
            isMine: isMine,
            onOpenPost: (id) => calls.add('post:$id'),
            onOpenComments: (id) => calls.add('comments:$id'),
            onEditProfile: () => calls.add('edit'),
            onOpenSettings: () => calls.add('settings'),
            onLogout: () => calls.add('logout'),
          ),
        ),
      ),
    );
  }

  testWidgets('the header: picture, name, bio and compact counts', (
    tester,
  ) async {
    await pumpView(tester, ProfileState.loaded(user: adaProfile, posts: [p1]));

    expect(find.byType(UserAvatar), findsWidgets);
    expect(find.text('Ada Lovelace'), findsWidgets);
    expect(find.text('Enchantress of numbers.'), findsOneWidget);
    expect(find.bySemanticsLabel('4.8K Followers'), findsOneWidget);
    expect(find.bySemanticsLabel('312 Following'), findsOneWidget);
    expect(find.bySemanticsLabel('1 Posts'), findsOneWidget);
  });

  testWidgets("someone else's profile is read-only, with a Back button", (
    tester,
  ) async {
    await pumpView(tester, const ProfileState.loaded(user: adaProfile));

    expect(find.byType(BackButton), findsOneWidget);
    expect(find.text('Edit profile'), findsNothing);
    expect(find.text('Log out'), findsNothing);
    expect(find.byTooltip('Settings'), findsNothing);
    expect(find.text('No posts yet.'), findsOneWidget);
  });

  testWidgets('my profile has Settings, Edit profile and Log out', (
    tester,
  ) async {
    await pumpView(
      tester,
      const ProfileState.loaded(user: demoUser),
      isMine: true,
    );

    expect(find.byType(BackButton), findsNothing);
    expect(find.text("You haven't posted yet."), findsOneWidget);
    await tester.tap(find.byTooltip('Settings'));
    await tester.tap(find.text('Edit profile'));

    expect(calls, ['settings', 'edit']);
  });

  testWidgets('logging out asks first', (tester) async {
    await pumpView(
      tester,
      const ProfileState.loaded(user: demoUser),
      isMine: true,
    );

    await tester.tap(find.text('Log out'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(calls, isEmpty);

    await tester.tap(find.text('Log out'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Log out'));
    await tester.pumpAndSettle();
    expect(calls, ['logout']);
  });

  testWidgets('the posts work as everywhere', (tester) async {
    await pumpView(tester, ProfileState.loaded(user: adaProfile, posts: [p1]));

    await tester.tap(find.text('Post p1'));
    await tester.tap(find.byTooltip('Like'));
    await tester.tap(find.byTooltip('0 comments'));
    await tester.tap(find.byTooltip('Bookmark'));

    expect(calls, ['post:p1', 'comments:p1']);
    verify(() => cubit.toggleLike(p1)).called(1);
    verify(() => cubit.toggleBookmark(p1)).called(1);
  });

  testWidgets('posts still loading show a spinner, not "No posts"', (
    tester,
  ) async {
    await pumpView(
      tester,
      const ProfileState.loaded(user: adaProfile, isLoadingPosts: true),
    );

    expect(find.bySemanticsLabel('Loading posts'), findsOneWidget);
    expect(find.text('No posts yet.'), findsNothing);
  });

  testWidgets('an unknown user says so', (tester) async {
    await pumpView(tester, const ProfileState.notFound());

    expect(find.text("This profile isn't available."), findsOneWidget);
  });

  testWidgets('a failure offers Try again', (tester) async {
    await pumpView(tester, const ProfileState.error('No connection.'));

    await tester.tap(find.text('Try again'));

    verify(() => cubit.load()).called(1);
  });

  group('large text', () {
    double top(WidgetTester tester, String label) =>
        tester.getTopLeft(find.text(label)).dy;

    testWidgets('Edit profile and Log out sit side by side', (tester) async {
      await pumpView(
        tester,
        ProfileState.loaded(user: adaProfile, posts: [p1]),
        isMine: true,
      );

      expect(
        tester.getCenter(find.text('Log out')).dx,
        greaterThan(tester.getCenter(find.text('Edit profile')).dx),
      );
      expect(
        top(tester, 'Log out'),
        lessThan(top(tester, 'Edit profile') + 20),
      );
    });

    testWidgets('at 200 %, they stack, full width, and no word breaks', (
      tester,
    ) async {
      tester.platformDispatcher.textScaleFactorTestValue = 2;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      await pumpView(
        tester,
        ProfileState.loaded(user: adaProfile, posts: [p1]),
        isMine: true,
      );

      expect(
        top(tester, 'Log out'),
        greaterThan(tester.getBottomLeft(find.text('Edit profile')).dy),
      );
      // "Followers" keeps to one line: as tall as the one-word "Posts".
      expect(
        tester.getSize(find.text('Followers')).height,
        tester.getSize(find.text('Posts')).height,
      );
    });
  });
}
