import 'package:connect_hub/core/design_system/theme/app_colors.dart';
import 'package:connect_hub/core/design_system/theme/app_radius.dart';
import 'package:material_ui/material_ui.dart';

/// Builds the app's Material 3 light and dark themes from one seed color.
///
/// Screens style themselves through `Theme.of(context)`, never with hard-coded
/// colors, so a re-brand is a one-line change here. The seed is the Android
/// edition's teal; the UI is deliberately plain Material 3.
abstract final class AppTheme {
  static const Color seedColor = Color(0xFF0F766E);

  static ThemeData light() => _build(Brightness.light);

  static ThemeData dark() => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: brightness,
      // `fidelity` keeps the primary color close to the seed; the default
      // variant (`tonalSpot`) would noticeably mute it.
      dynamicSchemeVariant: DynamicSchemeVariant.fidelity,
    );

    return ThemeData(
      colorScheme: colorScheme,
      extensions: [
        if (brightness == Brightness.light) AppColors.light else AppColors.dark,
      ],
      cardTheme: const CardThemeData(
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(AppRadius.medium)),
        ),
      ),
      chipTheme: const ChipThemeData(shape: StadiumBorder()),
      inputDecorationTheme: const InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(AppRadius.small)),
        ),
      ),
      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
