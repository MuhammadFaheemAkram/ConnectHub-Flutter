import 'package:connect_hub/core/design_system/design_system.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../../../helpers/pump_app.dart';

void main() {
  EditableText editable(WidgetTester tester) =>
      tester.widget<EditableText>(find.byType(EditableText));

  testWidgets('shows its label and error, and reports changes', (tester) async {
    final changes = <String>[];
    await tester.pumpThemed(
      AppTextField(
        label: 'Email',
        errorText: 'Email is required.',
        onChanged: changes.add,
      ),
    );

    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Email is required.'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'ada@example.com');
    expect(changes, ['ada@example.com']);
  });

  testWidgets('a password field is obscured until the toggle is tapped', (
    tester,
  ) async {
    await tester.pumpThemed(
      const AppTextField(label: 'Password', obscureText: true),
    );
    expect(editable(tester).obscureText, isTrue);

    await tester.tap(find.byTooltip('Show password'));
    await tester.pump();
    expect(editable(tester).obscureText, isFalse);

    await tester.tap(find.byTooltip('Hide password'));
    await tester.pump();
    expect(editable(tester).obscureText, isTrue);
  });

  testWidgets('a plain field has no visibility toggle', (tester) async {
    await tester.pumpThemed(const AppTextField(label: 'Name'));

    expect(find.byTooltip('Show password'), findsNothing);
    expect(editable(tester).obscureText, isFalse);
  });
}
