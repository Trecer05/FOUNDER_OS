import 'package:flutter_test/flutter_test.dart';
import 'package:founder_os/application/performance/native_performance_bridge.dart';
import 'package:founder_os/domain/entities/game_state.dart';
import 'package:founder_os/persistence/storage/game_snapshot_store.dart';

void main() {
  test('legacy fallback snapshot migrates to native atomic storage', () async {
    final legacy = GameState.initial().copyWith(cash: 987654);
    final fallback = _MemoryFallbackStore(<String, String>{
      'founder_os.snapshot.v8': legacy.encode(),
    });
    final bridge = _FakeNativeBridge();
    final store = GameSnapshotStore(
      nativeBridge: bridge,
      fallbackStore: fallback,
    );

    final loaded = await store.load();

    expect(loaded, isNotNull);
    expect(loaded!.cash, legacy.cash);
    expect(bridge.snapshot, isNotNull);
    expect(GameState.decode(bridge.snapshot!).cash, legacy.cash);
    expect(await fallback.getString('founder_os.snapshot.v8'), isNull);
  });

  test('large snapshots encode outside UI work and remain readable', () async {
    final large = GameState.initial().copyWith(
      cash: 333333,
      feed: List<String>.generate(180, (index) => 'event_$index'),
    );
    final fallback = _MemoryFallbackStore();
    final bridge = _FakeNativeBridge();
    final store = GameSnapshotStore(
      nativeBridge: bridge,
      fallbackStore: fallback,
    );

    await store.save(large);

    expect(bridge.snapshot, isNotNull);

    final decoded = GameState.decode(bridge.snapshot!);

    expect(decoded.cash, large.cash);
    expect(decoded.feed, hasLength(180));

    // First successful native save also creates a recovery copy.
    expect(
      await fallback.getString(GameSnapshotStore.fallbackSnapshotKey),
      bridge.snapshot,
    );
  });

  test('native snapshot is preferred over fallback copy', () async {
    final native = GameState.initial().copyWith(cash: 222222);
    final fallbackState = GameState.initial().copyWith(cash: 111111);

    final fallback = _MemoryFallbackStore(<String, String>{
      GameSnapshotStore.fallbackSnapshotKey: fallbackState.encode(),
    });
    final bridge = _FakeNativeBridge()..snapshot = native.encode();

    final store = GameSnapshotStore(
      nativeBridge: bridge,
      fallbackStore: fallback,
    );

    final loaded = await store.load();

    expect(loaded, isNotNull);
    expect(loaded!.cash, native.cash);
    expect(fallback.readCount, 0);
  });

  test(
    'damaged native snapshot recovers from fallback and repairs native',
    () async {
      final recovery = GameState.initial().copyWith(cash: 444444);

      final fallback = _MemoryFallbackStore(<String, String>{
        GameSnapshotStore.fallbackSnapshotKey: recovery.encode(),
      });
      final bridge = _FakeNativeBridge()..snapshot = '{"broken":';

      final store = GameSnapshotStore(
        nativeBridge: bridge,
        fallbackStore: fallback,
      );

      final loaded = await store.load();

      expect(loaded, isNotNull);
      expect(loaded!.cash, recovery.cash);
      expect(GameState.decode(bridge.snapshot!).cash, recovery.cash);
    },
  );

  test('manual slots round-trip independently and survive autosave clear', () async {
    final fallback = _MemoryFallbackStore();
    final bridge = _FakeNativeBridge();
    final store = GameSnapshotStore(
      nativeBridge: bridge,
      fallbackStore: fallback,
    );
    final saved = GameState.initial(seed: 42).copyWith(cash: 7654321);

    await store.saveSlot('slot_2', saved);
    final summaries = await store.listSlots();

    expect(summaries, hasLength(1));
    expect(summaries.single.slotId, 'slot_2');
    expect(summaries.single.cash, saved.cash);
    expect((await store.loadSlot('slot_2'))!.cash, saved.cash);

    await store.clear();
    expect((await store.loadSlot('slot_2'))!.cash, saved.cash);

    await store.deleteSlot('slot_2');
    expect(await store.loadSlot('slot_2'), isNull);
  });
}

class _MemoryFallbackStore implements SnapshotFallbackStore {
  _MemoryFallbackStore([Map<String, String>? initial])
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

class _FakeNativeBridge extends NativePerformanceBridge {
  _FakeNativeBridge() : super(platformAvailable: true);

  String? snapshot;

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
