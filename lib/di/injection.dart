import 'package:connect_hub/di/injection.config.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

/// The app's single service locator.
///
/// Only `main.dart`, the app widget, the router and Page widgets resolve
/// dependencies from it. Everything else receives them through its
/// constructor, so tests can pass fakes directly.
final GetIt getIt = GetIt.instance;

/// Composition root: the one place where concrete implementations are chosen
/// and wired together (the role of Hilt modules on Android and of
/// `AppEnvironment` on iOS).
///
/// `injectable` generates `getIt.init()` from the annotations under `lib/`.
/// It is async because the `@preResolve` dependencies (preferences and
/// package info) must be ready before the first frame.
@InjectableInit()
Future<void> configureDependencies() async {
  await getIt.init();
}
