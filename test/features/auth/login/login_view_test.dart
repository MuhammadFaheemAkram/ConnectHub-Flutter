import 'package:bloc_test/bloc_test.dart';
import 'package:connect_hub/core/common/form_status.dart';
import 'package:connect_hub/core/design_system/design_system.dart';
import 'package:connect_hub/features/auth/login/bloc/login_bloc.dart';
import 'package:connect_hub/features/auth/login/bloc/login_event.dart';
import 'package:connect_hub/features/auth/login/bloc/login_state.dart';
import 'package:connect_hub/features/auth/login/login_view.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';

class _MockLoginBloc extends MockBloc<LoginEvent, LoginState>
    implements LoginBloc {}

void main() {
  late _MockLoginBloc bloc;
  var createAccountTaps = 0;

  setUpAll(() => registerFallbackValue(const LoginSubmitted()));

  setUp(() {
    bloc = _MockLoginBloc();
    createAccountTaps = 0;
    when(() => bloc.state).thenReturn(const LoginState());
  });

  Future<void> pumpView(WidgetTester tester, {String? notice}) {
    return tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: BlocProvider<LoginBloc>.value(
          value: bloc,
          child: LoginView(
            notice: notice,
            onCreateAccount: () => createAccountTaps++,
          ),
        ),
      ),
    );
  }

  Finder field(String label) => find.widgetWithText(TextField, label);

  testWidgets('typing sends one event per field', (tester) async {
    await pumpView(tester);

    await tester.enterText(field('Email'), 'ada@example.com');
    await tester.enterText(field('Password'), 'engines');

    // Events have no `==`, so match by type and field.
    verify(
      () => bloc.add(
        any(
          that: isA<LoginEmailChanged>().having(
            (event) => event.email,
            'email',
            'ada@example.com',
          ),
        ),
      ),
    ).called(1);
    verify(() => bloc.add(any(that: isA<LoginPasswordChanged>()))).called(1);
  });

  testWidgets('"Sign in" and the keyboard\'s done action both submit', (
    tester,
  ) async {
    await pumpView(tester);

    await tester.tap(find.text('Sign in'));
    await tester.enterText(field('Password'), 'x');
    await tester.testTextInput.receiveAction(TextInputAction.done);

    verify(() => bloc.add(any(that: isA<LoginSubmitted>()))).called(2);
  });

  testWidgets('shows field errors and the server message from the state', (
    tester,
  ) async {
    when(() => bloc.state).thenReturn(
      const LoginState(
        showErrors: true,
        status: FormStatus.failure,
        errorMessage: 'Incorrect email or password.',
      ),
    );
    await pumpView(tester);

    expect(find.text('Email is required.'), findsOneWidget);
    expect(find.text('Password is required.'), findsOneWidget);
    expect(find.text('Incorrect email or password.'), findsOneWidget);
  });

  testWidgets('while signing in, the button shows a spinner and nothing is '
      'tappable', (tester) async {
    when(() => bloc.state).thenReturn(
      const LoginState(
        email: 'ada@example.com',
        password: 'engines',
        status: FormStatus.submitting,
      ),
    );
    await pumpView(tester);

    expect(find.bySemanticsLabel('Signing in'), findsOneWidget);
    await tester.tap(find.text('Use demo account'));
    await tester.tap(find.text('Create an account'));
    verifyNever(() => bloc.add(any()));
    expect(createAccountTaps, 0);
  });

  testWidgets('values the Bloc sets (the demo account) appear in the fields', (
    tester,
  ) async {
    whenListen(
      bloc,
      Stream.value(
        const LoginState(email: 'demo@connecthub.app', password: 'connecthub'),
      ),
      initialState: const LoginState(),
    );
    await pumpView(tester);

    await tester.tap(find.text('Use demo account'));
    await tester.pump();

    verify(() => bloc.add(any(that: isA<LoginDemoAccountRequested>())))
        .called(1);
    expect(find.text('demo@connecthub.app'), findsOneWidget);
  });

  testWidgets('shows a notice, e.g. an expired session', (tester) async {
    await pumpView(
      tester,
      notice: 'Your session has expired. Please sign in again.',
    );

    expect(
      find.text('Your session has expired. Please sign in again.'),
      findsOneWidget,
    );
  });

  testWidgets('"Create an account" calls back', (tester) async {
    await pumpView(tester);

    await tester.tap(find.text('Create an account'));

    expect(createAccountTaps, 1);
  });
}
