import 'package:flutter_test/flutter_test.dart';
import 'package:founder_os/application/controllers/game_controller.dart';
import 'package:founder_os/domain/commands/game_action.dart';
import 'package:founder_os/domain/entities/game_state.dart';
import 'package:founder_os/persistence/storage/snapshot_store.dart';

void main() {
  test('save bursts are coalesced and newest snapshot wins', () async {
    final store = _SlowStore();
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

  testWidgets('failed slot load restarts the simulation clock', (tester) async {
    final store = _FailingSlotStore();
    final controller = GameController(
      snapshotStore: store,
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

class _SlowStore implements SnapshotStore {
  GameState? saved;
  int saveCount = 0;

  @override
  Future<void> clear() async => saved = null;

  @override
  Future<GameState?> load() async => saved;

  @override
  Future<void> save(GameState state) async {
    saveCount += 1;
    await Future<void>.delayed(const Duration(milliseconds: 20));
    saved = state;
  }
}

class _FailingSlotStore implements SnapshotStore, SaveSlotStore {
  GameState? saved;

  @override
  Future<void> clear() async => saved = null;

  @override
  Future<void> deleteSlot(String slotId) async {}

  @override
  Future<List<SaveSlotSummary>> listSlots() async => const <SaveSlotSummary>[];

  @override
  Future<GameState?> load() async => saved;

  @override
  Future<GameState?> loadSlot(String slotId) async {
    throw StateError('damaged slot');
  }

  @override
  Future<void> save(GameState state) async => saved = state;

  @override
  Future<void> saveSlot(String slotId, GameState state) async {}
}
