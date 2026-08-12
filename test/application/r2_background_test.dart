import 'package:flutter_test/flutter_test.dart';
import 'package:founder_os/application/controllers/game_controller.dart';
import 'package:founder_os/domain/entities/game_state.dart';
import 'package:founder_os/application/background/background_simulation_service.dart';
import 'package:founder_os/domain/entities/models.dart';

import '../support/fakes.dart';
import '../support/fixtures.dart';

void main() {
  test('background catch-up advances a running simulation', () {
    final state = fundedInitial().copyWith(paused: false);
    final next = BackgroundSimulationService.catchUp(state, 60);
    expect(next.simulationMinutes, greaterThan(state.simulationMinutes));
  });

  test('background catch-up does not advance a manually paused game', () {
    final state = fundedInitial().copyWith(paused: true);
    final next = BackgroundSimulationService.catchUp(state, 60);
    expect(next.simulationMinutes, state.simulationMinutes);
  });

  test('background catch-up stops when a critical event is already active', () {
    final state = fundedInitial().copyWith(
      paused: false,
      criticalEvent: CriticalEventType.insolvency,
    );
    final next = BackgroundSimulationService.catchUp(state, 3600);
    expect(next.simulationMinutes, state.simulationMinutes);
  });

  test('critical prediction is absent for paused state', () async {
    final prediction = await BackgroundSimulationService.predictCritical(
      fundedInitial().copyWith(paused: true),
    );
    expect(prediction, isNull);
  });

  test('pure controller does not require platform preferences', () async {
    final controller = GameController(
      snapshotStore: MemorySnapshotStore(fundedInitial()),
      startClock: false,
    );
    addTearDown(controller.dispose);

    await controller.initialize();
    expect(controller.initialized, isTrue);

    await controller.reset();
    expect(
      controller.state.simulationMinutes,
      GameState.initial().simulationMinutes,
    );
  });
}
