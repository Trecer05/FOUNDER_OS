import 'package:flutter_test/flutter_test.dart';
import 'package:founder_os/domain/catalog/game_catalog.dart';
import 'package:founder_os/domain/commands/game_action.dart';
import 'package:founder_os/domain/entities/game_state.dart';
import 'package:founder_os/domain/entities/models.dart';
import 'package:founder_os/domain/entities/operations_models.dart';
import 'package:founder_os/domain/entities/product_evolution_models.dart';
import 'package:founder_os/domain/simulation/engine/game_engine.dart';

void main() {
  const engine = GameEngine();

  test('inactive product assignments do not reduce parallel efficiency', () {
    var state = GameState.initial().copyWith(cash: 100000000);
    for (var index = 0; index < 3; index += 1) {
      state = engine.reduce(
        state,
        CreateConfiguredProduct(
          name: 'Assignment $index',
          blueprintId: 'company_website',
          frameworkId: 'static_web',
          languageIds: const <String>['html_css'],
          technologyIds: const <String>[],
          featureIds: const <String>['landing_page'],
        ),
      );
    }
    final employee = state.candidates
        .firstWhere((candidate) => !candidate.isHr)
        .toEmployee();
    final products = <Product>[
      state.products[0],
      state.products[1].copyWith(
        stage: ProductStage.live,
        developmentProgress: 1,
      ),
      state.products[2].copyWith(
        stage: ProductStage.live,
        developmentProgress: 1,
      ),
    ];
    state = state.copyWith(
      products: products,
      employees: <Employee>[employee],
      employeeAssignments: <EmployeeAssignment>[
        for (final product in products)
          EmployeeAssignment(
            employeeId: employee.id,
            productId: product.id,
            assignedAtMinutes: state.simulationMinutes,
          ),
      ],
    );

    expect(state.assignmentsForEmployee(employee.id), hasLength(3));
    expect(state.activeAssignmentCountForEmployee(employee.id), 1);
    expect(state.parallelEfficiencyForEmployee(employee.id), 1);

    state = engine.reduce(
      state,
      ApplyProductImprovement(
        productId: products[1].id,
        type: ProductImprovementType.performance,
      ),
    );

    expect(state.activeAssignmentCountForEmployee(employee.id), 2);
    expect(state.parallelEfficiencyForEmployee(employee.id), 0.70);
  });

  test('intern HR sources and hires every missing role at intern grade', () {
    var state = engine.reduce(
      GameState.initial().copyWith(cash: 100000000),
      const CreateConfiguredProduct(
        name: 'HR Project',
        blueprintId: 'company_website',
        frameworkId: 'static_web',
        languageIds: <String>['html_css'],
        technologyIds: <String>[],
        featureIds: <String>['landing_page'],
      ),
    );
    final hr = const Candidate(
      id: 'fixture_hr',
      name: 'Fixture HR',
      role: EmployeeRole.productManager,
      skill: 42,
      speed: 40,
      quality: 41,
      autonomy: 38,
      communication: 48,
      reliability: 44,
      salary: 80000,
      loyalty: 80,
      remote: true,
      isHr: true,
      grade: EmployeeGrade.intern,
    ).toEmployee();
    state = state.copyWith(
      employees: <Employee>[hr],
      candidates: const <Candidate>[],
    );
    final product = state.products.single;

    state = engine.reduce(state, AutoHireProjectTeam(product.id));

    final hires = state.employees
        .where((employee) => !employee.isHr)
        .toList(growable: false);
    expect(hires, isNotEmpty);
    expect(
      hires.every((employee) => employee.grade == EmployeeGrade.intern),
      isTrue,
    );
    for (final requirement in state.roleRequirementsFor(product)) {
      expect(
        state.assignedRoleCount(product.id, requirement.role),
        greaterThanOrEqualTo(requirement.minimumCount),
        reason: requirement.role.name,
      );
    }
  });

  test(
    'employee productivity exposes visible positive and negative factors',
    () {
      final base = GameState.initial();
      final employee = base.candidates
          .firstWhere((candidate) => !candidate.isHr)
          .toEmployee()
          .managedCopyWith(morale: 92, workload: 35);
      final state = base.copyWith(employees: <Employee>[employee]);

      expect(state.employeeProductivityPercent(employee), greaterThan(0));
      expect(
        state.employeeProductivityFactors(employee).join(' '),
        contains('Высокая мораль'),
      );
      expect(
        state.employeeProductivityFactors(employee).join(' '),
        contains('Нагрузка без штрафа'),
      );
    },
  );

  test('late-game server catalog adds stronger and cheaper compute tiers', () {
    final edge = GameCatalog.serverHardwareById('edge_s1');
    final superPod = GameCatalog.serverHardwareById('ai_superpod_p96');
    final dense = GameCatalog.serverHardwareById('dense_cluster_x48');

    expect(superPod.computeUnits, greaterThan(70000));
    expect(dense.computeUnits, greaterThan(25000));
    expect(
      superPod.purchaseCost / superPod.computeUnits,
      lessThan(edge.purchaseCost / edge.computeUnits),
    );
  });

  test('business credit always returns an explicit result', () {
    final refused = engine.reduce(
      GameState.initial(),
      const RequestBusinessLoan(),
    );
    expect(refused.activeLoan, isNull);
    expect(refused.feed.first, contains('Банк отказал'));

    var eligible = engine.reduce(
      GameState.initial().copyWith(cash: 1000000),
      const CreateConfiguredProduct(
        name: 'Credit Proof',
        blueprintId: 'company_website',
        frameworkId: 'static_web',
        languageIds: <String>['html_css'],
        technologyIds: <String>[],
        featureIds: <String>['landing_page'],
      ),
    );
    eligible = engine.reduce(eligible, const RequestBusinessLoan());
    expect(eligible.activeLoan, isNotNull);
    expect(eligible.feed.first, contains('одобрен'));
  });
}
