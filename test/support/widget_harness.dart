import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:founder_os/app/app.dart';
import 'package:founder_os/application/controllers/game_controller.dart';
import 'package:founder_os/domain/entities/game_state.dart';
import 'package:founder_os/domain/entities/v12_models.dart';

import 'fakes.dart';

Future<GameController> pumpFounderApp(
  WidgetTester tester, {
  GameState? state,
  Size size = const Size(430, 932),
}) async {
  await tester.binding.setSurfaceSize(size);
  addTearDown(() => tester.binding.setSurfaceSize(null));

  final seeded =
      state ??
      GameState.initial().copyWith(
        onboardingCompleted: true,
        companyProfile: const FounderCompanyProfile.legacy(),
      );
  final store = MemorySnapshotStore(seeded);
  final controller = GameController(snapshotStore: store, startClock: false);
  addTearDown(controller.dispose);
  await controller.initialize();

  await tester.pumpWidget(
    FounderOsApp(controller: controller, showGlobalTimeControls: false),
  );
  await tester.pumpAndSettle();

  final tutorialSkip = find.byKey(const Key('tutorial-skip'));
  if (tutorialSkip.evaluate().isNotEmpty) {
    await tester.tap(tutorialSkip);
    await tester.pumpAndSettle();
  }
  return controller;
}

Future<GameController> controllerFor(GameState state) async {
  final controller = GameController(
    snapshotStore: MemorySnapshotStore(state),
    startClock: false,
  );
  await controller.initialize();
  return controller;
}
