import 'package:flutter_test/flutter_test.dart';
import 'package:founder_os/domain/catalog/contract_catalog.dart';
import 'package:founder_os/domain/catalog/game_catalog.dart';
import 'package:founder_os/domain/commands/game_action.dart';
import 'package:founder_os/domain/entities/game_state.dart';
import 'package:founder_os/domain/entities/models.dart';
import 'package:founder_os/domain/simulation/engine/game_engine.dart';

import '../support/fixtures.dart';

void main() {
  const engine = GameEngine();

  test('contracts stay locked before company website release', () {
    expect(GameState.initial().contractsUnlocked, isFalse);
  });

  test('released company website unlocks client contracts', () {
    expect(liveWebsiteState().contractsUnlocked, isTrue);
  });

  test('accepting contract creates active work and upfront cash movement', () {
    var state = liveWebsiteState(cash: 1000000);
    final cashBefore = state.cash;
    final template = ContractCatalog.byId('landing_launch');
    state = engine.reduce(state, const AcceptClientContract('landing_launch'));
    expect(state.activeContracts, hasLength(1));
    expect(state.activeContracts.single.templateId, 'landing_launch');
    expect(state.activeContracts.single.progress, 0);
    expect(
      state.cash,
      closeTo(cashBefore + template.reward * template.upfrontPercent, 0.01),
    );
  });

  test('contract team stores explicit employee assignments', () {
    var state = liveWebsiteState(cash: 1000000);
    state = engine.reduce(
      state,
      const AcceptClientContract('internal_dashboard'),
    );
    final frontend = employeeFixture(id: 'front', role: EmployeeRole.frontend);
    final backend = employeeFixture(id: 'back', role: EmployeeRole.backend);
    final designer = employeeFixture(id: 'design', role: EmployeeRole.designer);
    state = state.copyWith(employees: <Employee>[frontend, backend, designer]);
    final contract = state.activeContracts.single;

    state = engine.reduce(
      state,
      SetContractTeam(
        contractId: contract.id,
        employeeIds: const <String>['front', 'back', 'design'],
      ),
    );

    final assignments = state.contractEmployeeAssignments
        .where((item) => item.contractId == contract.id)
        .toList(growable: false);
    expect(assignments, hasLength(2));
    expect(assignments.map((item) => item.employeeId).toSet(), <String>{
      'front',
      'back',
    });
  });

  test('ecosystem supports multiple links and rejects reverse duplicate', () {
    final backend = employeeFixture(
      id: 'integrator',
      role: EmployeeRole.backend,
    );
    final products = <Product>[
      productFixture(id: 'p1', blueprintId: 'ai_assistant'),
      productFixture(id: 'p2', blueprintId: 'cloud_platform'),
      productFixture(id: 'p3', blueprintId: 'team_saas'),
    ];
    var state = fundedInitial().copyWith(
      employees: <Employee>[backend],
      products: products,
    );
    state = engine.reduce(
      state,
      const ConnectProducts(firstProductId: 'p1', secondProductId: 'p2'),
    );
    state = engine.reduce(
      state,
      const ConnectProducts(firstProductId: 'p1', secondProductId: 'p3'),
    );
    final duplicate = engine.reduce(
      state,
      const ConnectProducts(firstProductId: 'p2', secondProductId: 'p1'),
    );
    expect(state.ecosystemLinks, hasLength(2));
    expect(duplicate.ecosystemLinks, hasLength(2));
    expect(state.products, hasLength(3));
  });

  test('ecosystem link activation produces bounded product boost', () {
    final backend = employeeFixture(
      id: 'integrator',
      role: EmployeeRole.backend,
    );
    var state = fundedInitial().copyWith(
      employees: <Employee>[backend],
      products: <Product>[
        productFixture(id: 'p1', blueprintId: 'ai_assistant'),
        productFixture(id: 'p2', blueprintId: 'cloud_platform'),
      ],
    );
    state = engine.reduce(
      state,
      const ConnectProducts(firstProductId: 'p1', secondProductId: 'p2'),
    );
    final activationAt = state.ecosystemLinks.single.activeAtMinutes;
    final active = state.copyWith(simulationMinutes: activationAt);
    expect(active.ecosystemBoostFor('p1'), greaterThan(0));
    expect(active.ecosystemBoostFor('p1'), lessThan(0.2));
  });

  test(
    'market contains acquisition candidates independent of campaign victory',
    () {
      expect(GameCatalog.marketCompanies, isNotEmpty);
      expect(GameState.initial().founderLegacyCompleted, isFalse);
    },
  );

  test('contract catalog keeps five explicit current templates', () {
    expect(ContractCatalog.templates, hasLength(5));
    expect(
      ContractCatalog.templates.map((item) => item.id).toSet(),
      hasLength(5),
    );
    expect(
      ContractCatalog.templates.every((item) => item.requiredRoles.isNotEmpty),
      isTrue,
    );
  });
}
