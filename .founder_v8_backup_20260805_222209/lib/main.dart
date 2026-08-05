import 'package:flutter/material.dart';

import 'app/app.dart';
import 'application/controllers/game_controller.dart';
import 'persistence/storage/game_snapshot_store.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final controller = GameController(snapshotStore: GameSnapshotStore());
  await controller.initialize();

  runApp(FounderOsApp(controller: controller));
}
