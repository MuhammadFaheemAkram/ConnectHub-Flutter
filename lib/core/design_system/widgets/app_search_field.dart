import 'package:material_ui/material_ui.dart';

/// A rounded search field: a search icon, the hint, and a Clear button once
/// something is typed.
///
/// Material's `SearchBar` wraps its text field in a tappable surface with no
/// label of its own, so a screen reader stops on an unnamed control before
/// reaching the field. Here the field is the only control, and the hint
/// names it. Autocorrect is off: iOS would otherwise turn "ada" into "Ada"
/// as the keyboard closes.
class AppSearchField extends StatelessWidget {
  const AppSearchField({
    super.key,
    required this.controller,
    required this.hintText,
    this.onChanged,
    this.onSubmitted,
    this.onCleared,
  });

  final TextEditingController controller;
  final String hintText;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;

  /// Called after the Clear button has emptied the field.
  final VoidCallback? onCleared;

  static const _shape = BorderRadius.all(Radius.circular(28));

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ValueListenableBuilder(
      valueListenable: controller,
      builder: (context, value, _) => TextField(
        controller: controller,
        autocorrect: false,
        textInputAction: TextInputAction.search,
        onChanged: onChanged,
        onSubmitted: onSubmitted,
        decoration: InputDecoration(
          hintText: hintText,
          prefixIcon: const Icon(Icons.search),
          suffixIcon: value.text.isEmpty
              ? null
              : IconButton(
                  tooltip: 'Clear search',
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    controller.clear();
                    onCleared?.call();
                  },
                ),
          filled: true,
          fillColor: scheme.surfaceContainerHigh,
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
          border: const OutlineInputBorder(
            borderRadius: _shape,
            borderSide: BorderSide.none,
          ),
          enabledBorder: const OutlineInputBorder(
            borderRadius: _shape,
            borderSide: BorderSide.none,
          ),
          // A visible focus ring, for keyboard and switch users.
          focusedBorder: OutlineInputBorder(
            borderRadius: _shape,
            borderSide: BorderSide(color: scheme.primary, width: 2),
          ),
        ),
      ),
    );
  }
}
