import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:connect_hub/core/common/form_status.dart';
import 'package:connect_hub/core/design_system/design_system.dart';
import 'package:connect_hub/domain/model/user.dart';
import 'package:connect_hub/features/edit_profile/cubit/edit_profile_cubit.dart';
import 'package:connect_hub/features/edit_profile/cubit/edit_profile_state.dart';
import 'package:connect_hub/features/edit_profile/edit_profile_view.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/pump_app.dart';

class _MockEditProfileCubit extends MockCubit<EditProfileState>
    implements EditProfileCubit {}

void main() {
  late _MockEditProfileCubit cubit;
  late int closes;

  const me = User(id: 'u_demo', name: 'Demo User', bio: 'Hello');
  const filled = EditProfileState(
    original: me,
    name: 'Demo User',
    bio: 'Hello',
  );

  setUp(() {
    cubit = _MockEditProfileCubit();
    closes = 0;
    when(() => cubit.load()).thenAnswer((_) async {});
    when(() => cubit.save()).thenAnswer((_) async {});
  });

  /// Opens the form above a home screen, as the app does, so closing it has
  /// somewhere to go.
  Future<void> pumpView(WidgetTester tester, EditProfileState state) async {
    when(() => cubit.state).thenReturn(state);
    tester.usePhoneSurface();
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  fullscreenDialog: true,
                  builder: (_) => BlocProvider<EditProfileCubit>.value(
                    value: cubit,
                    child: EditProfileView(onClose: () => closes++),
                  ),
                ),
              ),
              child: const Text('Open'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open'));
    // Not pumpAndSettle: a loading form shows a spinner (conventions §11.7).
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
  }

  Finder field(String label) => find.widgetWithText(TextField, label);

  FilledButton saveButton(WidgetTester tester) => tester.widget<FilledButton>(
    find.ancestor(of: find.text('Save'), matching: find.byType(FilledButton)),
  );

  testWidgets('loading the profile shows a spinner', (tester) async {
    await pumpView(tester, const EditProfileState());

    expect(find.text('Loading your profile…'), findsOneWidget);
  });

  testWidgets("a profile that couldn't load offers Try again", (tester) async {
    await pumpView(tester, const EditProfileState(loadError: 'No connection.'));

    await tester.tap(find.text('Try again'));

    verify(() => cubit.load()).called(1);
  });

  testWidgets('starts from my profile, with the bio counter', (tester) async {
    await pumpView(tester, filled);

    expect(field('Name'), findsOneWidget);
    expect(find.widgetWithText(TextField, 'Demo User'), findsOneWidget);
    expect(find.widgetWithText(TextField, 'Hello'), findsOneWidget);
    expect(find.text('5/160'), findsOneWidget);
    // Nothing changed yet: nothing to save.
    expect(saveButton(tester).onPressed, isNull);
  });

  testWidgets('shows what is wrong, and Save stays off', (tester) async {
    await pumpView(tester, filled.copyWith(name: '', bio: 'a' * 161));

    expect(find.text('Name is required.'), findsOneWidget);
    expect(find.text('Bio must be 160 characters or fewer.'), findsOneWidget);
    expect(find.text('161/160'), findsOneWidget);
    expect(saveButton(tester).onPressed, isNull);
  });

  testWidgets('Save sends a valid change', (tester) async {
    await pumpView(tester, filled.copyWith(name: 'Demo Person'));

    await tester.tap(find.text('Save'));

    verify(() => cubit.save()).called(1);
  });

  testWidgets('a saved profile closes the page', (tester) async {
    final states = StreamController<EditProfileState>();
    addTearDown(states.close);
    final edited = filled.copyWith(name: 'Demo Person');
    whenListen(cubit, states.stream, initialState: edited);
    await pumpView(tester, edited);

    states.add(edited.copyWith(status: FormStatus.success));
    await tester.pump();

    expect(closes, 1);
  });

  testWidgets('with changes, Close asks first: Cancel stays, Discard '
      'leaves', (tester) async {
    await pumpView(tester, filled.copyWith(bio: 'Changed'));

    await tester.tap(find.byType(CloseButton));
    await tester.pumpAndSettle();
    expect(find.text('Discard changes?'), findsOneWidget);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(find.text('Edit profile'), findsOneWidget);
    expect(closes, 0);

    await tester.tap(find.byType(CloseButton));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Discard'));
    await tester.pumpAndSettle();
    expect(closes, 1);
  });

  testWidgets('without changes, Close just closes', (tester) async {
    await pumpView(tester, filled);

    await tester.tap(find.byType(CloseButton));
    await tester.pumpAndSettle();

    expect(find.text('Discard changes?'), findsNothing);
    expect(find.text('Open'), findsOneWidget);
  });
}
