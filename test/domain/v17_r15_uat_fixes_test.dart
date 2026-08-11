import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:founder_os/application/controllers/game_controller.dart';
import 'package:founder_os/domain/catalog/game_catalog.dart';
import 'package:founder_os/domain/catalog/v17_endgame_catalog.dart';
import 'package:founder_os/domain/commands/game_action.dart';
import 'package:founder_os/domain/entities/game_state.dart';
import 'package:founder_os/domain/entities/models.dart';
import 'package:founder_os/domain/entities/v12_models.dart';
import 'package:founder_os/domain/entities/v17_models.dart';
import 'package:founder_os/domain/simulation/engine/game_engine.dart';
import 'package:founder_os/persistence/storage/snapshot_store.dart';
import 'package:founder_os/presentation/features/dashboard/founder_dashboard.dart';
import 'package:founder_os/presentation/features/products/product_workspace_screen.dart';
import 'package:founder_os/presentation/features/research/research_screen.dart';
import 'package:founder_os/presentation/shared/widgets/formatters.dart';

void main() {
  const engine = GameEngine();

  test('perk recurring cost follows employee headcount after enable', () {
    final base = GameState.initial();
    final employees = base.candidates
        .take(2)
        .map((item) => item.toEmployee())
        .toList();
    var state = base.copyWith(
      cash: 100000000,
      employees: <Employee>[employees.first],
    );
    final perk = V17EndgameCatalog.perkById('health_insurance');

    state = engine.reduce(state, const ToggleCompanyPerk('health_insurance'));
    expect(state.monthlyCompanyPerkCost, perk.monthlyCost);
    expect(state.cash, closeTo(100000000 - perk.upfrontCost, 0.01));

    state = state.copyWith(employees: employees);
    expect(state.monthlyCompanyPerkCost, perk.monthlyCost * 2);
    state = state.copyWith(employees: <Employee>[employees.last]);
    expect(state.monthlyCompanyPerkCost, perk.monthlyCost);
  });

  test(
    'world project custom name survives snapshot and completed OS earns revenue',
    () {
      final definition = V17EndgameCatalog.worldProjectById('world_os');
      var state = GameState.initial().copyWith(
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

  test(
    'new product rejects unresearched technology and accepts it after R&D',
    () {
      var state = GameState.initial().copyWith(cash: 100000000, paused: false);
      const action = CreateConfiguredProduct(
        name: 'Research Gate',
        blueprintId: 'company_website',
        frameworkId: 'static_web',
        languageIds: <String>['html_css'],
        technologyIds: <String>['redis'],
        featureIds: <String>['landing_page'],
      );

      final blocked = engine.reduce(state, action);
      expect(blocked.products, isEmpty);
      expect(blocked.feed.first, contains('Сначала исследуйте технологию'));

      state = engine.reduce(
        state,
        const StartCompanyResearch(
          kind: ResearchTargetKind.technology,
          targetId: 'redis',
        ),
      );
      final days = state.researchDays(ResearchTargetKind.technology, 'redis');
      state = engine.reduce(state, AdvanceTime(days * 360 + 60));
      expect(
        state.researchCompleted(ResearchTargetKind.technology, 'redis'),
        isTrue,
      );

      state = engine.reduce(state, action);
      expect(state.products, hasLength(1));
    },
  );

  test('researched technology integrates into a live product', () {
    var state = GameState.initial().copyWith(
      cash: 100000000,
      paused: false,
      products: <Product>[_productFixture()],
    );
    state = engine.reduce(
      state,
      const StartCompanyResearch(
        kind: ResearchTargetKind.technology,
        targetId: 'redis',
      ),
    );
    final days = state.researchDays(ResearchTargetKind.technology, 'redis');
    state = engine.reduce(state, AdvanceTime(days * 360 + 60));
    state = engine.reduce(
      state,
      const AddProductTechnology(
        productId: 'r15_product',
        technologyId: 'redis',
      ),
    );

    final work = state.activeFeatureDevelopmentFor('r15_product');
    expect(work, isNotNull);
    expect(work!.featureId, '__technology_redis');
  });

  test(
    'user satisfaction is bounded and improves with healthier experience',
    () {
      final state = GameState.initial();
      final normal = state.productUserSatisfaction(_productFixture());
      final low = state.productUserSatisfaction(
        _productFixture(
          quality: 35,
          reliability: 0.82,
          security: 35,
          intensity: 1,
        ),
      );
      final high = state.productUserSatisfaction(
        _productFixture(
          quality: 96,
          reliability: 0.999,
          security: 96,
          intensity: 0.2,
        ),
      );

      expect(normal, greaterThanOrEqualTo(0));
      expect(normal, lessThanOrEqualTo(100));
      expect(high, greaterThan(low));
    },
  );

  testWidgets(
    'rename dialog can be closed with back without disposed controller error',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(900, 1000));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final state = GameState.initial().copyWith(
        companyProfile: const FounderCompanyProfile.legacy(),
        onboardingCompleted: true,
        products: <Product>[_productFixture()],
      );
      final controller = await _controller(state);
      addTearDown(controller.dispose);
      await tester.pumpWidget(
        MaterialApp(
          home: ProductWorkspaceScreen(
            controller: controller,
            productId: state.products.single.id,
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('rename-product')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('rename-product-field')), findsOneWidget);
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(
        find.byKey(const Key('product-user-satisfaction')),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'dashboard header keeps fan and reputation icons with long company name',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(390, 844));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final state = GameState.initial().copyWith(
        companyProfile: const FounderCompanyProfile(
          configured: true,
          companyName: 'Очень длинное название технологической компании',
          founderName: 'CEO',
          logoId: 'company_logo_01',
          startingBudget: 450000,
          background: FounderBackground.product,
          skills: <FounderSkill, int>{
            FounderSkill.engineering: 4,
            FounderSkill.design: 3,
            FounderSkill.product: 5,
            FounderSkill.growth: 3,
            FounderSkill.negotiation: 3,
            FounderSkill.operations: 4,
          },
        ),
        onboardingCompleted: true,
        companyFans: 1234567,
        brandReputation: 88,
      );
      final controller = await _controller(state);
      addTearDown(controller.dispose);
      await tester.pumpWidget(
        MaterialApp(home: FounderDashboard(controller: controller)),
      );
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.favorite_outline), findsOneWidget);
      expect(find.byIcon(Icons.workspace_premium_outlined), findsWidgets);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('dedicated R&D screen shows technology price before research', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(900, 1200));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final controller = await _controller(
      GameState.initial().copyWith(cash: 100000000),
    );
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      MaterialApp(home: ResearchScreen(controller: controller)),
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('research-screen-list')), findsOneWidget);
    expect(
      find.byKey(const Key('research-screen-technology-redis')),
      findsOneWidget,
    );
    final cost = controller.state.researchCost(
      ResearchTargetKind.technology,
      'redis',
    );
    expect(find.textContaining(money(cost)), findsWidgets);
  });
}

Future<GameController> _controller(GameState state) async {
  final controller = GameController(
    snapshotStore: _MemoryStore(state),
    startClock: false,
  );
  await controller.initialize();
  return controller;
}

class _MemoryStore implements SnapshotStore {
  _MemoryStore(this.state);
  GameState state;

  @override
  Future<void> clear() async => state = GameState.initial();

  @override
  Future<GameState?> load() async => state;

  @override
  Future<void> save(GameState value) async => state = value;
}

Product _productFixture({
  double churn = 0.05,
  double rating = 4.2,
  double quality = 84,
  double reliability = 0.995,
  double security = 75,
  double intensity = 0.5,
}) {
  final blueprint = GameCatalog.blueprintById('company_website');
  return Product(
    id: 'r15_product',
    blueprintId: blueprint.id,
    name: 'R15 Product',
    category: blueprint.category,
    stage: ProductStage.live,
    frameworkId: 'static_web',
    languageIds: const <String>['html_css', 'javascript'],
    technologyIds: const <String>[],
    featureIds: const <String>['landing_page'],
    developmentProgress: 1,
    users: 10000,
    dau: 2500,
    mau: 7000,
    activationRate: 0.58,
    retention30d: 0.62,
    churnRate: churn,
    rating: rating,
    speedMs: 180,
    designScore: 80,
    securityScore: security,
    reliability: reliability,
    featureCoverage: 0.8,
    qualityScore: quality,
    monthlyRevenue: 500000,
    monthlyCost: 50000,
    monthlyGrowth: 1000,
    price: 490,
    monetization: MonetizationModel.advertising,
    marketingBudget: 0,
    allocatedCapacityPercent: 30,
    computeMultiplier: 1,
    createdAtMinutes: 0,
    acquired: false,
    brandAwareness: 0.4,
    brandTrust: 0.72,
    priceSentiment: 0,
    monetizationIntensity: intensity,
  );
}
