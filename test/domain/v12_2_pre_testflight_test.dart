import 'package:flutter_test/flutter_test.dart';
import 'package:founder_os/domain/commands/game_action.dart';
import 'package:founder_os/domain/entities/game_state.dart';
import 'package:founder_os/domain/entities/models.dart';
import 'package:founder_os/domain/entities/operations_models.dart';
import 'package:founder_os/domain/entities/v12_game_state_extensions.dart';
import 'package:founder_os/domain/entities/v12_models.dart';
import 'package:founder_os/domain/simulation/engine/game_engine.dart';

void main() {
  const engine = GameEngine();

  test(
    'configured CEO contributes to the total visible development capacity',
    () {
      var state = _configuredCompany();
      state = _website(state);
      final product = state.products.single;

      expect(state.employeesForProduct(product.id), isEmpty);
      expect(state.founderDevelopmentCapacityFor(product), greaterThan(0));
      expect(
        state.totalDevelopmentCapacityFor(product),
        greaterThan(state.productDevelopmentCapacity(product.id)),
      );
    },
  );

  test(
    'parallel employee efficiency is deterministic from one to four works',
    () {
      var state = _configuredCompany().copyWith(
        cash: 10000000,
        selectedOfficeId: 'garage',
      );
      final candidate = state.candidates.firstWhere((item) => !item.isHr);
      state = engine.reduce(state, HireCandidate(candidate.id));
      expect(state.employeeById(candidate.id), isNotNull);

      GameState withAssignments(int count) => state.copyWith(
        employeeAssignments: <EmployeeAssignment>[
          for (var index = 0; index < count; index += 1)
            EmployeeAssignment(
              employeeId: candidate.id,
              productId: 'parallel_product_$index',
              assignedAtMinutes: index,
            ),
        ],
      );

      expect(withAssignments(1).parallelEfficiencyForEmployee(candidate.id), 1);
      expect(
        withAssignments(2).parallelEfficiencyForEmployee(candidate.id),
        0.70,
      );
      expect(
        withAssignments(3).parallelEfficiencyForEmployee(candidate.id),
        0.55,
      );
      expect(
        withAssignments(4).parallelEfficiencyForEmployee(candidate.id),
        0.40,
      );
      expect(
        withAssignments(4).canAssignEmployeeToMoreWork(candidate.id),
        isFalse,
      );
    },
  );

  test(
    'contract acceptance auto assigns matching roles and reaches full coverage',
    () {
      var state = _configuredCompany().copyWith(
        cash: 10000000,
        selectedOfficeId: 'garage',
      );
      state = _website(state);
      final created = state.products.single;
      state = state.copyWith(
        products: <Product>[
          created.copyWith(stage: ProductStage.live, developmentProgress: 1),
        ],
      );

      final frontend = state.candidates.firstWhere(
        (item) => item.role == EmployeeRole.frontend && !item.isHr,
      );
      final designer = state.candidates.firstWhere(
        (item) => item.role == EmployeeRole.designer && !item.isHr,
      );
      state = engine.reduce(state, HireCandidate(frontend.id));
      state = engine.reduce(state, HireCandidate(designer.id));

      state = engine.reduce(
        state,
        const AcceptClientContract('landing_launch'),
      );

      expect(state.activeContracts, hasLength(1));
      final contract = state.activeContracts.single;
      final team = state.employeesForContract(contract.id);
      expect(team.map((item) => item.role), contains(EmployeeRole.frontend));
      expect(team.map((item) => item.role), contains(EmployeeRole.designer));
      expect(state.contractRoleCoverageFor(contract.id), 1);
    },
  );

  test(
    'project challenge grants thirty percent of stage once for the project',
    () {
      var state = _website(_configuredCompany());
      final created = state.products.single;
      state = state.copyWith(
        products: <Product>[created.copyWith(developmentProgress: 0.45)],
      );
      final product = state.products.single;
      final stage = state.founderStageFor(product);

      expect(stage, FounderDevelopmentStage.implementation);
      expect(state.projectChallengeEligible(product), isTrue);

      final first = engine.reduce(
        state,
        CompleteDevelopmentChallenge(
          productId: product.id,
          stage: stage,
          correct: true,
        ),
      );
      expect(first.products.single.developmentProgress, closeTo(0.582, 0.0001));
      expect(first.projectChallengeHandled(first.products.single), isTrue);

      final second = engine.reduce(
        first,
        CompleteDevelopmentChallenge(
          productId: product.id,
          stage: stage,
          correct: true,
        ),
      );
      expect(
        second.products.single.developmentProgress,
        first.products.single.developmentProgress,
      );
    },
  );
}

GameState _configuredCompany() {
  const engine = GameEngine();
  return engine
      .reduce(
        GameState.initial(),
        const ConfigureCompany(
          companyName: 'Preflight Labs',
          founderName: 'Алекс',
          logoId: 'company_logo_01',
          startingBudget: 1200000,
          background: FounderBackground.engineer,
          skills: <FounderSkill, int>{
            FounderSkill.engineering: 4,
            FounderSkill.design: 2,
            FounderSkill.product: 2,
            FounderSkill.growth: 1,
            FounderSkill.negotiation: 1,
            FounderSkill.operations: 2,
          },
        ),
      )
      .copyWith(onboardingCompleted: true);
}

GameState _website(GameState state) {
  const engine = GameEngine();
  return engine.reduce(
    state,
    const CreateConfiguredProduct(
      name: 'Preflight Site',
      blueprintId: 'company_website',
      frameworkId: 'static_web',
      languageIds: <String>['html_css'],
      technologyIds: <String>[],
      featureIds: <String>['landing_page'],
    ),
  );
}
