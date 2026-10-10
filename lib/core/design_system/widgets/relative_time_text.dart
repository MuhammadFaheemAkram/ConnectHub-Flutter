import 'package:clock/clock.dart';
import 'package:connect_hub/core/common/relative_time.dart';
import 'package:material_ui/material_ui.dart';

/// A timestamp shown as "5m" and read out as "5 minutes ago".
///
/// The current time comes from `package:clock`'s `clock`, which a test can
/// fix for everything it runs (`withClock(Clock.fixed(…), …)`). Services get
/// their `Clock` injected instead; a widget can't take constructor
/// dependencies from the container.
class RelativeTimeText extends StatelessWidget {
  const RelativeTimeText(this.time, {super.key, this.style});

  final DateTime time;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final now = clock.now();
    return Semantics(
      label: RelativeTime.spoken(time, now: now),
      excludeSemantics: true,
      child: Text(RelativeTime.short(time, now: now), style: style),
    );
  }
}
