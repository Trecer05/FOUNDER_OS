import 'package:flutter_test/flutter_test.dart';
import 'package:founder_os/domain/entities/game_state.dart';
import 'package:founder_os/persistence/storage/game_snapshot_store.dart';

import '../support/fakes.dart';

void main() {
  test('legacy fallback snapshot migrates to native atomic storage', () async {
    final legacy = GameState.initial().copyWith(cash: 987654);
    final fallback = MemoryFallbackStore(<String, String>{
      'founder_os.snapshot.v8': legacy.encode(),
    });
    final bridge = FakeNativeBridge();
    final store = GameSnapshotStore(
      nativeBridge: bridge,
      fallbackStore: fallback,
    );

    final loaded = await store.load();
    expect(loaded, isNotNull);
    expect(loaded!.cash, legacy.cash);
    expect(GameState.decode(bridge.snapshot!).cash, legacy.cash);
    expect(await fallback.getString('founder_os.snapshot.v8'), isNull);
  });

  test('native snapshot is preferred over fallback copy', () async {
    final native = GameState.initial().copyWith(cash: 222222);
    final fallbackState = GameState.initial().copyWith(cash: 111111);
    final fallback = MemoryFallbackStore(<String, String>{
      GameSnapshotStore.fallbackSnapshotKey: fallbackState.encode(),
    });
    final bridge = FakeNativeBridge()..snapshot = native.encode();
    final store = GameSnapshotStore(
      nativeBridge: bridge,
      fallbackStore: fallback,
    );

    final loaded = await store.load();
    expect(loaded!.cash, native.cash);
    expect(fallback.readCount, 0);
  });

  test(
    'damaged native snapshot recovers from fallback and repairs primary',
    () async {
      final recovery = GameState.initial().copyWith(cash: 444444);
      final fallback = MemoryFallbackStore(<String, String>{
        GameSnapshotStore.fallbackSnapshotKey: recovery.encode(),
      });
      final bridge = FakeNativeBridge()..snapshot = '{"broken":';
      final store = GameSnapshotStore(
        nativeBridge: bridge,
        fallbackStore: fallback,
      );
      final loaded = await store.load();
      expect(loaded!.cash, recovery.cash);
      expect(GameState.decode(bridge.snapshot!).cash, recovery.cash);
    },
  );

  test('large snapshot stays readable and creates recovery fallback', () async {
    final large = GameState.initial().copyWith(
      cash: 333333,
      feed: List<String>.generate(180, (index) => 'event_$index'),
    );
    final fallback = MemoryFallbackStore();
    final bridge = FakeNativeBridge();
    final store = GameSnapshotStore(
      nativeBridge: bridge,
      fallbackStore: fallback,
    );
    await store.save(large);
    expect(GameState.decode(bridge.snapshot!).feed, hasLength(180));
    expect(
      await fallback.getString(GameSnapshotStore.fallbackSnapshotKey),
      bridge.snapshot,
    );
  });

  test('manual save slots remain independent from autosave clear', () async {
    final fallback = MemoryFallbackStore();
    final bridge = FakeNativeBridge();
    final store = GameSnapshotStore(
      nativeBridge: bridge,
      fallbackStore: fallback,
    );
    final saved = GameState.initial(seed: 42).copyWith(cash: 7654321);
    await store.saveSlot('slot_2', saved);
    expect((await store.loadSlot('slot_2'))!.cash, saved.cash);
    await store.clear();
    expect((await store.loadSlot('slot_2'))!.cash, saved.cash);
    await store.deleteSlot('slot_2');
    expect(await store.loadSlot('slot_2'), isNull);
  });

  test(
    'manual slot summaries skip damaged entries instead of failing list',
    () async {
      final fallback = MemoryFallbackStore(<String, String>{
        'founder_os.manual_save.v1.slot_1': '{"broken":',
      });
      final store = GameSnapshotStore(
        nativeBridge: FakeNativeBridge(),
        fallbackStore: fallback,
      );

      await store.saveSlot('slot_2', GameState.initial().copyWith(cash: 123));

      final summaries = await store.listSlots();
      expect(summaries.where((item) => item.slotId == 'slot_2'), hasLength(1));
      expect(summaries.where((item) => item.slotId == 'slot_1'), isEmpty);
    },
  );
}
