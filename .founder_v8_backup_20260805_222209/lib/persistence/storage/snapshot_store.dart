import '../../domain/entities/game_state.dart';

abstract interface class SnapshotStore {
  Future<GameState?> load();
  Future<void> save(GameState state);
  Future<void> clear();
}
