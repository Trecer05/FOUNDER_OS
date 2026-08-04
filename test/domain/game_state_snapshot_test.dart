import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:founder_os/domain/commands/game_action.dart';
import 'package:founder_os/domain/entities/game_state.dart';
import 'package:founder_os/domain/entities/product_evolution_models.dart';
import 'package:founder_os/domain/simulation/engine/game_engine.dart';

void main() {
  const engine = GameEngine();

  test('version 5 snapshot round-trips AI, evolution and operations', () {
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
    state = engine.reduce(
      state,
      AssignEmployeeToProduct(
        employeeId: 'c_anna',
        productId: state.products[0].id,
      ),
    );
    state = engine.reduce(
      state,
      PurchaseSecurityControl(
        productId: state.products[0].id,
        controlId: 'secure_sdlc',
      ),
    );
    state = engine.reduce(state, RunSecurityAudit(state.products[0].id));
    state = engine.reduce(
      state,
      ApplyProductImprovement(
        productId: state.products[0].id,
        type: ProductImprovementType.algorithms,
      ),
    );
    state = engine.reduce(
      state,
      SetAiDeploymentMode(
        productId: state.products[0].id,
        mode: AiDeploymentMode.corporate,
      ),
    );
    state = engine.reduce(state, const CompleteOnboarding());

    final restored = GameState.decode(state.encode());

    expect(restored.encode(), state.encode());
    expect(restored.products, hasLength(2));
    expect(restored.employees, hasLength(1));
    expect(restored.ecosystemLinks, hasLength(1));
    expect(restored.employeeAssignments, hasLength(1));
    expect(restored.securityControls, hasLength(1));
    expect(restored.securityAudits, hasLength(1));
    expect(restored.productImprovements, hasLength(1));
    expect(restored.productUpdates, isNotEmpty);
    expect(restored.productAiDeployments, hasLength(1));
    expect(restored.onboardingCompleted, isTrue);
    expect(restored.snapshotVersion, currentSnapshotVersion);
  });

  test(
    'legacy snapshot migrates to version 5 with controlled reset of model',
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

  test('version 3 snapshot keeps old state and adds operations defaults', () {
    final legacyV3 = jsonEncode(<String, Object?>{
      'snapshotVersion': 3,
      'simulationMinutes': 1000,
      'speed': 'x1',
      'paused': true,
      'cash': 123456,
      'products': <Object?>[],
      'candidates': <Object?>[],
      'employees': <Object?>[],
      'ecosystemLinks': <Object?>[],
      'selectedOfficeId': 'garage',
      'selectedServerRoomId': 'closet',
      'installedServers': <Object?>[],
      'investorOffers': <Object?>[],
      'investorAgreements': <Object?>[],
      'founderOwnershipPercent': 100,
      'portfolioHoldings': <Object?>[],
      'acquiredCompanyIds': <Object?>[],
      'news': <Object?>[],
      'criticalEvent': 'none',
      'criticalProductId': null,
      'gameOver': false,
      'miniGamesEnabled': true,
      'rngSeed': 5,
      'rngCounter': 2,
      'feed': <String>['old'],
    });

    final migrated = GameState.decode(legacyV3);

    expect(migrated.snapshotVersion, currentSnapshotVersion);
    expect(migrated.cash, 123456);
    expect(migrated.employeeAssignments, isEmpty);
    expect(migrated.securityControls, isEmpty);
    expect(migrated.securityAudits, isEmpty);
    expect(migrated.productAiDeployments, isEmpty);
    expect(migrated.productAiIntegrations, isEmpty);
    expect(migrated.productImprovements, isEmpty);
    expect(migrated.productUpdates, isEmpty);
    expect(migrated.onboardingCompleted, isFalse);
  });

  test(
    'version 4 migration marks existing products fresh at migration time',
    () {
      var state = GameState.initial().copyWith(cash: 10000000);
      state = engine.reduce(
        state,
        const CreateConfiguredProduct(
          name: 'Legacy Desk',
          blueprintId: 'team_saas',
          frameworkId: 'flutter_firebase',
          languageIds: <String>['typescript'],
          technologyIds: <String>['postgresql'],
          featureIds: <String>['team_spaces', 'automation'],
        ),
      );
      final json = jsonDecode(state.encode()) as Map<String, dynamic>;
      json['snapshotVersion'] = 4;
      json.remove('productAiDeployments');
      json.remove('productAiIntegrations');
      json.remove('productImprovements');
      json.remove('productUpdates');
      json.remove('onboardingCompleted');

      final migrated = GameState.decode(jsonEncode(json));

      expect(migrated.snapshotVersion, currentSnapshotVersion);
      expect(migrated.products, hasLength(1));
      expect(migrated.productUpdates, hasLength(1));
      expect(
        migrated.productUpdates.single.updatedAtMinutes,
        migrated.simulationMinutes,
      );
      expect(migrated.productFreshnessScore(migrated.products.single), 100);
    },
  );

  test('unsupported snapshot version fails with controlled error', () {
    expect(
      () => GameState.decode('{"snapshotVersion":999}'),
      throwsA(isA<FormatException>()),
    );
  });
}
