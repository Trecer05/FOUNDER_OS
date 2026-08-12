import 'package:flutter_test/flutter_test.dart';
import 'package:founder_os/domain/catalog/v17_endgame_catalog.dart';
import 'package:founder_os/domain/commands/game_action.dart';
import 'package:founder_os/domain/entities/game_state.dart';
import 'package:founder_os/domain/entities/models.dart';
import 'package:founder_os/domain/entities/v16_models.dart';
import 'package:founder_os/domain/entities/v17_models.dart';
import 'package:founder_os/domain/simulation/engine/game_engine.dart';

import '../support/fixtures.dart';

void main() {
  const engine = GameEngine();

  test('technology research tree exposes explicit prerequisites', () {
    final state = GameState.initial();
    expect(
      state.researchPrerequisiteKeys(ResearchTargetKind.technology, 'redis'),
      contains('technology:postgresql'),
    );
    expect(
      state.researchPrerequisiteKeys(ResearchTargetKind.technology, 'hsm'),
      contains('technology:e2ee'),
    );
  });

  test('deeper research costs more and takes longer', () {
    final state = GameState.initial();
    expect(
      state.researchDepth(ResearchTargetKind.technology, 'hsm'),
      greaterThan(state.researchDepth(ResearchTargetKind.technology, 'e2ee')),
    );
    expect(
      state.researchCost(ResearchTargetKind.technology, 'hsm'),
      greaterThan(state.researchCost(ResearchTargetKind.technology, 'e2ee')),
    );
    expect(
      state.researchDays(ResearchTargetKind.technology, 'hsm'),
      greaterThan(state.researchDays(ResearchTargetKind.technology, 'e2ee')),
    );
  });

  test('research engine refuses locked child before prerequisite', () {
    final state = fundedInitial(cash: 100000000);
    final blocked = engine.reduce(
      state,
      const StartCompanyResearch(
        kind: ResearchTargetKind.technology,
        targetId: 'hsm',
      ),
    );
    expect(blocked.activeResearchProjects, isEmpty);
    expect(blocked.feed.first, contains('сначала исследуйте'));
  });

  test(
    'starting player-selected research does not create notification spam',
    () {
      final state = engine.reduce(
        fundedInitial(cash: 100000000),
        const StartCompanyResearch(
          kind: ResearchTargetKind.technology,
          targetId: 'postgresql',
        ),
      );
      expect(state.activeResearchProjects, hasLength(1));
      expect(
        state.companyNotifications.where(
          (item) => item.kind == CompanyNotificationKind.research,
        ),
        isEmpty,
      );
    },
  );

  test(
    'completed company research is reusable and no longer costs time or money',
    () {
      final state = GameState.initial().copyWith(
        completedResearchKeys: const <String>['technology:redis'],
      );
      expect(
        state.researchCompleted(ResearchTargetKind.technology, 'redis'),
        isTrue,
      );
      expect(state.researchCost(ResearchTargetKind.technology, 'redis'), 0);
      expect(state.researchDays(ResearchTargetKind.technology, 'redis'), 0);
    },
  );

  test(
    'world project is blocked until valuation fans and research gates are met',
    () {
      final blocked = engine.reduce(
        fundedInitial(cash: 300000000000),
        const FundWorldProjectPhase('world_os'),
      );
      expect(blocked.worldProjectProgressFor('world_os'), isNull);
    },
  );

  test(
    'eligible company can fund first AURA OS phase with exact phase CAPEX',
    () {
      final definition = V17EndgameCatalog.worldProjectById('world_os');
      var state = fundedInitial(cash: 300000000000).copyWith(
        companyFans: 2000000,
        completedResearchKeys: List<String>.generate(
          12,
          (index) => 'research:$index',
        ),
        products: <Product>[
          productFixture(
            id: 'money',
            blueprintId: 'cloud_platform',
            monthlyRevenue: 2000000000,
          ),
        ],
      );
      expect(state.valuation, greaterThan(definition.minimumValuation));
      final cashBefore = state.cash;
      state = engine.reduce(state, const FundWorldProjectPhase('world_os'));
      expect(state.worldProjectProgressFor('world_os'), isNotNull);
      expect(
        state.cash,
        closeTo(cashBefore - definition.phaseCosts.first, 0.01),
      );
    },
  );

  test(
    'completed world project earns its catalog revenue and custom name persists',
    () {
      final definition = V17EndgameCatalog.worldProjectById('world_os');
      var state = fundedInitial().copyWith(
        worldProjects: <WorldProjectProgress>[
          WorldProjectProgress(
            projectId: definition.id,
            completedPhases: definition.phaseCosts.length,
            activePhaseCompletesAtMinutes: -1,
            completedUpgradeIds: const <String>[],
            activeUpgradeId: '',
            activeUpgradeCompletesAtMinutes: -1,
          ),
        ],
      );
      expect(state.monthlyWorldProjectRevenue, definition.monthlyRevenue);
      state = engine.reduce(
        state,
        const RenameWorldProject(projectId: 'world_os', name: 'Nova OS'),
      );
      expect(state.worldProjectDisplayName('world_os'), 'Nova OS');
      final restored = GameState.decode(state.encode());
      expect(restored.worldProjectDisplayName('world_os'), 'Nova OS');
      expect(restored.monthlyWorldProjectRevenue, definition.monthlyRevenue);
    },
  );

  test('AURA OS has a deep dedicated upgrade tree', () {
    final upgrades = V17EndgameCatalog.worldProjectUpgrades
        .where((item) => item.projectId == 'world_os')
        .toList();
    expect(upgrades.length, greaterThanOrEqualTo(12));
    expect(
      upgrades.map((item) => item.id),
      containsAll(<String>['os_sdk', 'os_store', 'os_ai']),
    );
  });

  test('industry event sells at most three product showcase slots', () {
    const opportunity = IndustryEventOpportunity(
      id: 'event_test',
      templateId: 'global_tech_expo',
      availableUntilMinutes: 10 * 1440,
      eventAtMinutes: 1440,
    );
    var state = fundedInitial(cash: 500000000).copyWith(
      products: <Product>[
        productFixture(id: 'p1'),
        productFixture(id: 'p2', blueprintId: 'ai_assistant'),
        productFixture(id: 'p3', blueprintId: 'cloud_platform'),
        productFixture(id: 'p4', blueprintId: 'team_saas'),
      ],
      industryEventOpportunities: const <IndustryEventOpportunity>[opportunity],
    );
    state = engine.reduce(
      state,
      const JoinIndustryEvent(
        opportunityId: 'event_test',
        productIds: <String>['p1', 'p2', 'p3', 'p4'],
      ),
    );
    expect(state.bookedIndustryEvents.single.productIds, hasLength(3));
  });

  test('notifications expose unread count and mark-all-read action', () {
    var state = fundedInitial().copyWith(
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

  test(
    'architect legend requires premium Limassol office and sufficient scale',
    () {
      final products = <Product>[
        productFixture(id: 'web', monthlyRevenue: 300000000),
        productFixture(
          id: 'ai',
          blueprintId: 'ai_assistant',
          monthlyRevenue: 300000000,
        ),
        productFixture(
          id: 'cloud',
          blueprintId: 'cloud_platform',
          monthlyRevenue: 300000000,
        ),
      ];
      final base = fundedInitial().copyWith(products: products);
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

  test('campaign victory depends only on all three world projects', () {
    final projects = V17EndgameCatalog.worldProjects.map((definition) {
      final upgrades = V17EndgameCatalog.worldProjectUpgrades
          .where((item) => item.projectId == definition.id)
          .take(definition.requiredUpgradeCount)
          .map((item) => item.id)
          .toList();
      return WorldProjectProgress(
        projectId: definition.id,
        completedPhases: definition.phaseCosts.length,
        activePhaseCompletesAtMinutes: -1,
        completedUpgradeIds: upgrades,
        activeUpgradeId: '',
        activeUpgradeCompletesAtMinutes: -1,
      );
    }).toList();
    final state = fundedInitial().copyWith(worldProjects: projects);
    expect(state.releasedBlueprintCount, 0);
    expect(state.requiredReleasedBlueprintsForLegacy, 0);
    expect(state.founderLegacyCompleted, isTrue);
  });

  test('post-game path is locked before victory', () {
    final state = fundedInitial();
    final blocked = engine.reduce(
      state,
      const ChoosePostGamePath(PostGamePath.infiniteGrowth),
    );
    expect(blocked.postGamePath, PostGamePath.none);
  });
}
