import 'package:connect_hub/core/design_system/theme/app_radius.dart';
import 'package:connect_hub/core/design_system/theme/app_spacing.dart';
import 'package:material_ui/material_ui.dart';

/// An inline notice above a form, e.g. "Your session has expired".
///
/// It uses the `tertiaryContainer` / `onTertiaryContainer` role pair, which
/// Material 3 guarantees to contrast in both themes. It is announced to
/// screen readers as a live region when it appears.
class NoticeBanner extends StatelessWidget {
  const NoticeBanner({super.key, required this.icon, required this.message});

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      liveRegion: true,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: scheme.tertiaryContainer,
          borderRadius: const BorderRadius.all(
            Radius.circular(AppRadius.medium),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.small),
          child: Row(
            children: [
              Icon(icon, color: scheme.onTertiaryContainer),
              const SizedBox(width: AppSpacing.small),
              Expanded(
                child: Text(
                  message,
                  style: TextStyle(color: scheme.onTertiaryContainer),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
