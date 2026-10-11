import 'dart:async';
import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

/// Three dots that rise and fall in turn while the other person types.
///
/// One [AnimationController] drives all three; each dot is the same wave,
/// shifted by a third of the cycle. With animations turned off in the
/// accessibility settings, the dots stay still. Screen readers hear
/// [semanticsLabel].
class TypingIndicator extends StatefulWidget {
  const TypingIndicator({super.key, this.semanticsLabel = 'Typing'});

  final String semanticsLabel;

  @override
  State<TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<TypingIndicator>
    with SingleTickerProviderStateMixin {
  late final _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.stop();
    } else if (!_controller.isAnimating) {
      unawaited(_controller.repeat());
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      label: widget.semanticsLabel,
      liveRegion: true,
      excludeSemantics: true,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: scheme.surfaceContainerHighest,
          borderRadius: const BorderRadius.all(Radius.circular(18)),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, _) => Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (var dot = 0; dot < 3; dot++)
                  Padding(
                    padding: EdgeInsets.only(left: dot == 0 ? 0 : 4),
                    child: Transform.translate(
                      offset: Offset(0, -3 * _lift(dot)),
                      child: Container(
                        width: 7,
                        height: 7,
                        decoration: BoxDecoration(
                          color: scheme.onSurfaceVariant.withValues(
                            alpha: 0.5 + 0.5 * _lift(dot),
                          ),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// How high [dot] is right now, from 0 (resting) to 1 (top).
  double _lift(int dot) {
    final phase = (_controller.value - dot / 3) % 1;
    return math.max(0, math.sin(phase * 2 * math.pi));
  }
}
