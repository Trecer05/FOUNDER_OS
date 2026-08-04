import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:founder_os/domain/commands/game_action.dart';
import 'package:founder_os/domain/entities/game_state.dart';
import 'package:founder_os/domain/simulation/engine/game_engine.dart';

void main() {
  const engine = GameEngine();

  test('version 3 snapshot round-trips products, people and ecosystem', () {
    var state = GameState.initial().copyWith(cash: 10000000);
    state = engine.reduce(
      state,
      const CreateConfiguredProduct(
        name: 'Nova',
        blueprintId: 'ai_assistant',
        frameworkId: 'fastapi_react',
        languageIds: <String>['typescript', 'python'],
        technologyIds: <String>['postgresql', 'vector_db'],
        featureIds: <String>['chat_history', 'file_analysis'],
      ),
    );
    state = engine.reduce(
      state,
      const CreateConfiguredProduct(
        name: 'Orbit',
        blueprintId: 'cloud_platform',
        frameworkId: 'go_microservices',
        languageIds: <String>['go'],
        technologyIds: <String>['postgresql', 'kubernetes'],
        featureIds: <String>['autoscaling', 'monitoring'],
      ),
    );
    state = engine.reduce(state, const HireCandidate('c_anna'));
    state = engine.reduce(
      state,
      ConnectProducts(
        firstProductId: state.products[0].id,
        secondProductId: state.products[1].id,
      ),
    );

    final restored = GameState.decode(state.encode());

    expect(restored.encode(), state.encode());
    expect(restored.products, hasLength(2));
    expect(restored.employees, hasLength(1));
    expect(restored.ecosystemLinks, hasLength(1));
    expect(restored.snapshotVersion, currentSnapshotVersion);
  });

  test(
    'legacy snapshot migrates to version 3 with controlled reset of model',
    () {
      final legacy = jsonEncode(<String, Object?>{
        'snapshotVersion': 2,
        'simulationMinutes': 900,
        'speed': 'x2',
        'paused': false,
        'cash': 91000,
        'miniGamesEnabled': false,
      });

      final migrated = GameState.decode(legacy);

      expect(migrated.snapshotVersion, currentSnapshotVersion);
      expect(migrated.simulationMinutes, 900);
      expect(migrated.speed, GameSpeed.x2);
      expect(migrated.cash, 91000);
      expect(migrated.products, isEmpty);
      expect(migrated.miniGamesEnabled, isFalse);
      expect(migrated.feed.first, contains('перенесено'));
    },
  );

  test('unsupported snapshot version fails with controlled error', () {
    expect(
      () => GameState.decode('{"snapshotVersion":999}'),
      throwsA(isA<FormatException>()),
    );
  });
}
