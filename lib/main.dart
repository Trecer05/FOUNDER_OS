import 'package:flutter/material.dart';

import 'app/app.dart';
import 'application/controllers/game_controller.dart';
import 'application/settings/display_preferences.dart';
import 'persistence/storage/game_snapshot_store.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DisplayPreferences.instance.initialize();

  final controller = GameController(snapshotStore: GameSnapshotStore());
  await controller.initialize();

  runApp(FounderOsApp(controller: controller, startAtMainMenu: true));
}
