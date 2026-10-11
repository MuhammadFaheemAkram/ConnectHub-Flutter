import 'package:connect_hub/core/navigation/app_routes.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

/// The leading app-bar button for screens that live above the tab shell.
///
/// Opened from a tab, these screens have something underneath, so this is
/// the normal Back (or Close) button. Opened *directly* (a deep link, or the
/// return address after sign-in), the Navigator has nothing underneath to pop
/// to. The button then takes the user to the Feed instead of leaving them
/// stuck on a screen with no way out.
class BackToFeedButton extends StatelessWidget {
  /// A back arrow, for pushed screens.
  const BackToFeedButton({super.key}) : _close = false;

  /// A close icon, for full-screen dialogs.
  const BackToFeedButton.close({super.key}) : _close = true;

  final bool _close;

  @override
  Widget build(BuildContext context) {
    // Without a router above it (a view's widget test), it is a plain button.
    final router = GoRouter.maybeOf(context);
    if (router == null || router.canPop()) {
      return _close ? const CloseButton() : const BackButton();
    }
    return IconButton(
      tooltip: 'Go to the feed',
      icon: _close ? const CloseButtonIcon() : const BackButtonIcon(),
      onPressed: () => const FeedRoute().go(context),
    );
  }
}
