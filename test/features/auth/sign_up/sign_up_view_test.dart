import 'package:bloc_test/bloc_test.dart';
import 'package:connect_hub/core/common/form_status.dart';
import 'package:connect_hub/core/design_system/design_system.dart';
import 'package:connect_hub/features/auth/sign_up/bloc/sign_up_bloc.dart';
import 'package:connect_hub/features/auth/sign_up/bloc/sign_up_event.dart';
import 'package:connect_hub/features/auth/sign_up/bloc/sign_up_state.dart';
import 'package:connect_hub/features/auth/sign_up/sign_up_view.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/pump_app.dart';

class _MockSignUpBloc extends MockBloc<SignUpEvent, SignUpState>
    implements SignUpBloc {}

void main() {
  late _MockSignUpBloc bloc;
  var signInTaps = 0;

  setUpAll(() => registerFallbackValue(const SignUpSubmitted()));

  setUp(() {
    bloc = _MockSignUpBloc();
    signInTaps = 0;
    when(() => bloc.state).thenReturn(const SignUpState());
  });

  Future<void> pumpView(WidgetTester tester) {
    tester.usePhoneSurface();
    return tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: BlocProvider<SignUpBloc>.value(
          value: bloc,
          child: SignUpView(onSignIn: () => signInTaps++),
        ),
      ),
    );
  }

  testWidgets('each field sends its own event', (tester) async {
    await pumpView(tester);

    await tester.enterText(find.widgetWithText(TextField, 'Name'), 'Ada');
    await tester.enterText(find.widgetWithText(TextField, 'Email'), 'a@b.co');
    await tester.enterText(find.widgetWithText(TextField, 'Password'), 'p');
    await tester.enterText(
      find.widgetWithText(TextField, 'Confirm password'),
      'p',
    );

    verify(() => bloc.add(any(that: isA<SignUpNameChanged>()))).called(1);
    verify(() => bloc.add(any(that: isA<SignUpEmailChanged>()))).called(1);
    verify(() => bloc.add(any(that: isA<SignUpPasswordChanged>()))).called(1);
    verify(() => bloc.add(any(that: isA<SignUpConfirmPasswordChanged>())))
        .called(1);
  });

  testWidgets('"Create account" submits, and the sign-in link calls back', (
    tester,
  ) async {
    await pumpView(tester);

    await tester.tap(find.widgetWithText(FilledButton, 'Create account'));
    await tester.tap(find.text('Already have an account? Sign in'));

    verify(() => bloc.add(any(that: isA<SignUpSubmitted>()))).called(1);
    expect(signInTaps, 1);
  });

  testWidgets('shows every field error and the server message', (tester) async {
    when(() => bloc.state).thenReturn(
      const SignUpState(
        password: 'secret1',
        confirmPassword: 'secret2',
        showErrors: true,
        status: FormStatus.failure,
        errorMessage: 'An account with this email already exists.',
      ),
    );
    await pumpView(tester);

    expect(find.text('Name is required.'), findsOneWidget);
    expect(find.text('Email is required.'), findsOneWidget);
    expect(find.text("Passwords don't match."), findsOneWidget);
    expect(
      find.text('An account with this email already exists.'),
      findsOneWidget,
    );
  });
}
