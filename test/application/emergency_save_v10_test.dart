import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:founder_os/application/controllers/game_controller.dart';
import 'package:founder_os/domain/commands/game_action.dart';
import 'package:founder_os/domain/entities/game_state.dart';
import 'package:founder_os/persistence/storage/snapshot_store.dart';

void main() {
  test(
    'crossing into negative cash forces save even when regular save is off',
    () async {
      final store = _MemorySnapshotStore();
      final controller = GameController(
        snapshotStore: store,
        startClock: false,
      );
      await controller.initialize();

      controller.dispatch(
        const RedeemDebugPromo('FOUNDER-BROKE'),
        playSound: false,
        save: false,
      );
      final saved = await store.firstSave.future.timeout(
        const Duration(seconds: 1),
      );

      expect(saved.cash, lessThan(0));
      controller.dispose();
    },
  );
}

class _MemorySnapshotStore implements SnapshotStore {
  final Completer<GameState> firstSave = Completer<GameState>();
  GameState? saved;

  @override
  Future<void> clear() async {
    saved = null;
  }

  @override
  Future<GameState?> load() async => saved;

  @override
  Future<void> save(GameState state) async {
    saved = state;
    if (!firstSave.isCompleted) firstSave.complete(state);
  }
}
