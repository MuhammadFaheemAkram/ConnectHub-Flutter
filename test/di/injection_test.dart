import 'package:connect_hub/core/navigation/placeholder_session.dart';
import 'package:connect_hub/di/injection.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  tearDown(getIt.reset);

  // A smoke test of the real composition root: a constructor parameter that
  // injectable can't resolve (e.g. a missing `@ignoreParam`) only fails when
  // the type is first resolved, at runtime. This catches it in CI.
  test('the real container resolves the session', () async {
    await configureDependencies();

    final session = getIt<PlaceholderSession>();

    expect(session.isSignedIn, isFalse);
    expect(getIt<PlaceholderSession>(), same(session));
  });
}
