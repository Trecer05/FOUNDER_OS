import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:founder_os/domain/catalog/v17_endgame_catalog.dart';
import 'package:founder_os/domain/commands/game_action.dart';
import 'package:founder_os/domain/entities/game_state.dart';
import 'package:founder_os/domain/entities/models.dart';
import 'package:founder_os/domain/entities/operations_models.dart';
import 'package:founder_os/domain/entities/v16_models.dart';
import 'package:founder_os/domain/entities/v17_models.dart';
import 'package:founder_os/domain/simulation/engine/game_engine.dart';

void main() {
  const engine = GameEngine();

  test('v17 r1 snapshot migrates to endgame ecosystem defaults', () {
    final raw =
        jsonDecode(GameState.initial().encode()) as Map<String, dynamic>;
    raw['snapshotVersion'] = 15;
    for (final key in <String>[
      'activeResearchProjects',
      'completedResearchKeys',
      'enabledCompanyPerkIds',
      'legendMarketOffers',
      'hiredLegendBonuses',
      'pendingEmployeeDepartures',
      'companyFans',
      'brandReputation',
      'industryEventOpportunities',
      'bookedIndustryEvents',
      'companyNotifications',
      'worldProjects',
      'ecosystemDoctrine',
      'philanthropySpent',
      'postGamePath',
    ]) {
      raw.remove(key);
    }

    final restored = GameState.decode(jsonEncode(raw));
    expect(restored.snapshotVersion, 16);
    expect(restored.completedResearchKeys, isEmpty);
    expect(restored.companyFans, 0);
    expect(restored.brandReputation, 10);
    expect(restored.worldProjects, isEmpty);
    expect(restored.postGamePath, PostGamePath.none);
  });

  test('post-release feature requires paid research before implementation', () {
    var state = _liveWebsite().copyWith(cash: 100000000, paused: false);
    final product = state.products.single;
    const featureId = 'contact_form';

    final blocked = engine.reduce(
      state,
      AddProductFeature(productId: product.id, featureId: featureId),
    );
    expect(blocked.activeFeatureDevelopmentFor(product.id), isNull);

    final cost = state.researchCost(ResearchTargetKind.feature, featureId);
    final days = state.researchDays(ResearchTargetKind.feature, featureId);
    state = engine.reduce(
      state,
      const StartCompanyResearch(
        kind: ResearchTargetKind.feature,
        targetId: featureId,
      ),
    );
    expect(state.cash, closeTo(100000000 - cost, 0.01));
    expect(
      state.activeResearchFor(
        state.researchKey(ResearchTargetKind.feature, featureId),
      ),
      isNotNull,
    );

    state = engine.reduce(state, AdvanceTime(days * 360));
    expect(
      state.researchCompleted(ResearchTargetKind.feature, featureId),
      isTrue,
    );
    state = engine.reduce(
      state,
      AddProductFeature(productId: product.id, featureId: featureId),
    );
    expect(state.activeFeatureDevelopmentFor(product.id), isNotNull);
  });

  test('research is reusable across products after one completion', () {
    final state = GameState.initial().copyWith(
      completedResearchKeys: <String>['technology:redis'],
    );
    expect(
      state.researchCompleted(ResearchTargetKind.technology, 'redis'),
      isTrue,
    );
    expect(state.activeResearchProjects, isEmpty);
  });

  test('company perks create recurring spend and retention value', () {
    var state = GameState.initial().copyWith(cash: 100000000);
    final definition = V17EndgameCatalog.perkById('health_insurance');
    state = engine.reduce(state, const ToggleCompanyPerk('health_insurance'));

    expect(state.enabledCompanyPerkIds, contains('health_insurance'));
    expect(state.monthlyCompanyPerkCost, definition.monthlyCost);
    expect(state.companyPerkLoyaltyBonus, greaterThan(0));
    expect(state.companyPerkMoraleBonus, greaterThan(0));
    expect(state.cash, closeTo(100000000 - definition.upfrontCost, 0.01));
  });

  test(
    'poor on-site conditions erode loyalty while remote staff avoid office penalty',
    () {
      final candidates = GameState.initial().candidates
          .where((item) => !item.isHr)
          .take(2)
          .toList(growable: false);
      final onSite = candidates[0].toEmployee().managedCopyWith(
        remote: false,
        loyalty: 70,
        morale: 70,
        workload: 50,
        locationCityId: 'moscow',
      );
      final remote = candidates[1].toEmployee().managedCopyWith(
        remote: true,
        loyalty: 70,
        morale: 70,
        workload: 50,
        locationCityId: 'moscow',
      );
      var state = GameState.initial().copyWith(
        paused: false,
        employees: <Employee>[onSite, remote],
        selectedOfficeId: 'remote_first',
      );
      state = engine.reduce(state, const AdvanceTime(1080));
      expect(state.employeeById(onSite.id)!.loyalty, lessThan(70));
      expect(state.employeeById(remote.id)!.loyalty, greaterThanOrEqualTo(70));
    },
  );

  test('counter offer keeps a resigning employee with required raise', () {
    final candidate = GameState.initial().candidates.firstWhere(
      (item) => !item.isHr,
    );
    final employee = candidate.toEmployee().managedCopyWith(
      salary: 200000,
      loyalty: 20,
    );
    var state = GameState.initial().copyWith(
      employees: <Employee>[employee],
      pendingEmployeeDepartures: <PendingEmployeeDeparture>[
        PendingEmployeeDeparture(
          employeeId: employee.id,
          createdAtMinutes: 0,
          deadlineMinutes: 3 * 1440,
          requiredRaisePercent: 20,
        ),
      ],
    );

    state = engine.reduce(state, CounterOfferEmployee(employee.id));
    expect(state.pendingDepartureFor(employee.id), isNull);
    expect(state.employeeById(employee.id)!.salary, closeTo(240000, 0.01));
    expect(state.employeeById(employee.id)!.loyalty, greaterThan(20));
  });

  test('expired resignation removes employee and creates notification', () {
    final candidate = GameState.initial().candidates.firstWhere(
      (item) => !item.isHr,
    );
    final employee = candidate.toEmployee().managedCopyWith(loyalty: 10);
    var state = GameState.initial().copyWith(
      paused: false,
      employees: <Employee>[employee],
      pendingEmployeeDepartures: <PendingEmployeeDeparture>[
        PendingEmployeeDeparture(
          employeeId: employee.id,
          createdAtMinutes: 0,
          deadlineMinutes: 1,
          requiredRaisePercent: 25,
        ),
      ],
    );

    state = engine.reduce(state, const AdvanceTime(360));
    expect(state.employeeById(employee.id), isNull);
    expect(
      state.companyNotifications.any(
        (item) => item.kind == CompanyNotificationKind.employee,
      ),
      isTrue,
    );
  });

  test(
    'architect legend requires three products valuation and premium Cyprus office',
    () {
      final products = <Product>[
        _product('p_web', 'company_website', ProductCategory.saas),
        _product('p_ai', 'ai_assistant', ProductCategory.aiAssistant),
        _product('p_cloud', 'cloud_platform', ProductCategory.cloud),
      ];
      final base = GameState.initial().copyWith(products: products);
      expect(base.hasLegendRequirement('legend_architect'), isFalse);

      final ready = base.copyWith(
        ownedOffices: const <OwnedOfficeSite>[
          OwnedOfficeSite(
            id: 'cyprus_hq',
            cityId: 'limassol',
            size: FacilitySize.medium,
            fitoutQuality: FacilityQuality.premium,
            equipmentQuality: FacilityQuality.premium,
            builtAtMinutes: 0,
          ),
        ],
      );
      expect(ready.valuation, greaterThan(3000000000));
      expect(ready.hasLegendRequirement('legend_architect'), isTrue);
    },
  );

  test('hired legend has all 100 stats and unique product bonus', () {
    final products = <Product>[
      _product('p_web', 'company_website', ProductCategory.saas),
      _product('p_ai', 'ai_assistant', ProductCategory.aiAssistant),
      _product('p_cloud', 'cloud_platform', ProductCategory.cloud),
    ];
    var state = GameState.initial().copyWith(
      cash: 500000000,
      products: products,
      ownedOffices: const <OwnedOfficeSite>[
        OwnedOfficeSite(
          id: 'cyprus_hq',
          cityId: 'limassol',
          size: FacilitySize.medium,
          fitoutQuality: FacilityQuality.premium,
          equipmentQuality: FacilityQuality.premium,
          builtAtMinutes: 0,
        ),
      ],
      legendMarketOffers: const <LegendMarketOffer>[
        LegendMarketOffer(
          legendId: 'legend_architect',
          productId: 'p_cloud',
          bonusKind: LegendProductBonusKind.performance,
          availableUntilMinutes: 21 * 1440,
        ),
      ],
    );

    state = engine.reduce(
      state,
      const HireMarketLegend(
        legendId: 'legend_architect',
        productId: 'p_cloud',
      ),
    );
    final legend = state.employeeById('market_legend_architect')!;
    expect(legend.skill, 100);
    expect(legend.speed, 100);
    expect(legend.quality, 100);
    expect(legend.autonomy, 100);
    expect(legend.communication, 100);
    expect(legend.reliability, 100);
    expect(
      state.legendProductMetricBonus(
        'p_cloud',
        LegendProductBonusKind.performance,
      ),
      1,
    );
  });

  test(
    'event sells at most three product slots and later creates users and fans',
    () {
      final products = <Product>[
        _product('p1', 'company_website', ProductCategory.saas),
        _product('p2', 'ai_assistant', ProductCategory.aiAssistant),
        _product('p3', 'cloud_platform', ProductCategory.cloud),
        _product('p4', 'team_saas', ProductCategory.saas),
      ];
      const opportunity = IndustryEventOpportunity(
        id: 'event_test',
        templateId: 'global_tech_expo',
        availableUntilMinutes: 10 * 1440,
        eventAtMinutes: 1440,
      );
      var state = GameState.initial().copyWith(
        cash: 500000000,
        paused: false,
        products: products,
        industryEventOpportunities: const <IndustryEventOpportunity>[
          opportunity,
        ],
      );
      final fansBefore = state.companyFans;
      state = engine.reduce(
        state,
        const JoinIndustryEvent(
          opportunityId: 'event_test',
          productIds: <String>['p1', 'p2', 'p3', 'p4'],
        ),
      );
      expect(state.bookedIndustryEvents.single.productIds, hasLength(3));
      final usersBefore = state.products.fold<int>(
        0,
        (sum, item) => sum + item.users,
      );

      state = engine.reduce(state, const AdvanceTime(360));
      expect(state.companyFans, greaterThan(fansBefore));
      expect(
        state.products.fold<int>(0, (sum, item) => sum + item.users),
        greaterThan(usersBefore),
      );
    },
  );

  test('notifications expose unread count and can all be marked read', () {
    var state = GameState.initial().copyWith(
      companyNotifications: const <CompanyNotification>[
        CompanyNotification(
          id: 'n1',
          kind: CompanyNotificationKind.tax,
          title: 'Tax',
          body: 'Soon',
          simulationMinutes: 0,
          read: false,
        ),
        CompanyNotification(
          id: 'n2',
          kind: CompanyNotificationKind.legend,
          title: 'Legend',
          body: 'Market',
          simulationMinutes: 0,
          read: false,
        ),
      ],
    );
    expect(state.unreadCompanyNotificationCount, 2);
    state = engine.reduce(state, const MarkAllCompanyNotificationsRead());
    expect(state.unreadCompanyNotificationCount, 0);
  });

  test('world projects are huge gated spend with their own operating cost', () {
    final definition = V17EndgameCatalog.worldProjectById('world_os');
    var blocked = GameState.initial().copyWith(cash: 100000000000);
    blocked = engine.reduce(blocked, const FundWorldProjectPhase('world_os'));
    expect(blocked.worldProjectProgressFor('world_os'), isNull);

    var ready = GameState.initial().copyWith(
      cash: 300000000000,
      companyFans: 2000000,
      completedResearchKeys: List<String>.generate(
        12,
        (index) => 'research:$index',
      ),
      products: <Product>[
        _product(
          'money',
          'cloud_platform',
          ProductCategory.cloud,
        ).copyWith(monthlyRevenue: 2000000000),
      ],
    );
    expect(ready.valuation, greaterThan(definition.minimumValuation));
    final cashBefore = ready.cash;
    ready = engine.reduce(ready, const FundWorldProjectPhase('world_os'));
    expect(ready.worldProjectProgressFor('world_os'), isNotNull);
    expect(ready.cash, closeTo(cashBefore - definition.phaseCosts.first, 0.01));
  });

  test('AURA OS exposes a deep dedicated upgrade tree', () {
    final upgrades = V17EndgameCatalog.worldProjectUpgrades
        .where((item) => item.projectId == 'world_os')
        .toList(growable: false);
    expect(upgrades.length, greaterThanOrEqualTo(12));
    expect(upgrades.map((item) => item.id), contains('os_sdk'));
    expect(upgrades.map((item) => item.id), contains('os_store'));
    expect(upgrades.map((item) => item.id), contains('os_ai'));
  });

  test('campaign completion depends only on all three world projects', () {
    final projects = V17EndgameCatalog.worldProjects
        .map((definition) {
          final upgrades = V17EndgameCatalog.worldProjectUpgrades
              .where((item) => item.projectId == definition.id)
              .take(definition.requiredUpgradeCount)
              .map((item) => item.id)
              .toList(growable: false);
          return WorldProjectProgress(
            projectId: definition.id,
            completedPhases: definition.phaseCosts.length,
            activePhaseCompletesAtMinutes: -1,
            completedUpgradeIds: upgrades,
            activeUpgradeId: '',
            activeUpgradeCompletesAtMinutes: -1,
          );
        })
        .toList(growable: false);
    final state = GameState.initial().copyWith(worldProjects: projects);

    expect(state.releasedBlueprintCount, 0);
    expect(state.requiredReleasedBlueprintsForLegacy, 0);
    expect(state.founderLegacyCompleted, isTrue);
  });

  test('open doctrine favors fans while dominant doctrine favors revenue', () {
    final product = _product(
      'money',
      'cloud_platform',
      ProductCategory.cloud,
    ).copyWith(monthlyRevenue: 100000000);
    final open = GameState.initial().copyWith(
      products: <Product>[product],
      ecosystemDoctrine: EcosystemDoctrine.open,
    );
    final dominant = open.copyWith(
      ecosystemDoctrine: EcosystemDoctrine.dominant,
    );

    expect(
      dominant.monthlyProductRevenue,
      greaterThan(open.monthlyProductRevenue),
    );
    expect(
      open.brandDemandMultiplier,
      greaterThan(dominant.brandDemandMultiplier),
    );
  });

  test('philanthropy converts cash into fans reputation and legacy', () {
    var state = GameState.initial().copyWith(cash: 2000000000);
    final fans = state.companyFans;
    final reputation = state.brandReputation;
    final legacy = state.companyLegacyScore;
    state = engine.reduce(state, const FundPhilanthropy(1000000000));
    expect(state.companyFans, greaterThan(fans));
    expect(state.brandReputation, greaterThan(reputation));
    expect(state.companyLegacyScore, greaterThan(legacy));
  });

  test('post-game path is locked before victory and available after it', () {
    var state = GameState.initial();
    state = engine.reduce(
      state,
      const ChoosePostGamePath(PostGamePath.holdingCompany),
    );
    expect(state.postGamePath, PostGamePath.none);

    final completed = V17EndgameCatalog.worldProjects
        .map((definition) {
          final upgrades = V17EndgameCatalog.worldProjectUpgrades
              .where((item) => item.projectId == definition.id)
              .take(definition.requiredUpgradeCount)
              .map((item) => item.id)
              .toList(growable: false);
          return WorldProjectProgress(
            projectId: definition.id,
            completedPhases: definition.phaseCosts.length,
            activePhaseCompletesAtMinutes: -1,
            completedUpgradeIds: upgrades,
            activeUpgradeId: '',
            activeUpgradeCompletesAtMinutes: -1,
          );
        })
        .toList(growable: false);
    state = state.copyWith(worldProjects: completed);
    state = engine.reduce(
      state,
      const ChoosePostGamePath(PostGamePath.holdingCompany),
    );
    expect(state.postGamePath, PostGamePath.holdingCompany);
  });

  test(
    'perks and world projects materially increase late-game recurring spend',
    () {
      final world = WorldProjectProgress(
        projectId: 'free_ai',
        completedPhases: V17EndgameCatalog.worldProjectById(
          'free_ai',
        ).phaseCosts.length,
        activePhaseCompletesAtMinutes: -1,
        completedUpgradeIds: const <String>[],
        activeUpgradeId: '',
        activeUpgradeCompletesAtMinutes: -1,
      );
      final base = GameState.initial();
      final scaled = base.copyWith(
        enabledCompanyPerkIds: V17EndgameCatalog.companyPerks
            .map((item) => item.id)
            .toList(growable: false),
        worldProjects: <WorldProjectProgress>[world],
      );
      expect(scaled.monthlyCosts, greaterThan(base.monthlyCosts + 2500000000));
    },
  );
}

GameState _liveWebsite() {
  const engine = GameEngine();
  var state = engine.reduce(
    GameState.initial().copyWith(cash: 10000000),
    const RentHostingPlan('shared_launch'),
  );
  state = engine.reduce(
    state,
    const CreateConfiguredProduct(
      name: 'R&D Web',
      blueprintId: 'company_website',
      frameworkId: 'static_web',
      languageIds: <String>['html_css'],
      technologyIds: <String>[],
      featureIds: <String>['landing_page'],
    ),
  );
  return state.copyWith(
    products: <Product>[
      state.products.single.copyWith(
        stage: ProductStage.live,
        developmentProgress: 1,
        users: 20000,
        mau: 12000,
        dau: 2000,
        monthlyRevenue: 600000,
        releasedAtMinutes: 0,
      ),
    ],
  );
}

Product _product(String id, String blueprintId, ProductCategory category) {
  return Product(
    id: id,
    blueprintId: blueprintId,
    name: id,
    category: category,
    stage: ProductStage.live,
    frameworkId: 'static_web',
    languageIds: const <String>['html_css'],
    technologyIds: const <String>[],
    featureIds: const <String>['landing_page'],
    developmentProgress: 1,
    users: 1000000,
    dau: 120000,
    mau: 600000,
    activationRate: 0.55,
    retention30d: 0.42,
    churnRate: 0.07,
    rating: 4.4,
    speedMs: 220,
    designScore: 82,
    securityScore: 80,
    reliability: 0.995,
    featureCoverage: 0.9,
    qualityScore: 88,
    monthlyRevenue: 250000000,
    monthlyCost: 10000000,
    monthlyGrowth: 15000,
    price: 999,
    monetization: MonetizationModel.subscription,
    marketingBudget: 0,
    allocatedCapacityPercent: 30,
    computeMultiplier: 1,
    createdAtMinutes: 0,
    acquired: false,
    brandAwareness: 0.8,
    brandTrust: 0.8,
    releasedAtMinutes: 0,
  );
}
