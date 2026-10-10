import 'package:connect_hub/core/design_system/design_system.dart';
import 'package:material_ui/material_ui.dart';

/// Shown while the saved session is being restored (Phase 2 on).
///
/// It has no logic and no artificial delay: the router leaves this screen as
/// soon as the session is known.
class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Center(
        child: Semantics(
          label: 'Loading ConnectHub',
          excludeSemantics: true,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.forum_rounded,
                size: 64,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: AppSpacing.small),
              Text('ConnectHub', style: theme.textTheme.headlineSmall),
              const SizedBox(height: AppSpacing.large),
              const CircularProgressIndicator(),
            ],
          ),
        ),
      ),
    );
  }
}
