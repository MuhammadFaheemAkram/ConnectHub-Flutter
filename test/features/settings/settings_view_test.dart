import 'package:bloc_test/bloc_test.dart';
import 'package:connect_hub/core/common/ui_message.dart';
import 'package:connect_hub/core/design_system/design_system.dart';
import 'package:connect_hub/domain/model/app_language.dart';
import 'package:connect_hub/domain/model/app_settings.dart';
import 'package:connect_hub/domain/model/app_theme_mode.dart';
import 'package:connect_hub/features/settings/cubit/settings_cubit.dart';
import 'package:connect_hub/features/settings/cubit/settings_tools_cubit.dart';
import 'package:connect_hub/features/settings/cubit/settings_tools_state.dart';
import 'package:connect_hub/features/settings/settings_view.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/pump_app.dart';

class _MockSettingsCubit extends MockCubit<AppSettings>
    implements SettingsCubit {}

class _MockSettingsToolsCubit extends MockCubit<SettingsToolsState>
    implements SettingsToolsCubit {}

void main() {
  late _MockSettingsCubit settings;
  late _MockSettingsToolsCubit tools;
  late int logouts;

  setUpAll(() {
    registerFallbackValue(AppThemeMode.system);
    registerFallbackValue(AppLanguage.en);
  });

  setUp(() {
    settings = _MockSettingsCubit();
    tools = _MockSettingsToolsCubit();
    logouts = 0;
    when(() => settings.state).thenReturn(const AppSettings());
    when(() => settings.selectThemeMode(any())).thenAnswer((_) async {});
    when(() => settings.setNotificationsEnabled(enabled: any(named: 'enabled')))
        .thenAnswer((_) async {});
    when(() => settings.selectLanguage(any())).thenAnswer((_) async {});
    when(() => tools.state).thenReturn(const SettingsToolsState());
    when(() => tools.clearCache()).thenAnswer((_) async {});
    when(() => tools.expireSession()).thenAnswer((_) async {});
  });

  Future<void> pumpView(WidgetTester tester) async {
    tester.usePhoneSurface();
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: MultiBlocProvider(
          providers: [
            BlocProvider<SettingsCubit>.value(value: settings),
            BlocProvider<SettingsToolsCubit>.value(value: tools),
          ],
          child: SettingsView(
            appVersion: '1.0.0 (1)',
            onLogout: () => logouts++,
          ),
        ),
      ),
    );
  }

  /// Scrolls the settings list (the language field has a scrollable too).
  Future<void> scrollTo(WidgetTester tester, String text) async {
    await tester.scrollUntilVisible(
      find.text(text),
      200,
      scrollable: find
          .descendant(
            of: find.byType(ListView),
            matching: find.byType(Scrollable),
          )
          .first,
    );
    await tester.pumpAndSettle();
  }

  testWidgets('the appearance control shows the saved choice; selecting Dark '
      'calls the Cubit', (tester) async {
    await pumpView(tester);

    final picker = tester.widget<SegmentedButton<AppThemeMode>>(
      find.byType(SegmentedButton<AppThemeMode>),
    );
    expect(picker.selected, {AppThemeMode.system});

    await tester.tap(find.text('Dark'));
    verify(() => settings.selectThemeMode(AppThemeMode.dark)).called(1);
  });

  testWidgets('"Show unread badges" turns the badges off', (tester) async {
    await pumpView(tester);

    await tester.tap(find.text('Show unread badges'));
    verify(() => settings.setNotificationsEnabled(enabled: false)).called(1);
  });

  testWidgets('the language menu lists the four languages and saves the '
      'choice', (tester) async {
    await pumpView(tester);

    await tester.tap(find.byType(DropdownMenu<AppLanguage>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Français').last);
    await tester.pumpAndSettle();

    verify(() => settings.selectLanguage(AppLanguage.fr)).called(1);
  });

  testWidgets('Clear cache asks first: Cancel keeps it, Clear clears it', (
    tester,
  ) async {
    await pumpView(tester);
    await scrollTo(tester, 'Clear cache');

    await tester.tap(find.text('Clear cache'));
    await tester.pumpAndSettle();
    expect(find.text('Clear cache?'), findsOneWidget);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    verifyNever(() => tools.clearCache());

    await tester.tap(find.text('Clear cache'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Clear'));
    await tester.pumpAndSettle();
    verify(() => tools.clearCache()).called(1);
  });

  testWidgets('the developer switches reach their Cubit', (tester) async {
    await pumpView(tester);
    await scrollTo(tester, 'Expire session');

    await tester.tap(find.text('Simulate network failure'));
    verify(() => tools.setNetworkFailure(fail: true)).called(1);

    await tester.tap(find.text('Expire session'));
    verify(() => tools.expireSession()).called(1);
  });

  testWidgets('Log out asks first', (tester) async {
    await pumpView(tester);
    await scrollTo(tester, 'Log out');

    await tester.tap(find.text('Log out'));
    await tester.pumpAndSettle();
    expect(find.text('Log out?'), findsOneWidget);
    await tester.tap(find.widgetWithText(FilledButton, 'Log out'));
    await tester.pumpAndSettle();

    expect(logouts, 1);
  });

  testWidgets('About shows the version and build', (tester) async {
    await pumpView(tester);
    await scrollTo(tester, 'Licenses');

    expect(find.text('Version 1.0.0 (1)'), findsOneWidget);
  });

  testWidgets('"Cache cleared." shows in a SnackBar', (tester) async {
    whenListen(
      tools,
      Stream.value(
        const SettingsToolsState(
          message: UiMessage(
            id: 1,
            text: SettingsToolsCubit.cacheClearedMessage,
          ),
        ),
      ),
      initialState: const SettingsToolsState(),
    );
    await pumpView(tester);
    await tester.pump();

    expect(find.text('Cache cleared.'), findsOneWidget);
  });

  testWidgets('at 200 % text, the appearance choices are a list, and '
      'choosing Dark calls the Cubit', (tester) async {
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await pumpView(tester);

    expect(find.byType(SegmentedButton<AppThemeMode>), findsNothing);
    expect(find.byType(RadioListTile<AppThemeMode>), findsNWidgets(3));

    await tester.tap(find.widgetWithText(RadioListTile<AppThemeMode>, 'Dark'));
    verify(() => settings.selectThemeMode(AppThemeMode.dark)).called(1);
  });
}
