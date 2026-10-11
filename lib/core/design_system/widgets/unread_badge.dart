import 'package:material_ui/material_ui.dart';

/// An unread count on an icon (a tab, an app-bar button), hidden at zero.
/// Screen readers hear "3 unread" rather than a bare "3".
///
/// The count grows with the text up to 130 %, then stops: on a 24 px icon, a
/// bigger badge would cover it, or fall off the screen's edge.
class UnreadBadge extends StatelessWidget {
  const UnreadBadge({super.key, required this.count, required this.child});

  final int count;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      value: count > 0 ? '$count unread' : null,
      child: ExcludeSemantics(
        child: MediaQuery.withClampedTextScaling(
          maxScaleFactor: 1.3,
          child: Badge.count(
            count: count,
            isLabelVisible: count > 0,
            child: child,
          ),
        ),
      ),
    );
  }
}
