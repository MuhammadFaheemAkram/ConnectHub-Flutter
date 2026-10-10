import 'package:cached_network_image/cached_network_image.dart';
import 'package:material_ui/material_ui.dart';

/// A round profile picture.
///
/// It falls back to the person's initials on the brand tint while the image
/// loads, when it fails (e.g. offline) and when there is no picture, so a
/// face-shaped gap never appears. Screen readers hear the person's name.
class UserAvatar extends StatelessWidget {
  const UserAvatar({super.key, required this.name, this.url, this.size = 40});

  final String name;
  final String? url;

  /// Diameter in logical pixels.
  final double size;

  /// "Ada Lovelace" → "AL", "Linus T." → "LT", "Grace" → "G".
  static String initialsOf(String name) {
    final initials = [
      for (final word in name.trim().split(RegExp(r'\s+')).take(2))
        if (word.isNotEmpty) word.characters.first.toUpperCase(),
    ];
    return initials.isEmpty ? '?' : initials.join();
  }

  @override
  Widget build(BuildContext context) {
    final url = this.url;
    final initials = _Initials(name: name, size: size);
    return Semantics(
      label: name,
      image: true,
      excludeSemantics: true,
      child: ClipOval(
        child: SizedBox.square(
          dimension: size,
          child: url == null
              ? initials
              : CachedNetworkImage(
                  imageUrl: url,
                  fit: BoxFit.cover,
                  fadeInDuration: const Duration(milliseconds: 150),
                  placeholder: (_, _) => initials,
                  errorWidget: (_, _, _) => initials,
                ),
        ),
      ),
    );
  }
}

/// The fallback: initials in `onPrimaryContainer` on `primaryContainer`, a
/// pair Material 3 keeps legible in both themes (checked by a test).
class _Initials extends StatelessWidget {
  const _Initials({required this.name, required this.size});

  final String name;
  final double size;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ColoredBox(
      color: scheme.primaryContainer,
      child: Padding(
        padding: EdgeInsets.all(size * 0.2),
        // Scales down rather than overflowing at large text sizes.
        child: FittedBox(
          child: Text(
            UserAvatar.initialsOf(name),
            style: TextStyle(
              color: scheme.onPrimaryContainer,
              fontSize: size * 0.4,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
