import '../../domain/entities/game_state.dart';

abstract interface class SnapshotStore {
  Future<GameState?> load();
  Future<void> save(GameState state);
  Future<void> clear();
}

class SaveSlotSummary {
  const SaveSlotSummary({
    required this.slotId,
    required this.companyName,
    required this.simulationMinutes,
    required this.cash,
    required this.savedAt,
  });

  final String slotId;
  final String companyName;
  final int simulationMinutes;
  final double cash;
  final DateTime savedAt;
}

abstract interface class SaveSlotStore {
  Future<List<SaveSlotSummary>> listSlots();
  Future<void> saveSlot(String slotId, GameState state);
  Future<GameState?> loadSlot(String slotId);
  Future<void> deleteSlot(String slotId);
}
