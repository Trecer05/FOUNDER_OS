import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:founder_os/domain/commands/game_action.dart';
import 'package:founder_os/domain/entities/game_state.dart';
import 'package:founder_os/domain/entities/models.dart';
import 'package:founder_os/domain/entities/product_evolution_models.dart';
import 'package:founder_os/domain/entities/product_strategy_models.dart';
import 'package:founder_os/domain/entities/v12_game_state_extensions.dart';
import 'package:founder_os/domain/entities/v12_models.dart';
import 'package:founder_os/domain/simulation/engine/game_engine.dart';

void main() {
  const engine = GameEngine();

  test('new company is unconfigured and starts without an office bill', () {
    final state = GameState.initial();

    expect(state.snapshotVersion, 16);
    expect(state.companyProfile.configured, isFalse);
    expect(state.selectedOfficeId, 'remote_first');
    expect(state.office.monthlyRent, 0);
    expect(state.office.capacity, 0);
    expect(state.monthlyOfficeCost, 0);
  });

  test(
    'company setup persists name budget logo background and fixed skills',
    () {
      var state = GameState.initial();
      state = engine.reduce(
        state,
        const ConfigureCompany(
          companyName: 'Orbit Works',
          founderName: 'Alex',
          logoId: 'company_logo_17',
          startingBudget: 750000,
          background: FounderBackground.engineer,
          skills: <FounderSkill, int>{
            FounderSkill.engineering: 7,
            FounderSkill.design: 3,
            FounderSkill.product: 4,
            FounderSkill.growth: 2,
            FounderSkill.negotiation: 2,
            FounderSkill.operations: 4,
          },
        ),
      );

      expect(state.companyProfile.configured, isTrue);
      expect(state.companyProfile.companyName, 'Orbit Works');
      expect(state.companyProfile.founderName, 'Alex');
      expect(state.companyProfile.logoId, 'company_logo_17');
      expect(state.companyProfile.hasValidSkillBudget, isTrue);
      expect(state.cash, 750000);
      expect(state.selectedOfficeId, 'remote_first');

      final restored = GameState.decode(state.encode());
      expect(restored.companyProfile.companyName, 'Orbit Works');
      expect(restored.companyProfile.founderName, 'Alex');
      expect(restored.companyProfile.background, FounderBackground.engineer);
      expect(restored.companyProfile.skills, state.companyProfile.skills);
    },
  );

  test('invalid founder point budget is rejected', () {
    final state = GameState.initial();
    final rejected = engine.reduce(
      state,
      const ConfigureCompany(
        companyName: 'Too Skilled',
        founderName: 'Alex',
        logoId: 'company_logo_01',
        startingBudget: 450000,
        background: FounderBackground.product,
        skills: <FounderSkill, int>{
          FounderSkill.engineering: 5,
          FounderSkill.design: 5,
          FounderSkill.product: 5,
          FounderSkill.growth: 5,
          FounderSkill.negotiation: 5,
          FounderSkill.operations: 5,
        },
      ),
    );

    expect(rejected.companyProfile.configured, isFalse);
    expect(rejected.cash, state.cash);
  });

  test('configured founder can advance a product without employees', () {
    var state = _configured();
    state = _website(state);
    final before = state.products.single.developmentProgress;
    expect(state.employees, isEmpty);
    expect(
      state.founderDevelopmentCapacityFor(state.products.single),
      greaterThan(0),
    );

    state = state.copyWith(paused: false);
    state = engine.reduce(state, const AdvanceTime(3600));

    expect(state.products.single.developmentProgress, greaterThan(before));
    expect(state.employees, isEmpty);
  });

  test('HR auto-hire fills exact minimum headcount and no spare roles', () {
    var state = _configured(budget: 1200000);
    state = _website(state);
    final hrId = state.candidates.singleWhere((candidate) => candidate.isHr).id;
    state = engine.reduce(state, HireCandidate(hrId));
    final product = state.products.single;
    final required = state
        .roleRequirementsFor(product)
        .fold<int>(0, (sum, item) => sum + item.minimumCount);

    state = engine.reduce(state, AutoHireProjectTeam(product.id));

    final assignedNonHr = state
        .employeesForProduct(product.id)
        .where((employee) => !employee.isHr)
        .toList(growable: false);

    expect(assignedNonHr.length, required);
    for (final requirement in state.roleRequirementsFor(product)) {
      expect(
        state.assignedRoleCount(product.id, requirement.role),
        requirement.minimumCount,
      );
    }
    expect(state.employeeById(hrId)?.isHr, isTrue);
  });

  test('auto-hire without HR cannot mutate employees', () {
    var state = _configured(budget: 1200000);
    state = _website(state);
    final product = state.products.single;
    final before = state.employees.length;

    state = engine.reduce(state, AutoHireProjectTeam(product.id));

    expect(state.employees.length, before);
    expect(state.feed.first, contains('HR / People Partner'));
  });

  test(
    'malformed legacy improvement no longer throws Bad state No element',
    () {
      var state = _configured(budget: 1200000);
      state = _website(state);
      final product = state.products.single;
      state = state.copyWith(
        paused: false,
        products: <Product>[
          product.copyWith(
            stage: ProductStage.live,
            developmentProgress: 1,
            allocatedCapacityPercent: 30,
          ),
        ],
        productFeatureDevelopments: <ProductFeatureDevelopment>[
          ProductFeatureDevelopment(
            productId: product.id,
            featureId: '__improvement_removed_legacy_type_1',
            startedAtMinutes: state.simulationMinutes,
            requiredHours: 0.01,
            progress: 0.999,
          ),
        ],
      );

      expect(
        () => engine.reduce(state, const AdvanceTime(300)),
        returnsNormally,
      );
      final next = engine.reduce(state, const AdvanceTime(300));
      expect(next.productFeatureDevelopments, isEmpty);
    },
  );

  test('founder economic skills reduce real recurring and hiring costs', () {
    var skilled = _configured(budget: 1200000);
    skilled = engine.reduce(skilled, const RentOffice('coworking'));
    final rawOfficeRent = skilled.office.monthlyRent;
    expect(skilled.monthlyOfficeCost, lessThan(rawOfficeRent));

    final candidate = skilled.candidates.firstWhere((item) => !item.isHr);
    final beforeCash = skilled.cash;
    skilled = engine.reduce(skilled, HireCandidate(candidate.id));
    final charged = beforeCash - skilled.cash;
    expect(charged, lessThan(candidate.salary * 0.15));
    expect(
      skilled.employeeById(candidate.id)!.salary,
      lessThan(candidate.salary),
    );
  });

  test(
    'founder can finish post-release technical improvement without staff',
    () {
      var state = _configured(budget: 1200000);
      state = _website(state);
      final product = state.products.single;
      state = state.copyWith(
        products: <Product>[
          product.copyWith(stage: ProductStage.live, developmentProgress: 1),
        ],
      );
      state = engine.reduce(
        state,
        ApplyProductImprovement(
          productId: product.id,
          type: ProductImprovementType.performance,
        ),
      );
      expect(state.employees, isEmpty);
      expect(state.productFeatureDevelopments, hasLength(1));
      final before = state.productFeatureDevelopments.single.progress;

      state = state.copyWith(paused: false);
      state = engine.reduce(state, const AdvanceTime(3600));

      expect(
        state.productFeatureDevelopments.isEmpty ||
            state.productFeatureDevelopments.single.progress > before,
        isTrue,
      );
    },
  );

  test('growth skill improves advertising conversion forecast', () {
    var skilled = _configured(budget: 1200000);
    skilled = _website(skilled);
    final product = skilled.products.single.copyWith(
      stage: ProductStage.live,
      developmentProgress: 1,
      users: 5000,
      mau: 3000,
      dau: 500,
      activationRate: 0.4,
      retention30d: 0.5,
      qualityScore: 75,
      reliability: 0.99,
    );
    skilled = skilled.copyWith(products: <Product>[product]);

    final neutral = skilled.copyWith(
      companyProfile: FounderCompanyProfile.unconfigured(),
    );
    final skilledForecast = skilled.advertisingForecast(
      product: product,
      agencyId: 'freelance_ads',
      channelId: 'search_ads',
      budget: 100000,
    );
    final neutralForecast = neutral.advertisingForecast(
      product: product,
      agencyId: 'freelance_ads',
      channelId: 'search_ads',
      budget: 100000,
    );

    expect(skilled.founderGrowthMultiplier, greaterThan(1));
    expect(
      skilledForecast.usersExpected,
      greaterThanOrEqualTo(neutralForecast.usersExpected),
    );
  });

  test('development challenge is rewarded at most once per project', () {
    var state = _configured();
    state = _website(state);
    final original = state.products.single;
    state = state.copyWith(
      products: <Product>[original.copyWith(developmentProgress: 0.45)],
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
    final progress = first.products.single.developmentProgress;
    final second = engine.reduce(
      first,
      CompleteDevelopmentChallenge(
        productId: product.id,
        stage: stage,
        correct: true,
      ),
    );

    expect(progress, closeTo(0.582, 0.0001));
    expect(second.products.single.developmentProgress, progress);
    expect(first.projectChallengeHandled(first.products.single), isTrue);
  });

  test('v11 snapshot migrates founder profile and automatic garage safely', () {
    final source = GameState.initial().copyWith(
      companyProfile: FounderCompanyProfile.legacy(),
      selectedOfficeId: 'garage',
    );
    final json = jsonDecode(source.encode()) as Map<String, dynamic>;
    json['snapshotVersion'] = 11;
    json.remove('companyProfile');

    final migrated = GameState.decode(jsonEncode(json));

    expect(migrated.snapshotVersion, 16);
    expect(migrated.companyProfile.configured, isTrue);
    expect(migrated.selectedOfficeId, 'remote_first');
  });
}

GameState _configured({double budget = 750000}) {
  const engine = GameEngine();
  return engine.reduce(
    GameState.initial(),
    ConfigureCompany(
      companyName: 'Test Labs',
      founderName: 'Alex',
      logoId: 'company_logo_01',
      startingBudget: budget,
      background: FounderBackground.engineer,
      skills: const <FounderSkill, int>{
        FounderSkill.engineering: 7,
        FounderSkill.design: 3,
        FounderSkill.product: 4,
        FounderSkill.growth: 2,
        FounderSkill.negotiation: 2,
        FounderSkill.operations: 4,
      },
    ),
  );
}

GameState _website(GameState state) {
  const engine = GameEngine();
  return engine.reduce(
    state,
    const CreateConfiguredProduct(
      name: 'Founder Site',
      blueprintId: 'company_website',
      frameworkId: 'static_web',
      languageIds: <String>['html_css'],
      technologyIds: <String>[],
      featureIds: <String>['landing_page'],
    ),
  );
}
