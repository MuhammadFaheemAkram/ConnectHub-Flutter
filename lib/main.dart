import 'package:connect_hub/app/connect_hub_app.dart';
import 'package:connect_hub/di/injection.dart';
import 'package:material_ui/material_ui.dart';

Future<void> main() async {
  // Bindings must exist before any async setup touches plugins or assets.
  WidgetsFlutterBinding.ensureInitialized();
  await configureDependencies();
  runApp(const ConnectHubApp());
}
