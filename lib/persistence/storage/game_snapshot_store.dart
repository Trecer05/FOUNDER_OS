import 'dart:isolate';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../application/performance/native_performance_bridge.dart';
import '../../domain/entities/game_state.dart';
import 'snapshot_store.dart';

/// Minimal fallback contract.
///
/// Production uses SharedPreferencesAsync. Unit tests can inject an in-memory
/// implementation and verify snapshot priority without invoking plugin channels.
abstract interface class SnapshotFallbackStore {
  Future<String?> getString(String key);

  Future<void> setString(String key, String value);

  Future<void> remove(String key);
}

class SharedPreferencesSnapshotFallbackStore implements SnapshotFallbackStore {
  SharedPreferencesSnapshotFallbackStore({SharedPreferencesAsync? preferences})
    : _preferences = preferences ?? SharedPreferencesAsync();

  final SharedPreferencesAsync _preferences;

  @override
  Future<String?> getString(String key) => _preferences.getString(key);

  @override
  Future<void> setString(String key, String value) =>
      _preferences.setString(key, value);

  @override
  Future<void> remove(String key) => _preferences.remove(key);
}

/// Hybrid snapshot storage.
///
/// iOS and Android use a native atomic file as the primary store.
/// SharedPreferencesAsync remains a portable recovery and migration source.
class GameSnapshotStore
    implements SnapshotStore, SaveSlotStore, BankruptcyRecoveryStore {
  GameSnapshotStore({
    SharedPreferencesAsync? preferences,
    SnapshotFallbackStore? fallbackStore,
    NativePerformanceBridge? nativeBridge,
  }) : assert(
         preferences == null || fallbackStore == null,
         'Pass either preferences or fallbackStore, not both.',
       ),
       _fallbackStore =
           fallbackStore ??
           SharedPreferencesSnapshotFallbackStore(preferences: preferences),
       _nativeBridge = nativeBridge ?? NativePerformanceBridge.instance;

  static const fallbackSnapshotKey = 'founder_os.snapshot.v10.fallback';
  static const manualSlotIds = <String>['slot_1', 'slot_2', 'slot_3'];
  static const _manualSlotPrefix = 'founder_os.manual_save.v1.';
  static const _recoverySlotPrefix = 'founder_os.weekly_recovery.v1.';
  static const _recoverySlotCount = 3;

  static const legacySnapshotKeys = <String>[
    'founder_os.snapshot.v8',
    'founder_os.snapshot.v7',
    'founder_os.snapshot.v3',
    'founder_os.snapshot.v2',
    'founder_os.snapshot.v1',
  ];

  final SnapshotFallbackStore _fallbackStore;
  final NativePerformanceBridge _nativeBridge;

  int _nativeSaveCount = 0;

  @override
  Future<GameState?> load() async {
    final native = await _nativeBridge.loadSnapshot();

    if (native != null && native.isNotEmpty) {
      try {
        return GameState.decode(native);
      } on Object {
        // Continue to the controlled recovery copy.
      }
    }

    final fallback = await _fallbackStore.getString(fallbackSnapshotKey);

    if (fallback != null && fallback.isNotEmpty) {
      final decoded = GameState.decode(fallback);

      // Repair the primary copy when the native file is absent or damaged.
      await _nativeBridge.saveSnapshot(decoded.encode());
      return decoded;
    }

    for (final legacyKey in legacySnapshotKeys) {
      final legacy = await _fallbackStore.getString(legacyKey);

      if (legacy == null || legacy.isEmpty) {
        continue;
      }

      final migrated = GameState.decode(legacy);

      await save(migrated);
      await _fallbackStore.remove(legacyKey);

      return migrated;
    }

    return null;
  }

  @override
  Future<void> save(GameState state) async {
    final encoded = await _encode(state);
    final savedNatively = await _nativeBridge.saveSnapshot(encoded);

    if (!savedNatively) {
      await _fallbackStore.setString(fallbackSnapshotKey, encoded);
      return;
    }

    // Keep a periodic recovery copy without doubling every autosave.
    _nativeSaveCount += 1;

    if (_nativeSaveCount == 1 || _nativeSaveCount % 8 == 0) {
      await _fallbackStore.setString(fallbackSnapshotKey, encoded);
    }
  }

  Future<String> _encode(GameState state) {
    final weight =
        state.products.length +
        state.employees.length +
        state.financeTransactions.length +
        state.productMetricHistory.length +
        state.feed.length;

    if (weight < 160) {
      return Future<String>.value(state.encode());
    }

    return Isolate.run<String>(state.encode);
  }

  @override
  Future<void> clear() async {
    await _nativeBridge.clearSnapshot();
    await _fallbackStore.remove(fallbackSnapshotKey);

    for (final key in legacySnapshotKeys) {
      await _fallbackStore.remove(key);
    }
    for (var index = 0; index < _recoverySlotCount; index += 1) {
      await _fallbackStore.remove('$_recoverySlotPrefix$index');
    }
  }

  String _manualSlotKey(String slotId) {
    if (!manualSlotIds.contains(slotId)) {
      throw ArgumentError.value(slotId, 'slotId', 'Unknown manual save slot');
    }
    return '$_manualSlotPrefix$slotId';
  }

  @override
  Future<List<SaveSlotSummary>> listSlots() async {
    final result = <SaveSlotSummary>[];
    for (final slotId in manualSlotIds) {
      final raw = await _fallbackStore.getString(_manualSlotKey(slotId));
      if (raw == null || raw.isEmpty) continue;
      try {
        final payload = jsonDecode(raw) as Map<String, dynamic>;
        final state = GameState.decode(payload['snapshot']! as String);
        result.add(
          SaveSlotSummary(
            slotId: slotId,
            companyName: state.companyProfile.companyName,
            simulationMinutes: state.simulationMinutes,
            cash: state.cash,
            savedAt: DateTime.fromMillisecondsSinceEpoch(
              (payload['savedAt']! as num).toInt(),
            ),
          ),
        );
      } on Object {
        // A damaged manual slot must never make the autosave unusable.
      }
    }
    return result;
  }

  @override
  Future<void> saveSlot(String slotId, GameState state) async {
    final encoded = await _encode(state);
    await _fallbackStore.setString(
      _manualSlotKey(slotId),
      jsonEncode(<String, Object>{
        'savedAt': DateTime.now().millisecondsSinceEpoch,
        'snapshot': encoded,
      }),
    );
  }

  @override
  Future<GameState?> loadSlot(String slotId) async {
    final raw = await _fallbackStore.getString(_manualSlotKey(slotId));
    if (raw == null || raw.isEmpty) return null;
    final payload = jsonDecode(raw) as Map<String, dynamic>;
    return GameState.decode(payload['snapshot']! as String);
  }

  @override
  Future<void> deleteSlot(String slotId) =>
      _fallbackStore.remove(_manualSlotKey(slotId));

  @override
  Future<void> saveRecoveryCheckpoint(GameState state) async {
    final week = state.simulationMinutes ~/ (7 * 1440);
    final slot = week % _recoverySlotCount;
    final encoded = await _encode(state);
    await _fallbackStore.setString(
      '$_recoverySlotPrefix$slot',
      jsonEncode(<String, Object>{
        'week': week,
        'simulationMinutes': state.simulationMinutes,
        'snapshot': encoded,
      }),
    );
  }

  @override
  Future<GameState?> loadRecoveryCheckpoint({
    required int beforeMinutes,
  }) async {
    GameState? best;
    for (var index = 0; index < _recoverySlotCount; index += 1) {
      final raw = await _fallbackStore.getString('$_recoverySlotPrefix$index');
      if (raw == null || raw.isEmpty) continue;
      try {
        final payload = jsonDecode(raw) as Map<String, dynamic>;
        final state = GameState.decode(payload['snapshot']! as String);
        if (state.simulationMinutes <= beforeMinutes &&
            (best == null ||
                state.simulationMinutes > best.simulationMinutes)) {
          best = state;
        }
      } on Object {
        // One damaged rolling checkpoint must not block the other copies.
      }
    }
    return best;
  }
}
