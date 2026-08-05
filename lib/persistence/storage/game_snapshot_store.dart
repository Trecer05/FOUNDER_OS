import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/game_state.dart';
import 'snapshot_store.dart';

class GameSnapshotStore implements SnapshotStore {
  GameSnapshotStore({SharedPreferencesAsync? preferences})
    : _preferences = preferences ?? SharedPreferencesAsync();

  static const _snapshotKey = 'founder_os.snapshot.v8';
  static const _legacySnapshotKeys = <String>[
    'founder_os.snapshot.v7',
    'founder_os.snapshot.v3',
    'founder_os.snapshot.v2',
    'founder_os.snapshot.v1',
  ];

  final SharedPreferencesAsync _preferences;

  @override
  Future<GameState?> load() async {
    final current = await _preferences.getString(_snapshotKey);
    if (current != null && current.isNotEmpty) {
      return GameState.decode(current);
    }

    for (final legacyKey in _legacySnapshotKeys) {
      final legacy = await _preferences.getString(legacyKey);
      if (legacy == null || legacy.isEmpty) {
        continue;
      }
      final migrated = GameState.decode(legacy);
      await save(migrated);
      await _preferences.remove(legacyKey);
      return migrated;
    }
    return null;
  }

  @override
  Future<void> save(GameState state) async {
    await _preferences.setString(_snapshotKey, state.encode());
  }

  @override
  Future<void> clear() async {
    await _preferences.remove(_snapshotKey);
    for (final key in _legacySnapshotKeys) {
      await _preferences.remove(key);
    }
  }
}
