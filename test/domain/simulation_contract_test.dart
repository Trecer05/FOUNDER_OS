import 'package:flutter_test/flutter_test.dart';
import 'package:founder_os/domain/commands/game_action.dart';
import 'package:founder_os/domain/entities/game_state.dart';
import 'package:founder_os/domain/entities/models.dart';
import 'package:founder_os/domain/simulation/engine/game_engine.dart';

import '../support/fixtures.dart';

void main() {
  const engine = GameEngine();

  test('initial state is the documented deterministic bootstrap', () {
    final state = GameState.initial(seed: 77);
    expect(state.snapshotVersion, 16);
    expect(state.simulationMinutes, 8 * 60);
    expect(state.formattedDateTime, '05.01.2026 08:00');
    expect(state.paused, isTrue);
    expect(state.speed, GameSpeed.x1);
    expect(state.cash, 450000);
    expect(state.products, isEmpty);
    expect(state.employees, isEmpty);
    expect(state.selectedOfficeId, 'remote_first');
    expect(state.selectedServerRoomId, 'no_server_room');
    expect(state.selectedHostingPlanId, 'no_hosting');
    expect(state.founderOwnershipPercent, 100);
    expect(state.companyFans, 0);
    expect(state.brandReputation, 10);
    expect(state.rngSeed, 77);
    expect(state.rngCounter, 0);
  });

  test('same seed and action sequence produces byte-identical state', () {
    GameState run() {
      var state = fundedInitial(seed: 123);
      const actions = <GameAction>[
        CompleteOnboarding(),
        SetGameSpeed(GameSpeed.x4),
        TogglePause(),
        AdvanceTime(15),
        SetGameSpeed(GameSpeed.x2),
        AdvanceTime(7),
      ];
      for (final action in actions) {
        state = engine.reduce(state, action);
      }
      return state;
    }

    expect(run().encode(), run().encode());
  });

  test('same seed produces same procedural candidate market', () {
    final first = GameState.initial(seed: 9);
    final second = GameState.initial(seed: 9);
    expect(
      first.candidates.map((item) => item.toJson()).toList(),
      second.candidates.map((item) => item.toJson()).toList(),
    );
  });

  test('paused game ignores time advancement', () {
    final state = GameState.initial();
    final next = engine.reduce(state, const AdvanceTime(60));
    expect(next.simulationMinutes, state.simulationMinutes);
  });

  test('speed multiplier changes simulation-minute advancement', () {
    var state = GameState.initial().copyWith(paused: false);
    state = engine.reduce(state, const SetGameSpeed(GameSpeed.x4));
    final next = engine.reduce(state, const AdvanceTime(10));
    expect(next.simulationMinutes - state.simulationMinutes, 160);
  });

  test('critical event freezes normal time advancement', () {
    final state = GameState.initial().copyWith(
      paused: false,
      criticalEvent: CriticalEventType.serverOverload,
    );
    final next = engine.reduce(state, const AdvanceTime(100));
    expect(next.simulationMinutes, state.simulationMinutes);
  });

  test('skip night advances to 08:00 and preserves pause state', () {
    final state = GameState.initial().copyWith(
      paused: true,
      simulationMinutes: 22 * 60,
    );
    final next = engine.reduce(state, const SkipNight());
    expect(next.minuteOfDay, 8 * 60);
    expect(next.paused, isTrue);
    expect(next.simulationMinutes, greaterThan(state.simulationMinutes));
  });

  test('snapshot round-trip preserves exact current state', () {
    final state = fundedInitial(seed: 88).copyWith(
      paused: false,
      companyFans: 1234,
      brandReputation: 72.5,
      products: <Product>[productFixture()],
    );
    expect(GameState.decode(state.encode()).encode(), state.encode());
  });

  test('future snapshot version is rejected', () {
    final source = GameState.initial().encode().replaceFirst(
      '"snapshotVersion":16',
      '"snapshotVersion":999',
    );
    expect(() => GameState.decode(source), throwsFormatException);
  });

  test('non-object snapshot root is rejected', () {
    expect(() => GameState.decode('[]'), throwsFormatException);
  });
}
