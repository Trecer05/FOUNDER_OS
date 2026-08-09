import 'package:flutter_test/flutter_test.dart';
import 'package:founder_os/domain/catalog/contract_catalog.dart';
import 'package:founder_os/domain/commands/game_action.dart';
import 'package:founder_os/domain/entities/business_models.dart';
import 'package:founder_os/domain/entities/game_state.dart';
import 'package:founder_os/domain/entities/management_models.dart';
import 'package:founder_os/domain/entities/models.dart';
import 'package:founder_os/domain/entities/product_evolution_models.dart';
import 'package:founder_os/domain/simulation/engine/game_engine.dart';

void main() {
  const engine = GameEngine();

  test('same seed and actions produce exactly the same state', () {
    final deterministicCandidateId = GameState.initial().candidates.first.id;
    final actions = <GameAction>[
      _configuredProduct(
        name: 'Nova',
        blueprintId: 'ai_assistant',
        frameworkId: 'fastapi_react',
        featureIds: const <String>['chat_history', 'file_analysis'],
      ),
      HireCandidate(deterministicCandidateId),
      const TogglePause(),
      const AdvanceTime(60),
      const SetGameSpeed(GameSpeed.x4),
      const AdvanceTime(30),
    ];

    GameState run() {
      var state = _fundedInitial();
      for (final action in actions) {
        state = engine.reduce(state, action);
      }
      return state;
    }

    expect(run().encode(), equals(run().encode()));
  });

  test('candidate hiring respects numeric office capacity', () {
    var state = _fundedInitial().copyWith(selectedOfficeId: 'garage');
    final onSite = state.candidates.where((item) => !item.remote).take(4).toList();
    expect(onSite, hasLength(4));
    for (final candidate in onSite.take(3)) {
      state = engine.reduce(state, HireCandidate(candidate.id));
    }
    final blockedCandidate = onSite[3];
    final fullOffice = engine.reduce(state, HireCandidate(blockedCandidate.id));

    expect(state.onSiteEmployeeCount, 3);
    expect(fullOffice.onSiteEmployeeCount, 3);
    expect(fullOffice.candidateById(blockedCandidate.id), isNotNull);
    expect(fullOffice.office.capacity, 3);
  });

  test(
    'ecosystem supports many links, rejects duplicates and keeps products',
    () {
      var state = _fundedInitial().copyWith(
        cash: 10000000,
        selectedOfficeId: 'garage',
      );
      state = engine.reduce(
        state,
        _configuredProduct(
          name: 'Nova',
          blueprintId: 'ai_assistant',
          frameworkId: 'fastapi_react',
          featureIds: const <String>['chat_history', 'file_analysis'],
        ),
      );
      state = engine.reduce(
        state,
        _configuredProduct(
          name: 'Orbit',
          blueprintId: 'cloud_platform',
          frameworkId: 'go_microservices',
          featureIds: const <String>['autoscaling', 'monitoring'],
        ),
      );
      state = engine.reduce(
        state,
        _configuredProduct(
          name: 'Flow',
          blueprintId: 'team_saas',
          frameworkId: 'next_nest',
          featureIds: const <String>['realtime_collaboration', 'automation'],
        ),
      );

      final integrationSpecialist = state.candidates.firstWhere(
        (candidate) =>
            candidate.remote &&
            (candidate.role == EmployeeRole.backend ||
                candidate.role == EmployeeRole.devOps),
      );
      state = engine.reduce(
        state,
        HireCandidate(integrationSpecialist.id),
      );

      final ai = state.products[0];
      final cloud = state.products[1];
      final saas = state.products[2];
      state = engine.reduce(
        state,
        ConnectProducts(firstProductId: ai.id, secondProductId: cloud.id),
      );
      state = engine.reduce(
        state,
        ConnectProducts(firstProductId: ai.id, secondProductId: saas.id),
      );
      final duplicate = engine.reduce(
        state,
        ConnectProducts(firstProductId: cloud.id, secondProductId: ai.id),
      );
      final activationAt = state.ecosystemLinks
          .map((link) => link.activeAtMinutes)
          .reduce((left, right) => left > right ? left : right);
      final activated = state.copyWith(simulationMinutes: activationAt);

      expect(state.ecosystemLinks, hasLength(2));
      expect(duplicate.ecosystemLinks, hasLength(2));
      expect(state.connectedProductIds(ai.id), hasLength(2));
      expect(activated.ecosystemBoostFor(ai.id), closeTo(0.07, 0.0001));
      expect(state.products.map((item) => item.id).toSet(), hasLength(3));
    },
  );

  test('product roadmap queues work hours without direct feature purchase', () {
    var state = _fundedInitial().copyWith(cash: 10000000);
    state = engine.reduce(
      state,
      _configuredProduct(
        name: 'Nova',
        blueprintId: 'ai_assistant',
        frameworkId: 'fastapi_react',
        featureIds: const <String>['chat_history'],
      ),
    );
    final created = state.products.single;
    state = state.copyWith(
      products: <Product>[
        created.copyWith(stage: ProductStage.live, developmentProgress: 1),
      ],
    );
    final cashBefore = state.cash;

    state = engine.reduce(
      state,
      AddProductFeature(productId: created.id, featureId: 'file_analysis'),
    );

    expect(
      state.productById(created.id)!.featureIds,
      isNot(contains('file_analysis')),
    );
    expect(state.activeFeatureDevelopmentFor(created.id), isNotNull);
    expect(
      state.activeFeatureDevelopmentFor(created.id)!.requiredHours,
      greaterThan(0),
    );
    expect(state.cash, cashBefore);
  });

  test(
    'market rewards product advantage even when weaker rival spends on ads',
    () {
      var state = _fundedInitial().copyWith(cash: 20000000);
      state = engine.reduce(
        state,
        _configuredProduct(
          name: 'Complete AI',
          blueprintId: 'ai_assistant',
          frameworkId: 'fastapi_react',
          featureIds: const <String>[
            'chat_history',
            'file_analysis',
            'web_search',
            'team_spaces',
          ],
        ),
      );
      state = engine.reduce(
        state,
        _configuredProduct(
          name: 'Ad-only AI',
          blueprintId: 'ai_assistant',
          frameworkId: 'flutter_firebase',
          featureIds: const <String>['chat_history'],
        ),
      );
      final strongId = state.products[0].id;
      final weakId = state.products[1].id;
      state = state.copyWith(
        paused: false,
        products: state.products
            .map(
              (product) => product.copyWith(
                stage: ProductStage.live,
                developmentProgress: 1,
                users: 1000,
                mau: 700,
                dau: 180,
                allocatedCapacityPercent: 50,
                marketingBudget: product.id == weakId ? 800000 : 0,
              ),
            )
            .toList(growable: false),
      );
      state = engine.reduce(state, const AdvanceTime(300));

      final strong = state.productById(strongId)!;
      final weak = state.productById(weakId)!;
      expect(strong.featureCoverage, greaterThan(weak.featureCoverage));
      expect(strong.activationRate, greaterThan(weak.activationRate));
      expect(strong.retention30d, greaterThan(weak.retention30d));
    },
  );

  test(
    'investor counters one million request with available five hundred thousand',
    () {
      var state = _fundedInitial().copyWith(cash: 10000000);

      state = engine.reduce(
        state,
        _configuredProduct(
          name: 'Nova',
          blueprintId: 'ai_assistant',
          frameworkId: 'fastapi_react',
          featureIds: const <String>[
            'chat_history',
            'file_analysis',
            'web_search',
          ],
        ),
      );

      final product = state.products.single;

      state = state.copyWith(
        products: <Product>[product.copyWith(developmentProgress: 0.5)],
      );

      state = engine.reduce(
        state,
        RequestInvestorFunding(
          investorId: 'inv_aurora',
          productId: product.id,
          requestedAmount: 1000000,
        ),
      );

      expect(state.investorOffers, hasLength(1));
      expect(state.investorOffers.single.requestedAmount, 1000000);
      expect(state.investorOffers.single.offeredAmount, lessThan(0));
      final decisionDays = int.parse(
        state.investorOffers.single.id.split('_').last,
      );

      state = state.copyWith(paused: false);
      state = engine.reduce(state, AdvanceTime(decisionDays * 360 + 1));

      expect(state.investorOffers, hasLength(1));
      expect(state.investorOffers.single.offeredAmount, 500000);
      state = engine.reduce(
        state,
        AcceptInvestorOffer(state.investorOffers.single.id),
      );

      expect(state.investorAgreements, hasLength(6));
      expect(state.founderOwnershipPercent, lessThan(100));
      expect(state.founderOwnershipPercent, greaterThan(50));
    },
  );

  test(
    'accepting a deal below fifty percent loses the company immediately',
    () {
      final offer = InvestorOffer(
        id: 'danger_offer',
        investorId: 'inv_frontier',
        productId: 'p',
        requestedAmount: 500000,
        offeredAmount: 500000,
        equityPercent: 3,
        revenueSharePercent: 2,
        createdAtMinutes: 0,
      );
      final state = _fundedInitial().copyWith(
        founderOwnershipPercent: 52,
        investorOffers: <InvestorOffer>[offer],
      );

      final next = engine.reduce(
        state,
        const AcceptInvestorOffer('danger_offer'),
      );

      expect(next.founderOwnershipPercent, 49);
      expect(next.gameOver, isTrue);
      expect(next.criticalEvent, CriticalEventType.lostControl);
    },
  );

  test(
    'strict allocation preserves old value when total would exceed 100%',
    () {
      var state = _fundedInitial().copyWith(cash: 10000000);
      state = engine.reduce(
        state,
        _configuredProduct(
          name: 'Nova',
          blueprintId: 'ai_assistant',
          frameworkId: 'fastapi_react',
          featureIds: const <String>['chat_history'],
        ),
      );
      state = engine.reduce(
        state,
        _configuredProduct(
          name: 'Orbit',
          blueprintId: 'cloud_platform',
          frameworkId: 'go_microservices',
          featureIds: const <String>['autoscaling'],
        ),
      );
      final first = state.products[0];
      final second = state.products[1];
      state = engine.reduce(
        state,
        SetProductAllocation(productId: second.id, percent: 10),
      );
      state = engine.reduce(
        state,
        SetProductAllocation(productId: first.id, percent: 90),
      );
      final rejected = engine.reduce(
        state,
        SetProductAllocation(productId: second.id, percent: 20),
      );

      expect(rejected.productById(second.id)!.allocatedCapacityPercent, 10);
      expect(rejected.totalAllocatedPercent, 100);
    },
  );

  test('server hardware is limited by rack power and cooling', () {
    var state = _fundedInitial().copyWith(cash: 10000000);
    final rejected = engine.reduce(state, const InstallServer('cluster_x12'));
    expect(rejected.installedCount('cluster_x12'), 0);
    expect(rejected.installedCount('edge_s1'), state.installedCount('edge_s1'));

    state = engine.reduce(state, const RentServerRoom('regional_dc'));
    state = engine.reduce(state, const InstallServer('cluster_x12'));
    expect(state.installedCount('cluster_x12'), 1);
    expect(state.infrastructureFitsRoom, isTrue);
  });

  test('acquired product migration requires prepared compute capacity', () {
    var state = _fundedInitial().copyWith(
      cash: 5000000000,
      selectedOfficeId: 'garage',
    );
    state = engine.reduce(
      state,
      _configuredProduct(
        name: 'Orbit',
        blueprintId: 'cloud_platform',
        frameworkId: 'go_microservices',
        featureIds: const <String>['autoscaling', 'monitoring'],
      ),
    );
    final targetId = state.products.single.id;
    state = state.copyWith(
      products: <Product>[
        state.products.single.copyWith(
          stage: ProductStage.live,
          developmentProgress: 1,
          users: 1200,
          mau: 800,
          dau: 180,
        ),
      ],
    );
    final blocked = engine.reduce(
      state,
      AcquireMarketProduct(
        companyId: 'm_orbit',
        mode: AcquisitionMode.migrateUsers,
        targetProductId: targetId,
      ),
    );
    expect(blocked.acquiredCompanyIds, isEmpty);

    state = engine.reduce(state, const RentServerRoom('regional_dc'));
    for (var index = 0; index < 19; index++) {
      state = engine.reduce(state, const InstallServer('cluster_x12'));
    }
    final devOps = state.candidates.firstWhere(
      (candidate) => candidate.role == EmployeeRole.devOps,
    );
    final security = state.candidates.firstWhere(
      (candidate) => candidate.role == EmployeeRole.security,
    );
    state = engine.reduce(state, HireCandidate(devOps.id));
    state = engine.reduce(state, HireCandidate(security.id));
    state = engine.reduce(state, const MigrateToOwnedInfrastructure());
    expect(state.usingOwnedInfrastructure, isTrue);
    state = engine.reduce(
      state,
      AcquireMarketProduct(
        companyId: 'm_orbit',
        mode: AcquisitionMode.migrateUsers,
        targetProductId: targetId,
      ),
    );
    expect(state.acquiredCompanyIds, contains('m_orbit'));
    expect(state.productById(targetId)!.users, greaterThan(0));
  });

  test('crypto wallet breach effectively kills the product', () {
    var state = _fundedInitial().copyWith(cash: 10000000);
    state = engine.reduce(
      state,
      _configuredProduct(
        name: 'Vaultline',
        blueprintId: 'crypto_wallet',
        frameworkId: 'rust_core',
        featureIds: const <String>['hardware_wallet', 'recovery'],
      ),
    );
    final wallet = state.products.single;
    state = state.copyWith(
      products: <Product>[
        wallet.copyWith(
          stage: ProductStage.live,
          developmentProgress: 1,
          users: 100000,
          mau: 70000,
          dau: 30000,
          monthlyRevenue: 900000,
        ),
      ],
    );
    state = engine.reduce(state, TriggerSecurityIncident(wallet.id));

    final attacked = state.productById(wallet.id)!;
    expect(attacked.stage, ProductStage.failed);
    expect(attacked.users, 8000);
    expect(attacked.monthlyRevenue, 0);
    expect(state.criticalEvent, CriticalEventType.securityBreach);
  });

  test('hardened crypto wallet survives a breach but takes heavy damage', () {
    var state = _fundedInitial().copyWith(cash: 20000000);
    state = engine.reduce(
      state,
      _configuredProduct(
        name: 'Vaultline',
        blueprintId: 'crypto_wallet',
        frameworkId: 'rust_core',
        featureIds: const <String>['hardware_wallet', 'recovery'],
      ),
    );
    final wallet = state.products.single;
    state = state.copyWith(
      products: <Product>[
        wallet.copyWith(
          stage: ProductStage.live,
          developmentProgress: 1,
          users: 100000,
          mau: 70000,
          dau: 30000,
          monthlyRevenue: 900000,
        ),
      ],
    );
    for (final controlId in const <String>[
      'kms_encryption',
      'backup_dr',
      'soc_response',
    ]) {
      state = engine.reduce(
        state,
        PurchaseSecurityControl(productId: wallet.id, controlId: controlId),
      );
    }

    state = engine.reduce(state, TriggerSecurityIncident(wallet.id));

    final attacked = state.productById(wallet.id)!;
    expect(attacked.stage, ProductStage.live);
    expect(attacked.users, 55000);
    expect(attacked.monthlyRevenue, greaterThan(0));
  });

  test(
    'employee parallel assignment applies seventy percent on two products',
    () {
      var state = _fundedInitial().copyWith(cash: 10000000);
      state = engine.reduce(
        state,
        _configuredProduct(
          name: 'Nova',
          blueprintId: 'ai_assistant',
          frameworkId: 'fastapi_react',
          featureIds: const <String>['chat_history', 'file_analysis'],
        ),
      );
      state = engine.reduce(
        state,
        _configuredProduct(
          name: 'Orbit',
          blueprintId: 'cloud_platform',
          frameworkId: 'go_microservices',
          featureIds: const <String>['autoscaling', 'monitoring'],
        ),
      );
      final candidateId = state.candidates
          .firstWhere(
            (candidate) =>
                candidate.remote && candidate.role == EmployeeRole.backend,
          )
          .id;
      state = engine.reduce(state, HireCandidate(candidateId));
      final firstId = state.products[0].id;
      final secondId = state.products[1].id;

      final founderOnlyCapacity = state.productDevelopmentCapacity(firstId);
      expect(founderOnlyCapacity, greaterThan(0));
      state = engine.reduce(
        state,
        AssignEmployeeToProduct(employeeId: candidateId, productId: firstId),
      );

      expect(state.employeesForProduct(firstId), hasLength(1));
      expect(
        state.productDevelopmentCapacity(firstId),
        greaterThan(founderOnlyCapacity),
      );
      expect(state.employeesForProduct(secondId), isEmpty);

      state = engine.reduce(
        state,
        AssignEmployeeToProduct(employeeId: candidateId, productId: secondId),
      );
      expect(state.employeesForProduct(firstId), hasLength(1));
      expect(state.employeesForProduct(secondId), hasLength(1));
      expect(state.assignmentsForEmployee(candidateId), hasLength(2));
      expect(state.employeeAllocationForProduct(candidateId, firstId), 70);
      expect(state.employeeAllocationForProduct(candidateId, secondId), 70);
    },
  );

  test('training and raise change exact employee metrics and payroll', () {
    var state = _fundedInitial().copyWith(cash: 10000000);
    final candidateId = state.candidates
        .firstWhere((candidate) => candidate.remote && !candidate.isHr)
        .id;
    state = engine.reduce(state, HireCandidate(candidateId));
    final before = state.employeeById(candidateId)!;
    final cashBefore = state.cash;

    state = engine.reduce(
      state,
      TrainEmployee(employeeId: candidateId, programId: 'security'),
    );
    final trained = state.employeeById(candidateId)!;
    expect(trained.skill, before.skill + 4);
    expect(trained.reliability, before.reliability + 6);
    expect(state.cash, cashBefore - 110000);

    final salaryBefore = trained.salary;
    state = engine.reduce(
      state,
      GiveEmployeeRaise(employeeId: candidateId, percent: 10),
    );
    expect(
      state.employeeById(candidateId)!.salary,
      closeTo(salaryBefore * 1.1, 0.01),
    );
  });

  test('security controls reduce incident risk and audit is persisted', () {
    var state = _fundedInitial().copyWith(cash: 10000000);
    state = engine.reduce(
      state,
      _configuredProduct(
        name: 'Vaultline',
        blueprintId: 'crypto_wallet',
        frameworkId: 'rust_core',
        featureIds: const <String>['hardware_wallet', 'recovery'],
      ),
    );
    final product = state.products.single;
    final riskBefore = state.productSecurityRisk(product);

    state = engine.reduce(
      state,
      PurchaseSecurityControl(
        productId: product.id,
        controlId: 'kms_encryption',
      ),
    );
    state = engine.reduce(
      state,
      PurchaseSecurityControl(productId: product.id, controlId: 'soc_response'),
    );

    expect(state.securityControls, hasLength(2));
    expect(state.productIncidentMultiplier(product.id), lessThan(0.4));
    expect(state.productSecurityRisk(product), lessThan(riskBefore));
    expect(state.monthlySecurityCost, 338000);

    state = engine.reduce(state, RunSecurityAudit(product.id));
    expect(state.securityAudits, hasLength(1));
    expect(state.latestAuditFor(product.id), isNotNull);
  });

  test('product role requirements expose deterministic coverage', () {
    var state = _fundedInitial().copyWith(
      cash: 10000000,
      selectedOfficeId: 'garage',
    );
    state = engine.reduce(
      state,
      _configuredProduct(
        name: 'Nova',
        blueprintId: 'ai_assistant',
        frameworkId: 'fastapi_react',
        featureIds: const <String>['chat_history', 'file_analysis'],
      ),
    );
    final productId = state.products.single.id;
    expect(state.productRoleCoverage(productId), 0);
    expect(state.missingRoleRequirements(productId), isNotEmpty);

    final aiCandidate = state.candidates.firstWhere(
      (candidate) => candidate.role == EmployeeRole.aiMl,
    );
    state = engine.reduce(state, HireCandidate(aiCandidate.id));
    state = engine.reduce(
      state,
      AssignEmployeeToProduct(employeeId: aiCandidate.id, productId: productId),
    );

    expect(state.assignedRoleCount(productId, EmployeeRole.aiMl), 1);
    expect(state.productRoleCoverage(productId), greaterThan(0));
    expect(state.productRoleCoverage(productId), lessThan(1));
  });

  test('corporate AI boosts product and adds compute plus OPEX', () {
    var state = _fundedInitial().copyWith(cash: 20000000);

    state = engine.reduce(
      state,
      _configuredProduct(
        name: 'Core AI',
        blueprintId: 'ai_assistant',
        frameworkId: 'fastapi_react',
        featureIds: const <String>['chat_history', 'file_analysis'],
      ),
    );

    state = engine.reduce(
      state,
      _configuredProduct(
        name: 'Desk',
        blueprintId: 'team_saas',
        frameworkId: 'flutter_firebase',
        featureIds: const <String>['team_spaces', 'automation'],
      ),
    );

    final ai = state.products[0];
    final target = state.products[1];

    state = state.copyWith(
      products: <Product>[
        ai.copyWith(stage: ProductStage.live, developmentProgress: 1),
        target,
      ],
    );

    final publicMonthlyCost = state.productById(ai.id)!.monthlyCost;

    state = engine.reduce(
      state,
      SetProductMarketingBudget(productId: ai.id, monthlyBudget: 300000),
    );

    // В v8 общий рекламный бюджет отключён:
    // реклама запускается отдельными кампаниями.
    expect(state.productById(ai.id)!.marketingBudget, 0);
    expect(
      state.productById(ai.id)!.monthlyCost,
      closeTo(publicMonthlyCost, 0.01),
    );

    final capacityBefore = state.productDevelopmentCapacity(target.id);
    final demandBefore = state.productComputeDemand(state.productById(ai.id)!);

    state = engine.reduce(
      state,
      SetAiDeploymentMode(productId: ai.id, mode: AiDeploymentMode.corporate),
    );

    expect(state.productById(ai.id)!.marketingBudget, 0);
    expect(
      state.productById(ai.id)!.monthlyCost,
      closeTo(publicMonthlyCost, 0.01),
    );

    state = engine.reduce(
      state,
      ConnectCorporateAi(aiProductId: ai.id, targetProductId: target.id),
    );

    expect(state.corporateAiForTarget(target.id)?.id, ai.id);
    expect(
      state.productDevelopmentCapacity(target.id),
      greaterThan(capacityBefore),
    );
    expect(state.productAiQualityBoost(target.id), 4);
    expect(state.monthlyCorporateAiCost, 45000);
    expect(
      state.productComputeDemand(state.productById(ai.id)!),
      greaterThan(demandBefore),
    );

    state = engine.reduce(
      state,
      SetAiDeploymentMode(
        productId: ai.id,
        mode: AiDeploymentMode.publicMarket,
      ),
    );

    expect(state.corporateAiForTarget(target.id), isNull);
    expect(state.productAiIntegrations, isEmpty);
  });

  test('stale product queues repeatable update without upfront cash', () {
    var state = _fundedInitial().copyWith(cash: 10000000);
    state = engine.reduce(
      state,
      _configuredProduct(
        name: 'Desk',
        blueprintId: 'team_saas',
        frameworkId: 'flutter_firebase',
        featureIds: const <String>['team_spaces', 'automation'],
      ),
    );
    final product = state.products.single;
    state = state.copyWith(
      products: <Product>[
        product.copyWith(stage: ProductStage.live, developmentProgress: 1),
      ],
      simulationMinutes: state.simulationMinutes + 50 * 1440,
    );
    expect(state.productFreshnessScore(product), lessThan(70));
    final cashBefore = state.cash;

    state = engine.reduce(
      state,
      ApplyProductImprovement(
        productId: product.id,
        type: ProductImprovementType.performance,
      ),
    );

    expect(state.cash, cashBefore);
    expect(
      state.improvementLevel(product.id, ProductImprovementType.performance),
      0,
    );
    expect(state.activeFeatureDevelopmentFor(product.id), isNotNull);
    expect(
      state.activeFeatureDevelopmentFor(product.id)!.featureId,
      startsWith('__improvement_performance_'),
    );
  });

  test('new product starts at zero percent development', () {
    const engine = GameEngine();

    final state = engine.reduce(
      _fundedInitial().copyWith(cash: 10000000),
      const CreateConfiguredProduct(
        name: 'Zero Start',
        blueprintId: 'team_saas',
        frameworkId: 'flutter_firebase',
        languageIds: <String>['dart'],
        technologyIds: <String>['postgresql'],
        featureIds: <String>['realtime_collaboration'],
      ),
    );

    expect(state.products, hasLength(1));
    expect(state.products.single.developmentProgress, 0);
  });

  test('remote candidate can be hired when office seats are full', () {
    const engine = GameEngine();
    var state = _fundedInitial().copyWith(cash: 10000000);
    final onSiteCandidates = state.candidates
        .where((item) => !item.remote)
        .take(state.office.capacity);
    for (final candidate in onSiteCandidates) {
      state = engine.reduce(state, HireCandidate(candidate.id));
    }
    expect(state.onSiteEmployeeCount, state.office.capacity);
    final remoteCandidate = state.candidates.firstWhere((item) => item.remote);
    state = engine.reduce(state, HireCandidate(remoteCandidate.id));
    expect(state.employeeById(remoteCandidate.id), isNotNull);
    expect(state.remoteEmployeeCount, 1);
  });

  test('continuous improvements are blocked before launch', () {
    const engine = GameEngine();

    var state = engine.reduce(
      _fundedInitial().copyWith(cash: 10000000),
      const CreateConfiguredProduct(
        name: 'Prelaunch',
        blueprintId: 'team_saas',
        frameworkId: 'flutter_firebase',
        languageIds: <String>['dart'],
        technologyIds: <String>['postgresql'],
        featureIds: <String>['realtime_collaboration'],
      ),
    );

    expect(state.products, hasLength(1));

    final productId = state.products.single.id;
    final cash = state.cash;

    state = engine.reduce(
      state,
      ApplyProductImprovement(
        productId: productId,
        type: ProductImprovementType.performance,
      ),
    );

    expect(
      state.improvementLevel(productId, ProductImprovementType.performance),
      0,
    );
    expect(state.cash, cash);
  });

  test('subscription price is configurable only after launch', () {
    const engine = GameEngine();

    var state = engine.reduce(
      _fundedInitial().copyWith(cash: 10000000),
      const CreateConfiguredProduct(
        name: 'Pricing',
        blueprintId: 'team_saas',
        frameworkId: 'flutter_firebase',
        languageIds: <String>['dart'],
        technologyIds: <String>['postgresql'],
        featureIds: <String>['realtime_collaboration'],
      ),
    );

    expect(state.products, hasLength(1));

    final id = state.products.single.id;
    final initialPrice = state.products.single.price;

    state = engine.reduce(state, SetProductPrice(productId: id, price: 1500));

    expect(state.products.single.price, initialPrice);

    state = state.copyWith(
      products: <Product>[
        state.products.single.copyWith(
          stage: ProductStage.live,
          developmentProgress: 1,
        ),
      ],
    );

    state = engine.reduce(state, SetProductPrice(productId: id, price: 1500));

    expect(state.products.single.price, 1500);
  });

  test('client contract pays upfront and finishes through simulation', () {
    const engine = GameEngine();

    var state = _fundedInitial().copyWith(cash: 1000000, paused: false);

    state = _withReleasedWebsite(state, engine);

    final template = ContractCatalog.byId('landing_launch');
    final frontend = state.candidates
        .firstWhere((candidate) => candidate.role == EmployeeRole.frontend)
        .toEmployee();
    final designer = state.candidates
        .firstWhere((candidate) => candidate.role == EmployeeRole.designer)
        .toEmployee();

    state = state.copyWith(employees: <Employee>[frontend, designer]);

    final cashBeforeAccept = state.cash;

    state = engine.reduce(state, const AcceptClientContract('landing_launch'));

    expect(state.activeContracts, hasLength(1));
    expect(
      state.cash,
      closeTo(
        cashBeforeAccept + template.reward * template.upfrontPercent,
        0.01,
      ),
    );
    final advanceTransactions = state.financeTransactions
        .where(
          (transaction) =>
              transaction.category == FinanceTransactionCategory.contract,
        )
        .toList(growable: false);
    expect(advanceTransactions, hasLength(1));
    expect(
      advanceTransactions.single.amount,
      closeTo(template.reward * template.upfrontPercent, 0.01),
    );

    state = engine.reduce(
      state,
      SetContractTeam(
        contractId: state.activeContracts.single.id,
        employeeIds: <String>[frontend.id, designer.id],
      ),
    );

    final cashAfterUpfront = state.cash;

    state = engine.reduce(state, const AdvanceTime(2750));

    expect(state.completedContracts, hasLength(1));
    expect(state.activeContracts, isEmpty);
    final laterContractPayments = state.financeTransactions
        .where(
          (transaction) =>
              transaction.category == FinanceTransactionCategory.contract &&
              transaction.simulationMinutes > 0,
        )
        .toList(growable: false);
    expect(
      laterContractPayments.map((transaction) => transaction.description),
      containsAll(<String>[
        'Этап 50% • ${template.name}',
        'Финальная выплата • ${template.name}',
      ]),
    );
    final totalContractRevenue = state.financeTransactions
        .where(
          (transaction) =>
              transaction.category == FinanceTransactionCategory.contract,
        )
        .fold<double>(0, (sum, transaction) => sum + transaction.amount);
    expect(totalContractRevenue, closeTo(template.reward, 0.01));
    expect(state.cash, isNot(cashAfterUpfront));
  });

  test('parallel contracts share the available reserve capacity', () {
    const engine = GameEngine();
    var single = _fundedInitial().copyWith(cash: 1000000, paused: false);
    single = _withReleasedWebsite(single, engine);
    single = engine.reduce(
      single,
      const AcceptClientContract('landing_launch'),
    );
    single = engine.reduce(single, const AdvanceTime(1000));

    var parallel = _fundedInitial().copyWith(cash: 1000000, paused: false);
    parallel = _withReleasedWebsite(parallel, engine);
    parallel = engine.reduce(
      parallel,
      const AcceptClientContract('landing_launch'),
    );
    parallel = engine.reduce(
      parallel,
      const AcceptClientContract('internal_dashboard'),
    );
    parallel = engine.reduce(parallel, const AdvanceTime(1000));

    final singleProgress = single.clientContracts
        .firstWhere((item) => item.templateId == 'landing_launch')
        .progress;
    final parallelProgress = parallel.clientContracts
        .firstWhere((item) => item.templateId == 'landing_launch')
        .progress;

    expect(parallelProgress, lessThan(singleProgress));
  });

  test('contract can fail when deadline passes without enough capacity', () {
    const engine = GameEngine();
    var state = _fundedInitial().copyWith(cash: 1000000, paused: false);
    state = _withReleasedWebsite(state, engine);
    state = engine.reduce(
      state,
      const AcceptClientContract('internal_dashboard'),
    );

    state = engine.reduce(state, const AdvanceTime(6500));

    expect(state.clientContracts.single.status, ContractStatus.failed);
    expect(state.completedContracts, isEmpty);
    expect(state.activeContracts, isEmpty);
  });
}

GameState _fundedInitial() => GameState.initial().copyWith(
  selectedHostingPlanId: 'shared_launch',
  investorAgreements: List<InvestorAgreement>.generate(
    5,
    (index) => InvestorAgreement(
      id: 'fixture_agreement_$index',
      investorId: 'fixture_investor_$index',
      productId: 'fixture_product',
      investedAmount: 0,
      equityPercent: 0,
      revenueSharePercent: 0,
      buybackPrice: 0,
    ),
    growable: false,
  ),
);

CreateConfiguredProduct _configuredProduct({
  required String name,
  required String blueprintId,
  required String frameworkId,
  required List<String> featureIds,
}) {
  final languages = switch (frameworkId) {
    'static_web' => const <String>['html_css'],
    'laravel_web' => const <String>['php'],
    'flutter_firebase' => const <String>['dart'],
    'next_nest' => const <String>['typescript'],
    'fastapi_react' => const <String>['python', 'typescript'],
    'go_microservices' => const <String>['go'],
    'java_enterprise' => const <String>['java'],
    'rust_core' => const <String>['rust'],
    'chromium_fork' => const <String>['cpp', 'typescript'],
    _ => const <String>['typescript'],
  };
  return CreateConfiguredProduct(
    name: name,
    blueprintId: blueprintId,
    frameworkId: frameworkId,
    languageIds: languages,
    technologyIds: const <String>['postgresql', 'observability_stack'],
    featureIds: featureIds,
  );
}

GameState _withReleasedWebsite(GameState state, GameEngine engine) {
  state = engine.reduce(
    state,
    const CreateConfiguredProduct(
      name: 'Founder Site',
      blueprintId: 'company_website',
      frameworkId: 'static_web',
      languageIds: <String>['html_css'],
      technologyIds: <String>[],
      featureIds: <String>['landing_page'],
      monetization: MonetizationModel.advertising,
    ),
  );
  final website = state.products.last;
  return state.copyWith(
    products: state.products
        .map(
          (product) => product.id == website.id
              ? product.copyWith(
                  stage: ProductStage.live,
                  developmentProgress: 1,
                )
              : product,
        )
        .toList(growable: false),
  );
}
