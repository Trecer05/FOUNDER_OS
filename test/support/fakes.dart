import 'package:founder_os/application/performance/native_performance_bridge.dart';
import 'package:founder_os/domain/entities/game_state.dart';
import 'package:founder_os/persistence/storage/game_snapshot_store.dart';
import 'package:founder_os/persistence/storage/snapshot_store.dart';

class MemorySnapshotStore
    implements SnapshotStore, SaveSlotStore, BankruptcyRecoveryStore {
  MemorySnapshotStore([this.value]);

  GameState? value;
  final Map<String, GameState> slots = <String, GameState>{};
  final List<GameState> recovery = <GameState>[];
  int saveCount = 0;

  @override
  Future<void> clear() async => value = null;

  @override
  Future<GameState?> load() async => value;

  @override
  Future<void> save(GameState state) async {
    saveCount += 1;
    value = state;
  }

  @override
  Future<void> deleteSlot(String slotId) async {
    slots.remove(slotId);
  }

  @override
  Future<List<SaveSlotSummary>> listSlots() async => slots.entries
      .map(
        (entry) => SaveSlotSummary(
          slotId: entry.key,
          companyName: entry.value.companyProfile.companyName,
          simulationMinutes: entry.value.simulationMinutes,
          cash: entry.value.cash,
          savedAt: DateTime.utc(2026, 1, 1),
        ),
      )
      .toList(growable: false);

  @override
  Future<GameState?> loadSlot(String slotId) async => slots[slotId];

  @override
  Future<void> saveSlot(String slotId, GameState state) async {
    slots[slotId] = state;
  }

  @override
  Future<void> saveRecoveryCheckpoint(GameState state) async {
    recovery.add(state);
    if (recovery.length > 3) {
      recovery.removeAt(0);
    }
  }

  @override
  Future<GameState?> loadRecoveryCheckpoint({
    required int beforeMinutes,
  }) async {
    final candidates =
        recovery
            .where((state) => state.simulationMinutes <= beforeMinutes)
            .toList()
          ..sort(
            (left, right) =>
                right.simulationMinutes.compareTo(left.simulationMinutes),
          );
    return candidates.isEmpty ? null : candidates.first;
  }
}

class SlowSnapshotStore implements SnapshotStore {
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

class FailingSlotStore implements SnapshotStore, SaveSlotStore {
  GameState? saved;

  @override
  Future<void> clear() async => saved = null;

  @override
  Future<GameState?> load() async => saved;

  @override
  Future<void> save(GameState state) async => saved = state;

  @override
  Future<void> deleteSlot(String slotId) async {}

  @override
  Future<List<SaveSlotSummary>> listSlots() async => const <SaveSlotSummary>[];

  @override
  Future<GameState?> loadSlot(String slotId) async {
    throw StateError('damaged slot');
  }

  @override
  Future<void> saveSlot(String slotId, GameState state) async {}
}

class MemoryFallbackStore implements SnapshotFallbackStore {
  MemoryFallbackStore([Map<String, String>? initial])
    : values = <String, String>{...?initial};

  final Map<String, String> values;
  int readCount = 0;
  int writeCount = 0;
  int removeCount = 0;

  @override
  Future<String?> getString(String key) async {
    readCount += 1;
    return values[key];
  }

  @override
  Future<void> setString(String key, String value) async {
    writeCount += 1;
    values[key] = value;
  }

  @override
  Future<void> remove(String key) async {
    removeCount += 1;
    values.remove(key);
  }
}

class FakeNativeBridge extends NativePerformanceBridge {
  FakeNativeBridge() : super();

  String? snapshot;

  @override
  Future<bool> isAvailable() async => true;

  @override
  Future<String?> loadSnapshot() async => snapshot;

  @override
  Future<bool> saveSnapshot(String value) async {
    snapshot = value;
    return true;
  }

  @override
  Future<bool> clearSnapshot() async {
    snapshot = null;
    return true;
  }
}
