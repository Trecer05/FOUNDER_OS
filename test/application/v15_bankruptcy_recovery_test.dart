import 'package:flutter_test/flutter_test.dart';
import 'package:founder_os/application/controllers/game_controller.dart';
import 'package:founder_os/domain/entities/game_state.dart';
import 'package:founder_os/domain/entities/models.dart';
import 'package:founder_os/persistence/storage/snapshot_store.dart';

void main() {
  test(
    'bankruptcy recovery restores the newest checkpoint at least a week old',
    () async {
      final safe = GameState.initial().copyWith(
        simulationMinutes: 7 * 1440,
        cash: 420000,
      );
      final bankrupt = GameState.initial().copyWith(
        simulationMinutes: 15 * 1440,
        cash: -900000,
        paused: true,
        criticalEvent: CriticalEventType.insolvency,
        gameOver: true,
      );
      final store = _RecoveryStore(
        current: bankrupt,
        checkpoints: <GameState>[safe],
      );
      final controller = GameController(
        snapshotStore: store,
        startClock: false,
      );
      addTearDown(controller.dispose);
      await controller.initialize();

      final restored = await controller.restoreWeekBeforeBankruptcy();

      expect(restored, isTrue);
      expect(controller.state.simulationMinutes, safe.simulationMinutes);
      expect(controller.state.cash, safe.cash);
      expect(controller.state.criticalEvent, CriticalEventType.none);
      expect(controller.state.gameOver, isFalse);
      expect(controller.state.paused, isTrue);
    },
  );
}

class _RecoveryStore implements SnapshotStore, BankruptcyRecoveryStore {
  _RecoveryStore({required this.current, required this.checkpoints});

  GameState? current;
  final List<GameState> checkpoints;

  @override
  Future<void> clear() async {
    current = null;
    checkpoints.clear();
  }

  @override
  Future<GameState?> load() async => current;

  @override
  Future<void> save(GameState state) async => current = state;

  @override
  Future<void> saveRecoveryCheckpoint(GameState state) async {
    checkpoints.add(state);
  }

  @override
  Future<GameState?> loadRecoveryCheckpoint({
    required int beforeMinutes,
  }) async {
    final eligible =
        checkpoints
            .where((item) => item.simulationMinutes <= beforeMinutes)
            .toList(growable: false)
          ..sort(
            (left, right) =>
                right.simulationMinutes.compareTo(left.simulationMinutes),
          );
    return eligible.isEmpty ? null : eligible.first;
  }
}
