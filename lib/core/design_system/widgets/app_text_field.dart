import 'package:material_ui/material_ui.dart';

/// A labelled text field with an inline error and, for passwords, a
/// show/hide toggle.
///
/// It holds no validation logic: the forms are driven by Blocs/Cubits, which
/// decide the [errorText]. The widget only renders it and reports changes, so
/// every form in the app looks and behaves the same.
class AppTextField extends StatefulWidget {
  const AppTextField({
    super.key,
    required this.label,
    this.controller,
    this.hintText,
    this.errorText,
    this.helperText,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.autofillHints,
    this.onChanged,
    this.onSubmitted,
    this.enabled = true,
    this.maxLines = 1,
    this.maxLength,
  });

  final String label;
  final TextEditingController? controller;
  final String? hintText;

  /// Shown under the field in the error color; `null` means valid.
  final String? errorText;
  final String? helperText;

  /// Hides the text and adds a show/hide toggle (for passwords).
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final Iterable<String>? autofillHints;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final bool enabled;
  final int maxLines;
  final int? maxLength;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late bool _obscured = widget.obscureText;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      obscureText: _obscured,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      autofillHints: widget.autofillHints,
      onChanged: widget.onChanged,
      onSubmitted: widget.onSubmitted,
      enabled: widget.enabled,
      // An obscured field must be single-line.
      maxLines: widget.obscureText ? 1 : widget.maxLines,
      maxLength: widget.maxLength,
      decoration: InputDecoration(
        labelText: widget.label,
        hintText: widget.hintText,
        errorText: widget.errorText,
        helperText: widget.helperText,
        suffixIcon: widget.obscureText
            ? IconButton(
                tooltip: _obscured ? 'Show password' : 'Hide password',
                icon: Icon(
                  _obscured
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                ),
                onPressed: () => setState(() => _obscured = !_obscured),
              )
            : null,
      ),
    );
  }
}
