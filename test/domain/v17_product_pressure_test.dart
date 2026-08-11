import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:founder_os/domain/commands/game_action.dart';
import 'package:founder_os/domain/entities/game_state.dart';
import 'package:founder_os/domain/entities/models.dart';
import 'package:founder_os/domain/entities/operations_models.dart';
import 'package:founder_os/domain/entities/product_evolution_models.dart';
import 'package:founder_os/domain/entities/product_strategy_models.dart';
import 'package:founder_os/domain/entities/v16_models.dart';
import 'package:founder_os/domain/entities/v17_models.dart';
import 'package:founder_os/domain/simulation/engine/game_engine.dart';

void main() {
  const engine = GameEngine();

  test('v16 snapshot migrates to v17 routing and relocation defaults', () {
    final raw =
        jsonDecode(GameState.initial().encode()) as Map<String, dynamic>;
    raw['snapshotVersion'] = 14;
    raw.remove('employeeRelocations');
    raw.remove('productServiceRoutes');

    final restored = GameState.decode(jsonEncode(raw));

    expect(restored.snapshotVersion, 16);
    expect(restored.employeeRelocations, isEmpty);
    expect(restored.productServiceRoutes, isEmpty);
  });

  test(
    'legacy finite advertising campaign is stopped during v16 to v17 migration',
    () {
      final raw =
          jsonDecode(_liveWebsite(engine).encode()) as Map<String, dynamic>;
      raw['snapshotVersion'] = 14;
      raw['advertisingCampaigns'] = <Map<String, Object?>>[
        <String, Object?>{
          'id': 'legacy_week',
          'productId': (raw['products'] as List).first['id'],
          'agencyId': 'signal_labs',
          'channelId': 'search_ads',
          'budget': 300000,
          'startedAtMinutes': 0,
          'endsAtMinutes': 7 * 1440,
          'status': 'active',
          'projectedImpressions': 1000,
          'projectedClicks': 100,
          'projectedUsersLow': 20,
          'projectedUsersExpected': 30,
          'projectedUsersHigh': 40,
          'deliveredUsers': 10,
        },
      ];

      final restored = GameState.decode(jsonEncode(raw));
      expect(
        restored.advertisingCampaigns.single.status,
        AdvertisingCampaignStatus.stopped,
      );
      expect(restored.monthlyAdvertisingSpend, 0);
    },
  );

  test('senior cannot take ordinary courses', () {
    final candidate = GameState.initial().candidates.firstWhere(
      (item) => item.remote && !item.isHr,
    );
    final senior = candidate.toEmployee().managedCopyWith(
      skill: 90,
      grade: EmployeeGrade.senior,
    );
    final state = GameState.initial().copyWith(
      cash: 10000000,
      employees: <Employee>[senior],
    );

    final next = engine.reduce(
      state,
      TrainEmployee(employeeId: senior.id, programId: 'security'),
    );

    expect(next.trainingForEmployee(senior.id), isNull);
    expect(next.cash, state.cash);
  });

  test(
    'senior grade program is longer expensive and boosts several skills',
    () {
      final candidate = GameState.initial().candidates.firstWhere(
        (item) => item.remote && !item.isHr,
      );
      final employee = candidate.toEmployee().managedCopyWith(
        skill: 40,
        speed: 45,
        quality: 44,
        autonomy: 42,
        communication: 43,
        reliability: 46,
        grade: EmployeeGrade.intern,
        salary: 100000,
      );
      var state = GameState.initial().copyWith(
        cash: 10000000,
        paused: false,
        employees: <Employee>[employee],
      );
      final cashBefore = state.cash;

      state = engine.reduce(
        state,
        UpgradeEmployeesToGrade(
          employeeIds: <String>[employee.id],
          targetGrade: EmployeeGrade.senior,
        ),
      );

      final plan = state.gradeUpgradeForEmployee(employee.id)!;
      expect(plan.completesAtMinutes - plan.startedAtMinutes, 13 * 1440);
      expect(plan.cost, greaterThan(employee.salary * 3));
      expect(state.cash, lessThan(cashBefore));

      state = engine.reduce(state, const AdvanceTime(13 * 360));
      final upgraded = state.employeeById(employee.id)!;
      expect(upgraded.grade, EmployeeGrade.senior);
      expect(upgraded.skill, greaterThan(employee.skill));
      expect(upgraded.speed, greaterThan(employee.speed));
      expect(upgraded.quality, greaterThan(employee.quality));
      expect(upgraded.autonomy, greaterThan(employee.autonomy));
      expect(upgraded.reliability, greaterThan(employee.reliability));
    },
  );

  test(
    'remote employee relocation costs money takes time and ends on-site',
    () {
      final candidate = GameState.initial().candidates.firstWhere(
        (item) => item.remote && !item.isHr,
      );
      var state = GameState.initial().copyWith(
        cash: 100000000,
        paused: false,
        employees: <Employee>[candidate.toEmployee()],
      );
      state = engine.reduce(
        state,
        const BuildOwnedOffice(
          cityId: 'warsaw',
          size: FacilitySize.small,
          fitoutQuality: FacilityQuality.standard,
          equipmentQuality: FacilityQuality.standard,
        ),
      );
      final office = state.ownedOffices.single;
      final cost = state.employeeRelocationCost(
        state.employeeById(candidate.id)!,
        office,
      );
      final cashBefore = state.cash;

      state = engine.reduce(
        state,
        RelocateEmployeeToOffice(
          employeeId: candidate.id,
          officeSiteId: office.id,
        ),
      );

      expect(state.relocationForEmployee(candidate.id), isNotNull);
      expect(state.cash, closeTo(cashBefore - cost, 0.01));
      expect(state.employeeById(candidate.id)!.remote, isTrue);

      state = engine.reduce(state, const AdvanceTime(5 * 360));
      expect(state.relocationForEmployee(candidate.id), isNull);
      expect(state.employeeById(candidate.id)!.remote, isFalse);
      expect(state.employeeById(candidate.id)!.locationCityId, 'warsaw');
    },
  );

  test('features stack and improvements extend supported product lifetime', () {
    var state = _liveWebsite(engine);
    final product = state.products.single;
    final baseLifetime = state.productSupportedLifetimeDays(product);

    final expanded = product.copyWith(
      featureIds: <String>[...product.featureIds, 'contact_form', 'analytics'],
      technologyIds: <String>[...product.technologyIds, 'redis', 'cdn'],
    );
    state = state.copyWith(
      products: <Product>[expanded],
      productImprovements: <ProductImprovementRecord>[
        ProductImprovementRecord(
          productId: expanded.id,
          type: ProductImprovementType.performance,
          level: 2,
          appliedAtMinutes: state.simulationMinutes,
        ),
      ],
    );

    expect(
      state.productSupportedLifetimeDays(expanded),
      greaterThan(baseLifetime),
    );
  });

  test('service routes isolate product resources by data center', () {
    var state = _liveWebsite(engine).copyWith(cash: 500000000);
    state = engine.reduce(
      state,
      const BuildOwnedDataCenter(
        cityId: 'helsinki',
        size: FacilitySize.small,
        facilityQuality: FacilityQuality.standard,
        equipmentQuality: FacilityQuality.standard,
      ),
    );
    state = engine.reduce(
      state,
      const BuildOwnedDataCenter(
        cityId: 'warsaw',
        size: FacilitySize.small,
        facilityQuality: FacilityQuality.standard,
        equipmentQuality: FacilityQuality.standard,
      ),
    );
    final computeSite = state.ownedDataCenters[0];
    final dataSite = state.ownedDataCenters[1];
    state = engine.reduce(
      state,
      InstallServer(
        'edge_s1',
        dataCenterSiteId: computeSite.id,
        service: InfrastructureService.aiCompute,
      ),
    );
    state = engine.reduce(
      state,
      InstallServer(
        'cluster_x12',
        dataCenterSiteId: dataSite.id,
        service: InfrastructureService.dataStorage,
      ),
    );
    state = state.copyWith(selectedHostingPlanId: 'owned');
    final product = state.products.single;
    state = engine.reduce(
      state,
      AssignProductInfrastructureService(
        productId: product.id,
        service: InfrastructureService.aiCompute,
        dataCenterSiteId: computeSite.id,
      ),
    );
    state = engine.reduce(
      state,
      AssignProductInfrastructureService(
        productId: product.id,
        service: InfrastructureService.dataStorage,
        dataCenterSiteId: dataSite.id,
      ),
    );

    expect(
      state.dataCenterRouteFor(product.id, InfrastructureService.aiCompute),
      computeSite.id,
    );
    expect(
      state.dataCenterRouteFor(product.id, InfrastructureService.dataStorage),
      dataSite.id,
    );
    expect(state.allocatedComputeFor(product.id), greaterThan(0));
    expect(state.allocatedStorageFor(product.id), greaterThan(0));
    expect(
      state.preparedComputeUnitsAtDataCenterForService(
        dataSite.id,
        InfrastructureService.aiCompute,
      ),
      0,
    );
    expect(
      state.preparedStorageGbAtDataCenterForService(
        computeSite.id,
        InfrastructureService.dataStorage,
      ),
      0,
    );
  });

  test(
    'new servers are dedicated to one service pool while legacy hardware migrates shared',
    () {
      final dedicated = InstalledServer(
        hardwareId: 'edge_s1',
        count: 1,
        dataCenterSiteId: 'dc_test',
        service: InfrastructureService.appApi,
      );
      final restored = InstalledServer.fromJson(<String, Object?>{
        'hardwareId': 'edge_s1',
        'count': 2,
        'dataCenterSiteId': 'dc_legacy',
      });

      expect(dedicated.service, InfrastructureService.appApi);
      expect(restored.service, InfrastructureService.sharedLegacy);
    },
  );

  test(
    'bootstrap website remains safe on shared launch while scaled usage stays material',
    () {
      var state = engine.reduce(
        GameState.initial().copyWith(
          cash: 10000000,
          selectedHostingPlanId: 'shared_launch',
        ),
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
      final product = state.products.single.copyWith(
        stage: ProductStage.live,
        developmentProgress: 1,
      );
      state = state.copyWith(products: <Product>[product]);

      expect(state.productServerLoad(product), lessThanOrEqualTo(1.35));

      final scaled = product.copyWith(users: 100000);
      expect(state.productMemoryDemand(scaled), greaterThan(5));
      expect(state.productStorageDemand(scaled), greaterThan(100));
    },
  );

  test('AI and website use material RAM and storage budgets', () {
    final websiteState = _liveWebsite(engine);
    final website = websiteState.products.single.copyWith(users: 100000);
    expect(websiteState.productMemoryDemand(website), greaterThan(5));
    expect(websiteState.productStorageDemand(website), greaterThan(100));

    var aiState = engine.reduce(
      GameState.initial().copyWith(cash: 10000000),
      const CreateConfiguredProduct(
        name: 'AI Load',
        blueprintId: 'ai_assistant',
        frameworkId: 'fastapi_react',
        languageIds: <String>['python', 'typescript'],
        technologyIds: <String>['postgresql'],
        featureIds: <String>['chat_history'],
      ),
    );
    final ai = aiState.products.single.copyWith(
      stage: ProductStage.live,
      developmentProgress: 1,
      users: 100000,
      mau: 70000,
    );
    aiState = aiState.copyWith(products: <Product>[ai]);
    expect(aiState.productMemoryDemand(ai), greaterThan(20));
    expect(aiState.productStorageDemand(ai), greaterThan(300));
  });

  test(
    'performance and algorithms improvements reduce server resource demand',
    () {
      var state = _liveWebsite(engine);
      final product = state.products.single.copyWith(users: 250000);
      state = state.copyWith(products: <Product>[product]);
      final memoryBefore = state.productMemoryDemand(product);
      final storageBefore = state.productStorageDemand(product);
      final computeBefore = state.productComputeDemand(product);

      state = state.copyWith(
        productImprovements: <ProductImprovementRecord>[
          ProductImprovementRecord(
            productId: product.id,
            type: ProductImprovementType.performance,
            level: 2,
            appliedAtMinutes: state.simulationMinutes,
          ),
          ProductImprovementRecord(
            productId: product.id,
            type: ProductImprovementType.algorithms,
            level: 2,
            appliedAtMinutes: state.simulationMinutes,
          ),
        ],
      );

      expect(state.productMemoryDemand(product), lessThan(memoryBefore));
      expect(state.productStorageDemand(product), lessThan(storageBefore));
      expect(state.productComputeDemand(product), lessThan(computeBefore));
    },
  );

  test('aggressive monetization hurts retention and increases churn', () {
    final state = _liveWebsite(engine);
    final base = state.products.single.copyWith(
      monetization: MonetizationModel.subscription,
      price: 120,
      monetizationIntensity: 0.2,
      freeTierPercent: 0.6,
    );
    final harsh = base.copyWith(
      price: 2500,
      monetizationIntensity: 1,
      freeTierPercent: 0,
    );

    final mildImpact = state.monetizationExperienceImpact(base);
    final harshImpact = state.monetizationExperienceImpact(harsh);
    expect(harshImpact.activationDelta, lessThan(mildImpact.activationDelta));
    expect(harshImpact.retentionDelta, lessThan(mildImpact.retentionDelta));
    expect(harshImpact.churnDelta, greaterThan(mildImpact.churnDelta));
    expect(harshImpact.trustDelta, lessThan(mildImpact.trustDelta));
  });

  test('monetization pressure reaches live retention and churn metrics', () {
    var mild = _liveWebsite(engine).copyWith(paused: false);
    var harsh = mild;
    final product = mild.products.single;
    mild = mild.copyWith(
      products: <Product>[
        product.copyWith(
          monetization: MonetizationModel.subscription,
          price: 1,
          monetizationIntensity: 0.2,
          freeTierPercent: 0.65,
        ),
      ],
    );
    harsh = harsh.copyWith(
      products: <Product>[
        product.copyWith(
          monetization: MonetizationModel.subscription,
          price: 2500,
          monetizationIntensity: 1,
          freeTierPercent: 0,
        ),
      ],
    );

    mild = engine.reduce(mild, const AdvanceTime(360));
    harsh = engine.reduce(harsh, const AdvanceTime(360));

    expect(
      harsh.products.single.retention30d,
      lessThan(mild.products.single.retention30d),
    );
    expect(
      harsh.products.single.churnRate,
      greaterThan(mild.products.single.churnRate),
    );
    expect(
      harsh.products.single.activationRate,
      lessThan(mild.products.single.activationRate),
    );
  });

  test(
    'prelaunch investor negotiation ignores live infrastructure overload risk',
    () {
      var state = engine.reduce(
        GameState.initial().copyWith(
          cash: 10000000,
          selectedHostingPlanId: 'shared_launch',
        ),
        const CreateConfiguredProduct(
          name: 'Investor AI',
          blueprintId: 'ai_assistant',
          frameworkId: 'fastapi_react',
          languageIds: <String>['python', 'typescript'],
          technologyIds: <String>['postgresql', 'observability_stack'],
          featureIds: <String>['chat_history', 'file_analysis', 'web_search'],
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
      final decisionDays = int.parse(
        state.investorOffers.single.id.split('_').last,
      );
      state = state.copyWith(paused: false);
      state = engine.reduce(state, AdvanceTime(decisionDays * 360 + 1));

      expect(state.investorOffers, hasLength(1));
      expect(state.investorOffers.single.offeredAmount, 500000);
    },
  );

  test(
    'advertising is recurring monthly spend with gradual users and stop',
    () {
      var state = _liveWebsite(engine).copyWith(cash: 10000000, paused: false);
      final product = state.products.single;
      final cashBefore = state.cash;

      state = engine.reduce(
        state,
        StartAdvertisingCampaign(
          productId: product.id,
          agencyId: 'signal_labs',
          channelId: 'search_ads',
          budget: 300000,
        ),
      );

      expect(state.cash, cashBefore);
      expect(state.activeCampaignsFor(product.id), hasLength(1));
      expect(state.monthlyAdvertisingSpend, 300000);
      expect(state.activeCampaignsFor(product.id).single.endsAtMinutes, -1);

      state = engine.reduce(state, const AdvanceTime(360));
      final campaign = state.activeCampaignsFor(product.id).single;
      expect(campaign.deliveredUsers, greaterThan(0));
      expect(
        state.financeTransactions.any(
          (item) => item.category.name == 'marketing' && item.amount < 0,
        ),
        isTrue,
      );

      state = engine.reduce(state, StopAdvertisingCampaign(campaign.id));
      expect(state.activeCampaignsFor(product.id), isEmpty);
      expect(state.monthlyAdvertisingSpend, 0);
    },
  );

  test(
    'a successful product creates material variable scale operations cost',
    () {
      var state = _liveWebsite(engine);
      final small = state.products.single.copyWith(mau: 10000, users: 15000);
      state = state.copyWith(products: <Product>[small]);
      final smallCost = state.monthlyScaleOperationsCost;

      final hit = small.copyWith(mau: 1000000, users: 1400000);
      state = state.copyWith(products: <Product>[hit]);
      expect(state.monthlyScaleOperationsCost, greaterThan(smallCost * 40));
      expect(state.monthlyScaleOperationsCost, greaterThan(1000000));
    },
  );

  test('portfolio diversification improves discovery versus a single hit', () {
    var single = _liveWebsite(engine).copyWith(paused: false);
    var diversified = engine.reduce(
      single,
      const CreateConfiguredProduct(
        name: 'Second Product',
        blueprintId: 'company_website',
        frameworkId: 'static_web',
        languageIds: <String>['html_css'],
        technologyIds: <String>[],
        featureIds: <String>['landing_page'],
      ),
    );
    final firstId = single.products.single.id;
    diversified = diversified.copyWith(
      paused: false,
      products: diversified.products
          .map((product) {
            if (product.id == firstId) {
              return single.products.single;
            }
            return product.copyWith(
              stage: ProductStage.live,
              developmentProgress: 1,
              users: 5000,
              mau: 3000,
              dau: 500,
              allocatedCapacityPercent: 0,
              releasedAtMinutes: diversified.simulationMinutes,
            );
          })
          .toList(growable: false),
    );

    single = engine.reduce(single, const AdvanceTime(360));
    diversified = engine.reduce(diversified, const AdvanceTime(360));

    expect(
      diversified.productById(firstId)!.monthlyGrowth,
      greaterThan(single.productById(firstId)!.monthlyGrowth),
    );
  });

  test(
    'daily recurring infrastructure costs are visible in finance ledger',
    () {
      var state = GameState.initial().copyWith(
        cash: 10000000,
        paused: false,
        selectedOfficeId: 'garage',
      );

      state = engine.reduce(state, const AdvanceTime(360));

      expect(
        state.financeTransactions.any(
          (item) =>
              item.description.contains('Инфраструктура') && item.amount < 0,
        ),
        isTrue,
      );
    },
  );
}

GameState _liveWebsite(GameEngine engine) {
  var state = engine.reduce(
    GameState.initial().copyWith(cash: 10000000),
    const RentHostingPlan('shared_launch'),
  );
  state = engine.reduce(
    state,
    const CreateConfiguredProduct(
      name: 'Web Core',
      blueprintId: 'company_website',
      frameworkId: 'static_web',
      languageIds: <String>['html_css'],
      technologyIds: <String>[],
      featureIds: <String>['landing_page'],
    ),
  );
  final product = state.products.single.copyWith(
    stage: ProductStage.live,
    developmentProgress: 1,
    users: 15000,
    mau: 9000,
    dau: 1500,
    allocatedCapacityPercent: 100,
    monetization: MonetizationModel.subscription,
    price: 199,
    releasedAtMinutes: state.simulationMinutes,
  );
  return state.copyWith(products: <Product>[product]);
}
