import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:connect_hub/core/common/form_status.dart';
import 'package:connect_hub/core/design_system/design_system.dart';
import 'package:connect_hub/features/create_post/create_post_view.dart';
import 'package:connect_hub/features/create_post/cubit/create_post_cubit.dart';
import 'package:connect_hub/features/create_post/cubit/create_post_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/pump_app.dart';

class _MockCreatePostCubit extends MockCubit<CreatePostState>
    implements CreatePostCubit {}

void main() {
  late _MockCreatePostCubit cubit;
  late int closes;

  setUp(() {
    cubit = _MockCreatePostCubit();
    closes = 0;
    when(() => cubit.submit()).thenAnswer((_) async {});
  });

  /// Opens the form above a home screen, as the app does, so closing it has
  /// somewhere to go.
  Future<void> pumpView(WidgetTester tester, CreatePostState state) async {
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
                  builder: (_) => BlocProvider<CreatePostCubit>.value(
                    value: cubit,
                    child: CreatePostView(onClose: () => closes++),
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
    // Not pumpAndSettle: a submitting form shows a spinner, which never
    // settles (conventions §11.7). The route transition takes under 1 s.
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
  }

  FilledButton postButton(WidgetTester tester) => tester.widget<FilledButton>(
    find.ancestor(of: find.text('Post'), matching: find.byType(FilledButton)),
  );

  testWidgets('Post is disabled until there is something valid to share', (
    tester,
  ) async {
    await pumpView(tester, const CreatePostState());
    expect(postButton(tester).onPressed, isNull);
  });

  testWidgets('a valid post can be sent', (tester) async {
    await pumpView(tester, const CreatePostState(content: 'Hello'));

    await tester.tap(find.text('Post'));

    verify(() => cubit.submit()).called(1);
  });

  testWidgets('typing reaches the Cubit', (tester) async {
    await pumpView(tester, const CreatePostState());

    await tester.enterText(find.byType(TextField).first, 'Hello');
    await tester.enterText(
      find.widgetWithText(TextField, 'Image URL (optional)'),
      'https://x.dev/a.png',
    );

    verify(() => cubit.contentChanged('Hello')).called(1);
    verify(() => cubit.imageUrlChanged('https://x.dev/a.png')).called(1);
  });

  testWidgets('the counter turns into an error over the limit', (tester) async {
    await pumpView(tester, CreatePostState(content: 'a' * 281));

    expect(find.text('281/280'), findsOneWidget);
    expect(find.text('Posts are limited to 280 characters.'), findsOneWidget);
    expect(postButton(tester).onPressed, isNull);
  });

  testWidgets("a failure shows the server's message", (tester) async {
    await pumpView(
      tester,
      const CreatePostState(
        content: 'Hello',
        status: FormStatus.failure,
        errorMessage: 'No connection.',
      ),
    );

    expect(find.text('No connection.'), findsOneWidget);
  });

  testWidgets('a published post closes the page', (tester) async {
    final states = StreamController<CreatePostState>();
    addTearDown(states.close);
    const submitting = CreatePostState(
      content: 'Hello',
      status: FormStatus.submitting,
    );
    whenListen(cubit, states.stream, initialState: submitting);
    await pumpView(tester, submitting);

    states.add(
      const CreatePostState(content: 'Hello', status: FormStatus.success),
    );
    await tester.pump();

    expect(closes, 1);
  });

  group('leaving', () {
    testWidgets('with nothing written, Close just closes', (tester) async {
      await pumpView(tester, const CreatePostState());

      await tester.tap(find.byType(CloseButton));
      await tester.pumpAndSettle();

      expect(find.text('Discard post?'), findsNothing);
      expect(find.text('Open'), findsOneWidget);
    });

    testWidgets('with a draft, Close asks first: Cancel stays, Discard '
        'leaves', (tester) async {
      await pumpView(tester, const CreatePostState(content: 'Hello'));

      await tester.tap(find.byType(CloseButton));
      await tester.pumpAndSettle();
      expect(find.text('Discard post?'), findsOneWidget);
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(find.text('New post'), findsOneWidget);
      expect(closes, 0);

      await tester.tap(find.byType(CloseButton));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, 'Discard'));
      await tester.pumpAndSettle();
      expect(closes, 1);
    });
  });
}
