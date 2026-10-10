import 'package:material_ui/material_ui.dart';

/// App-specific semantic colors that Material's [ColorScheme] has no slot for.
///
/// A [ThemeExtension] travels inside [ThemeData], so the light and dark
/// variants switch automatically (and animate via [lerp]) when the theme
/// changes. Widgets ask for an *intent* (`like`, `unread`) instead of
/// hard-coding raw colors.
@immutable
final class AppColors extends ThemeExtension<AppColors> {
  const AppColors({required this.like, required this.unread});

  /// The filled heart of a liked post. Icons only: it is not a text fill.
  final Color like;

  /// A subtle tint behind unread rows (notifications, chats). Text on it keeps
  /// the theme's normal `onSurface` color, so the tint must stay light enough
  /// for WCAG AA (checked by a test).
  final Color unread;

  static const light = AppColors(
    like: Color(0xFFE0344B),
    unread: Color(0x140F766E),
  );

  static const dark = AppColors(
    like: Color(0xFFFF6B7A),
    unread: Color(0x2E5EEAD4),
  );

  @override
  AppColors copyWith({Color? like, Color? unread}) {
    return AppColors(like: like ?? this.like, unread: unread ?? this.unread);
  }

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) return this;
    return AppColors(
      like: Color.lerp(like, other.like, t)!,
      unread: Color.lerp(unread, other.unread, t)!,
    );
  }
}

/// Shorthand for `Theme.of(context).extension<AppColors>()!`.
extension AppColorsContext on BuildContext {
  AppColors get appColors => Theme.of(this).extension<AppColors>()!;
}
