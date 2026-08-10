import 'package:flutter_test/flutter_test.dart';
import 'package:founder_os/domain/catalog/game_catalog.dart';
import 'package:founder_os/domain/commands/game_action.dart';
import 'package:founder_os/domain/entities/game_state.dart';
import 'package:founder_os/domain/entities/models.dart';
import 'package:founder_os/domain/entities/operations_models.dart';
import 'package:founder_os/domain/simulation/engine/game_engine.dart';

void main() {
  const engine = GameEngine();

  test('new company starts without purchased physical servers', () {
    final state = GameState.initial();
    expect(currentSnapshotVersion, 13);
    expect(state.snapshotVersion, 13);
    expect(state.installedServers, isEmpty);
    expect(state.preparedComputeUnits, 0);
  });

  test('v10 automatic starter pair is removed on rented hosting migration', () {
    final legacy = GameState.initial().copyWith(
      snapshotVersion: 10,
      selectedHostingPlanId: 'shared_launch',
      installedServers: const <InstalledServer>[
        InstalledServer(hardwareId: 'edge_s1', count: 2),
      ],
    );

    final migrated = GameState.decode(legacy.encode());

    expect(migrated.snapshotVersion, 13);
    expect(migrated.installedServers, isEmpty);
  });

  test('owned infrastructure keeps its physical servers during migration', () {
    final legacy = GameState.initial().copyWith(
      snapshotVersion: 10,
      selectedHostingPlanId: 'owned',
      installedServers: const <InstalledServer>[
        InstalledServer(hardwareId: 'edge_s1', count: 2),
      ],
    );

    final migrated = GameState.decode(legacy.encode());

    expect(migrated.installedCount('edge_s1'), 2);
  });

  test('v10 migration preserves paid servers beyond the automatic pair', () {
    final legacy = GameState.initial().copyWith(
      snapshotVersion: 10,
      selectedHostingPlanId: 'shared_launch',
      installedServers: const <InstalledServer>[
        InstalledServer(hardwareId: 'edge_s1', count: 3),
      ],
    );

    final migrated = GameState.decode(legacy.encode());

    expect(migrated.installedCount('edge_s1'), 1);
  });

  test('v10 migration removes hidden HR product assignment', () {
    final hrCandidate = GameCatalog.initialCandidates.singleWhere(
      (item) => item.isHr,
    );
    final hr = hrCandidate.toEmployee();
    var legacy = GameState.initial().copyWith(
      snapshotVersion: 10,
      cash: 1000000,
      employees: <Employee>[hr],
      candidates: GameState.initial().candidates
          .where((candidate) => candidate.id != hr.id)
          .toList(growable: false),
    );
    legacy = engine.reduce(
      legacy,
      const CreateConfiguredProduct(
        name: 'First Landing',
        blueprintId: 'company_website',
        frameworkId: 'static_web',
        languageIds: <String>['html_css'],
        technologyIds: <String>[],
        featureIds: <String>['landing_page'],
      ),
    );
    legacy = legacy.copyWith(
      employeeAssignments: <EmployeeAssignment>[
        EmployeeAssignment(
          employeeId: hr.id,
          productId: legacy.products.single.id,
          assignedAtMinutes: legacy.simulationMinutes,
        ),
      ],
    );

    final migrated = GameState.decode(legacy.encode());

    expect(migrated.employees.single.isHr, isTrue);
    expect(migrated.employeeAssignments, isEmpty);
  });

  test('auto hire cannot mutate company without a hired HR employee', () {
    var state = GameState.initial().copyWith(cash: 1000000);
    state = engine.reduce(
      state,
      const CreateConfiguredProduct(
        name: 'First Landing',
        blueprintId: 'company_website',
        frameworkId: 'static_web',
        languageIds: <String>['html_css'],
        technologyIds: <String>[],
        featureIds: <String>['landing_page'],
      ),
    );
    final product = state.products.single;
    final beforeCash = state.cash;
    final beforeCandidates = state.candidates.length;

    final next = engine.reduce(state, AutoHireProjectTeam(product.id));

    expect(next.employees, isEmpty);
    expect(next.candidates, hasLength(beforeCandidates));
    expect(next.cash, beforeCash);
    expect(next.employeeAssignments, isEmpty);
    expect(next.feed.first, contains('сначала наймите HR'));
  });

  test('HR candidate is explicit and not a hidden project specialist', () {
    final hr = GameCatalog.initialCandidates.singleWhere((item) => item.isHr);
    var state = GameState.initial().copyWith(cash: 1000000);
    state = engine.reduce(
      state,
      const CreateConfiguredProduct(
        name: 'First Landing',
        blueprintId: 'company_website',
        frameworkId: 'static_web',
        languageIds: <String>['html_css'],
        technologyIds: <String>[],
        featureIds: <String>['landing_page'],
      ),
    );

    final blocked = engine.reduce(
      state,
      HireCandidateForProduct(
        candidateId: hr.id,
        productId: state.products.single.id,
      ),
    );

    expect(blocked.employees, isEmpty);
    expect(blocked.feed.first, contains('разделе «Команда»'));
  });
}
