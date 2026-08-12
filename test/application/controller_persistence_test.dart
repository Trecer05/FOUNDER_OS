import 'package:flutter_test/flutter_test.dart';
import 'package:founder_os/application/controllers/game_controller.dart';
import 'package:founder_os/domain/commands/game_action.dart';
import 'package:founder_os/domain/entities/game_state.dart';

import '../support/fakes.dart';

void main() {
  test(
    'controller initializes from stored snapshot instead of replacing it',
    () async {
      final stored = GameState.initial(seed: 7).copyWith(cash: 987654);
      final store = MemorySnapshotStore(stored);
      final controller = GameController(
        snapshotStore: store,
        startClock: false,
      );
      addTearDown(controller.dispose);
      await controller.initialize();
      expect(controller.state.cash, 987654);
      expect(controller.state.rngSeed, 7);
    },
  );

  test('state-changing action is persisted', () async {
    final store = MemorySnapshotStore(GameState.initial());
    final controller = GameController(snapshotStore: store, startClock: false);
    addTearDown(controller.dispose);
    await controller.initialize();
    controller.dispatch(const CompleteOnboarding());
    await controller.saveNow();
    expect(store.value!.onboardingCompleted, isTrue);
  });

  test('save bursts are coalesced and newest snapshot wins', () async {
    final store = SlowSnapshotStore();
    final controller = GameController(snapshotStore: store, startClock: false);
    addTearDown(controller.dispose);
    await controller.initialize();
    controller.dispatch(const CompleteOnboarding());
    controller.dispatch(const SetGameSpeed(GameSpeed.x2));
    controller.dispatch(const SetGameSpeed(GameSpeed.x4));
    await controller.saveNow();
    expect(store.saved, isNotNull);
    expect(store.saved!.onboardingCompleted, isTrue);
    expect(store.saved!.speed, GameSpeed.x4);
    expect(store.saved!.encode(), controller.state.encode());
    expect(store.saveCount, lessThanOrEqualTo(2));
  });

  test('manual save slot round-trips through controller', () async {
    final store = MemorySnapshotStore(GameState.initial().copyWith(cash: 1000));
    final controller = GameController(snapshotStore: store, startClock: false);
    addTearDown(controller.dispose);
    await controller.initialize();
    controller.dispatch(const CompleteOnboarding());
    await controller.saveToSlot('slot_1');
    controller.dispatch(const SetGameSpeed(GameSpeed.x4));
    await controller.loadFromSlot('slot_1');
    expect(controller.state.onboardingCompleted, isTrue);
    expect(controller.state.speed, GameSpeed.x1);
  });

  test('controller reset clears autosave and installs fresh state', () async {
    final store = MemorySnapshotStore(
      GameState.initial().copyWith(cash: 999999),
    );
    final controller = GameController(snapshotStore: store, startClock: false);
    addTearDown(controller.dispose);
    await controller.initialize();
    await controller.reset();
    expect(controller.state.cash, 450000);
    expect(store.value!.cash, 450000);
  });

  testWidgets('failed slot load restarts simulation clock', (tester) async {
    final store = FailingSlotStore();
    final controller = GameController(
      snapshotStore: store,
      enableBackgroundLifecycle: false,
      tickInterval: const Duration(milliseconds: 10),
    );
    try {
      await controller.initialize();
      controller.dispatch(const TogglePause());
      await expectLater(controller.loadFromSlot('slot_1'), throwsStateError);
      final before = controller.state.simulationMinutes;
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 1100)),
      );
      await tester.pump(const Duration(milliseconds: 10));
      expect(controller.state.simulationMinutes, greaterThan(before));
    } finally {
      controller.dispose();
    }
  });
}
