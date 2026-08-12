import 'dart:isolate';

import '../../domain/commands/game_action.dart';
import '../../domain/entities/game_state.dart';
import '../../domain/entities/models.dart';
import '../../domain/simulation/engine/game_engine.dart';

class BackgroundCriticalPrediction {
  const BackgroundCriticalPrediction({
    required this.delaySeconds,
    required this.title,
    required this.body,
  });

  final int delaySeconds;
  final String title;
  final String body;
}

abstract final class BackgroundSimulationService {
  static const int maxCatchUpSeconds = 12 * 60 * 60;

  static Future<BackgroundCriticalPrediction?> predictCritical(
    GameState state, {
    bool english = false,
  }) {
    if (state.paused ||
        state.gameOver ||
        state.criticalEvent != CriticalEventType.none) {
      return Future<BackgroundCriticalPrediction?>.value(null);
    }
    return Isolate.run(
      () => _predictCriticalFromSnapshot(state.encode(), english: english),
    );
  }

  static BackgroundCriticalPrediction? _predictCriticalFromSnapshot(
    String snapshot, {
    required bool english,
  }) {
    const engine = GameEngine();
    var probe = GameState.decode(snapshot);
    var elapsed = 0;
    while (elapsed < maxCatchUpSeconds &&
        !probe.gameOver &&
        probe.criticalEvent == CriticalEventType.none) {
      const batch = 15;
      probe = engine.reduce(probe, const AdvanceTime(batch));
      elapsed += batch;
    }
    if (probe.criticalEvent == CriticalEventType.none) return null;
    final product = probe.criticalProductId == null
        ? null
        : probe.productById(probe.criticalProductId!);
    final reason = english
        ? switch (probe.criticalEvent) {
            CriticalEventType.serverOverload =>
              'Overload: ${product?.name ?? 'product'}',
            CriticalEventType.securityBreach =>
              'Attack on ${product?.name ?? 'product'}',
            CriticalEventType.insolvency => 'Company is insolvent',
            CriticalEventType.lostControl => 'Founder lost control',
            CriticalEventType.none => 'Simulation stopped',
          }
        : switch (probe.criticalEvent) {
            CriticalEventType.serverOverload =>
              'Перегрузка ${product?.name ?? 'продукта'}',
            CriticalEventType.securityBreach =>
              'Атака на ${product?.name ?? 'продукт'}',
            CriticalEventType.insolvency => 'Компания неплатёжеспособна',
            CriticalEventType.lostControl => 'Основатель потерял контроль',
            CriticalEventType.none => 'Симуляция остановлена',
          };
    return BackgroundCriticalPrediction(
      delaySeconds: elapsed,
      title: english
          ? 'FOUNDER.OS • time stopped'
          : 'FOUNDER.OS • время остановлено',
      body: english
          ? '$reason. Open the game to make a decision.'
          : '$reason. Откройте игру, чтобы принять решение.',
    );
  }

  static GameState catchUp(GameState state, int realSeconds) {
    if (realSeconds <= 0 ||
        state.paused ||
        state.gameOver ||
        state.criticalEvent != CriticalEventType.none) {
      return state;
    }
    const engine = GameEngine();
    var next = state;
    var remaining = realSeconds.clamp(0, maxCatchUpSeconds).toInt();
    while (remaining > 0 &&
        !next.gameOver &&
        next.criticalEvent == CriticalEventType.none) {
      final batch = remaining > 15 ? 15 : remaining;
      next = engine.reduce(next, AdvanceTime(batch));
      remaining -= batch;
    }
    return next;
  }
}
