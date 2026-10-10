import 'package:material_ui/material_ui.dart';

/// A small spinner that replaces a button's label while its action runs, so
/// the button keeps its size and the user sees that something is happening.
class ButtonProgress extends StatelessWidget {
  const ButtonProgress({super.key, required this.semanticsLabel});

  /// Read by screen readers, e.g. "Signing in".
  final String semanticsLabel;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: 20,
      child: CircularProgressIndicator(
        strokeWidth: 2,
        semanticsLabel: semanticsLabel,
      ),
    );
  }
}
