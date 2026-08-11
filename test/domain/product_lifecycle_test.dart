import 'package:flutter_test/flutter_test.dart';
import 'package:founder_os/domain/commands/game_action.dart';
import 'package:founder_os/domain/entities/game_state.dart';
import 'package:founder_os/domain/entities/models.dart';
import 'package:founder_os/domain/entities/product_evolution_models.dart';
import 'package:founder_os/domain/entities/v17_models.dart';
import 'package:founder_os/domain/simulation/engine/game_engine.dart';

import '../support/fixtures.dart';

void main() {
  const engine = GameEngine();

  test('new configured product starts from zero progress', () {
    final state = engine.reduce(
      fundedInitial(),
      const CreateConfiguredProduct(
        name: 'Zero Start',
        blueprintId: 'company_website',
        frameworkId: 'static_web',
        languageIds: <String>['html_css'],
        technologyIds: <String>[],
        featureIds: <String>['landing_page'],
        monetization: MonetizationModel.advertising,
      ),
    );
    expect(state.products, hasLength(1));
    expect(state.products.single.developmentProgress, 0);
    expect(state.products.single.stage, ProductStage.development);
  });

  test(
    'new product rejects unresearched technology and accepts after research',
    () {
      var state = fundedInitial().copyWith(paused: false);
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

  test('launch is blocked before development completes', () {
    final product = productFixture(
      id: 'launch',
      stage: ProductStage.development,
    ).copyWith(developmentProgress: 0.8);
    final state = fundedInitial().copyWith(
      selectedHostingPlanId: 'shared_launch',
      products: <Product>[product],
    );
    final blocked = engine.reduce(state, const LaunchProduct('launch'));
    expect(blocked.productById('launch')!.stage, ProductStage.development);

    final ready = state.copyWith(
      products: <Product>[product.copyWith(developmentProgress: 1)],
    );
    final launched = engine.reduce(ready, const LaunchProduct('launch'));
    expect(launched.productById('launch')!.stage, ProductStage.live);
  });

  test('post-release feature is gated by company research', () {
    final state = liveWebsiteState().copyWith(cash: 100000000);
    final product = state.products.single;
    final blocked = engine.reduce(
      state,
      AddProductFeature(productId: product.id, featureId: 'contact_form'),
    );
    expect(blocked.activeFeatureDevelopmentFor(product.id), isNull);
  });

  test('researched feature queues team work without direct purchase', () {
    var state = liveWebsiteState().copyWith(cash: 100000000);
    final product = state.products.single;
    state = state.copyWith(
      completedResearchKeys: <String>[
        state.researchKey(ResearchTargetKind.feature, 'contact_form'),
      ],
    );
    final cashBefore = state.cash;
    state = engine.reduce(
      state,
      AddProductFeature(productId: product.id, featureId: 'contact_form'),
    );
    expect(
      state.productById(product.id)!.featureIds,
      isNot(contains('contact_form')),
    );
    expect(state.activeFeatureDevelopmentFor(product.id), isNotNull);
    expect(
      state.activeFeatureDevelopmentFor(product.id)!.requiredHours,
      greaterThan(0),
    );
    expect(state.cash, cashBefore);
  });

  test('researched technology integration also enters technical queue', () {
    var state = liveWebsiteState().copyWith(
      cash: 100000000,
      completedResearchKeys: const <String>['technology:redis'],
    );
    final product = state.products.single;
    state = engine.reduce(
      state,
      AddProductTechnology(productId: product.id, technologyId: 'redis'),
    );
    final work = state.activeFeatureDevelopmentFor(product.id);
    expect(work, isNotNull);
    expect(work!.featureId, '__technology_redis');
  });

  test('product rename survives snapshot round-trip', () {
    var state = liveWebsiteState();
    state = engine.reduce(
      state,
      const RenameProduct(productId: 'website', name: 'Renamed Product'),
    );
    expect(state.productById('website')!.name, 'Renamed Product');
    expect(
      GameState.decode(state.encode()).productById('website')!.name,
      'Renamed Product',
    );
  });

  test('bugs are persisted weighted entities with live product penalty', () {
    final product = productFixture().copyWith(
      openBugs: const <ProductBug>[
        ProductBug(
          id: 'critical_bug',
          title: 'Payment failure',
          severity: ProductBugSeverity.critical,
          openedAtMinutes: 10,
        ),
      ],
      fixedBugCount: 2,
    );
    final state = fundedInitial().copyWith(products: <Product>[product]);
    expect(product.openBugs.single.weight, 7);
    expect(state.productBugPenalty(product), greaterThan(0));
    final restored = GameState.decode(state.encode()).products.single;
    expect(restored.openBugs.single.weight, 7);
    expect(restored.fixedBugCount, 2);
  });

  test('performance and algorithms improvements reduce resource footprint', () {
    final product = productFixture(users: 250000);
    var state = fundedInitial().copyWith(
      selectedHostingPlanId: 'vps_core',
      products: <Product>[product],
    );
    final computeBefore = state.productComputeDemand(product);
    final memoryBefore = state.productMemoryDemand(product);
    final storageBefore = state.productStorageDemand(product);

    state = state.copyWith(
      productImprovements: <ProductImprovementRecord>[
        ProductImprovementRecord(
          productId: product.id,
          type: ProductImprovementType.performance,
          level: 2,
          appliedAtMinutes: 0,
        ),
        ProductImprovementRecord(
          productId: product.id,
          type: ProductImprovementType.algorithms,
          level: 2,
          appliedAtMinutes: 0,
        ),
      ],
    );
    expect(state.productComputeDemand(product), lessThan(computeBefore));
    expect(state.productMemoryDemand(product), lessThan(memoryBefore));
    expect(state.productStorageDemand(product), lessThan(storageBefore));
  });

  test('features stack and improvements extend supported product lifetime', () {
    final base = productFixture();
    var state = fundedInitial().copyWith(products: <Product>[base]);
    final baseLifetime = state.productSupportedLifetimeDays(base);
    final expanded = base.copyWith(
      featureIds: <String>[...base.featureIds, 'contact_form', 'analytics'],
      technologyIds: <String>[...base.technologyIds, 'redis', 'cdn'],
    );
    state = state.copyWith(
      products: <Product>[expanded],
      productImprovements: <ProductImprovementRecord>[
        ProductImprovementRecord(
          productId: expanded.id,
          type: ProductImprovementType.performance,
          level: 2,
          appliedAtMinutes: 0,
        ),
      ],
    );
    expect(
      state.productSupportedLifetimeDays(expanded),
      greaterThan(baseLifetime),
    );
  });

  test('AI deployment mode is persisted as product capability state', () {
    final ai = productFixture(
      id: 'ai',
      blueprintId: 'ai_assistant',
      featureIds: const <String>['chat_history'],
    );
    var state = fundedInitial().copyWith(products: <Product>[ai]);
    state = engine.reduce(
      state,
      const SetAiDeploymentMode(
        productId: 'ai',
        mode: AiDeploymentMode.corporate,
      ),
    );
    expect(state.productAiDeployments, hasLength(1));
    expect(state.productAiDeployments.single.productId, 'ai');
    expect(state.productAiDeployments.single.mode, AiDeploymentMode.corporate);
    expect(
      GameState.decode(state.encode()).productAiDeployments.single.mode,
      AiDeploymentMode.corporate,
    );
  });
}
