import 'package:material_ui/material_ui.dart';

/// "128/280" under a field, in the error color once over the limit.
class CharacterCounter extends StatelessWidget {
  const CharacterCounter({super.key, required this.count, required this.max});

  final int count;
  final int max;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final over = count > max;
    return Semantics(
      label: '$count of $max characters',
      excludeSemantics: true,
      child: Text(
        '$count/$max',
        style: theme.textTheme.bodySmall?.copyWith(
          color: over
              ? theme.colorScheme.error
              : theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
