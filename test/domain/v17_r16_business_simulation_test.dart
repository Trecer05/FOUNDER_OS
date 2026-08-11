import 'package:flutter_test/flutter_test.dart';
import 'package:founder_os/domain/catalog/game_catalog.dart';
import 'package:founder_os/domain/catalog/v17_endgame_catalog.dart';
import 'package:founder_os/domain/commands/game_action.dart';
import 'package:founder_os/domain/entities/game_state.dart';
import 'package:founder_os/domain/entities/models.dart';
import 'package:founder_os/domain/entities/operations_models.dart';
import 'package:founder_os/domain/entities/v17_models.dart';
import 'package:founder_os/domain/simulation/engine/game_engine.dart';

void main() {
  const engine = GameEngine();

  test('per-person perks use realistic early and mid-game prices', () {
    final workstation = V17EndgameCatalog.perkById('premium_workstations');
    final health = V17EndgameCatalog.perkById('health_insurance');
    final family = V17EndgameCatalog.perkById('family_support');
    expect(workstation.upfrontCost, 120000);
    expect(workstation.monthlyCost, 8000);
    expect(health.monthlyCost, 18000);
    expect(family.monthlyCost, 35000);
  });

  test(
    'research tree has prerequisites and stronger nodes cost more and take longer',
    () {
      final state = GameState.initial();
      expect(
        state.researchPrerequisiteNames(ResearchTargetKind.technology, 'redis'),
        contains('PostgreSQL'),
      );
      expect(
        state.researchPrerequisiteNames(ResearchTargetKind.technology, 'hsm'),
        contains('End-to-end encryption'),
      );
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
      expect(
        state.researchCost(ResearchTargetKind.technology, 'redis'),
        isNot(state.researchCost(ResearchTargetKind.technology, 'kubernetes')),
      );
      final expensiveFeature = GameCatalog.features.reduce(
        (left, right) =>
            left.developmentCost >= right.developmentCost ? left : right,
      );
      expect(
        state.researchDepth(ResearchTargetKind.feature, expensiveFeature.id),
        greaterThanOrEqualTo(1),
      );
    },
  );

  test('research engine refuses locked child before prerequisite', () {
    final state = GameState.initial().copyWith(cash: 100000000);
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
    'larger loan relative to company valuation has lower approval chance',
    () {
      final state = GameState.initial().copyWith(
        products: <Product>[_productFixture(monthlyRevenue: 3000000)],
      );
      final small = state.businessLoanApprovalChance(500000);
      final medium = state.businessLoanApprovalChance(5000000);
      final huge = state.businessLoanApprovalChance(25000000);
      expect(small, greaterThan(medium));
      expect(medium, greaterThan(huge));
    },
  );

  test('approved business loan issues exactly requested amount', () {
    const requested = 250000.0;
    GameState? approved;
    for (var seed = 1; seed <= 500 && approved == null; seed += 1) {
      final state = GameState.initial(seed: seed).copyWith(
        cash: 1000000,
        products: <Product>[_productFixture(monthlyRevenue: 5000000)],
      );
      final result = engine.reduce(
        state,
        const RequestBusinessLoan(amount: requested),
      );
      if (result.activeLoan != null) {
        approved = result;
        expect(result.cash - state.cash, closeTo(requested, 0.01));
        expect(
          result.financeTransactions.first.amount,
          closeTo(requested, 0.01),
        );
      }
    }
    expect(approved, isNotNull);
  });

  test('security incident exposes localization price before resolution', () {
    final state = GameState.initial().copyWith(
      products: <Product>[_productFixture()],
    );
    final next = engine.reduce(
      state,
      const TriggerSecurityIncident('r16_product'),
    );
    final notification = next.companyNotifications.firstWhere(
      (item) => item.id.startsWith('security_response_'),
    );
    expect(notification.body, contains('локализация стоит'));
    expect(notification.body, contains('₽'));
    expect(next.news.first.body, contains('Локализация атаки:'));
  });

  test('runway two months or less creates one finance warning per month', () {
    final employee = GameState.initial().candidates.first
        .toEmployee()
        .managedCopyWith(salary: 600000);
    var state = GameState.initial().copyWith(
      paused: false,
      cash: 900000,
      employees: <Employee>[employee],
    );
    expect(state.monthlyProfit, lessThan(0));
    expect(state.runwayMonths, lessThanOrEqualTo(2));
    state = engine.reduce(state, const AdvanceTime(360));
    expect(
      state.companyNotifications
          .where((item) => item.id.startsWith('runway_low_'))
          .length,
      1,
    );
    state = engine.reduce(state, const AdvanceTime(360));
    expect(
      state.companyNotifications
          .where((item) => item.id.startsWith('runway_low_'))
          .length,
      1,
    );
  });

  test('satisfaction follows real product experience, not churn feedback', () {
    final state = GameState.initial();
    final comfortable = _productFixture(
      quality: 96,
      reliability: 0.999,
      security: 95,
      intensity: 0.2,
    );
    final hostile = _productFixture(
      quality: 40,
      reliability: 0.84,
      security: 35,
      intensity: 1,
    );
    expect(
      state.productUserSatisfaction(comfortable),
      greaterThan(state.productUserSatisfaction(hostile)),
    );
  });

  test('higher subscription price lowers paid conversion', () {
    final state = GameState.initial();
    final affordable = _productFixture(
      blueprintId: 'team_saas',
      monetization: MonetizationModel.subscription,
      price: 300,
    );
    final expensive = _productFixture(
      blueprintId: 'team_saas',
      monetization: MonetizationModel.subscription,
      price: 3000,
    );
    expect(
      state.productPaidConversionRate(affordable),
      greaterThan(state.productPaidConversionRate(expensive)),
    );
  });

  test('harder paywall trades satisfaction for more short-term revenue', () {
    final state = GameState.initial();
    final mild = _productFixture(
      blueprintId: 'team_saas',
      monetization: MonetizationModel.subscription,
      price: 500,
      intensity: 0.2,
      freeTierPercent: 0.60,
    );
    final hard = _productFixture(
      blueprintId: 'team_saas',
      monetization: MonetizationModel.subscription,
      price: 500,
      intensity: 0.9,
      freeTierPercent: 0.05,
    );
    expect(
      state.productUserSatisfaction(hard),
      lessThan(state.productUserSatisfaction(mild)),
    );
    expect(
      state.productMonetizationRevenueEstimate(hard),
      greaterThan(state.productMonetizationRevenueEstimate(mild)),
    );
  });
}

Product _productFixture({
  String blueprintId = 'company_website',
  double monthlyRevenue = 500000,
  double quality = 84,
  double reliability = 0.995,
  double security = 75,
  double intensity = 0.5,
  double freeTierPercent = 0.35,
  MonetizationModel monetization = MonetizationModel.advertising,
  double price = 1.5,
}) {
  final blueprint = GameCatalog.blueprintById(blueprintId);
  return Product(
    id: 'r16_product',
    blueprintId: blueprint.id,
    name: 'Business Simulation',
    category: blueprint.category,
    stage: ProductStage.live,
    frameworkId: blueprintId == 'company_website' ? 'static_web' : 'next_nest',
    languageIds: blueprintId == 'company_website'
        ? const <String>['html_css']
        : const <String>['typescript'],
    technologyIds: const <String>[],
    featureIds: const <String>['landing_page'],
    developmentProgress: 1,
    users: 25000,
    dau: 6000,
    mau: 18000,
    activationRate: 0.55,
    retention30d: 0.62,
    churnRate: 0.05,
    rating: 4.2,
    speedMs: 180,
    designScore: 80,
    securityScore: security,
    reliability: reliability,
    featureCoverage: 0.8,
    qualityScore: quality,
    monthlyRevenue: monthlyRevenue,
    monthlyCost: 30000,
    monthlyGrowth: 2200,
    price: price,
    monetization: monetization,
    marketingBudget: 0,
    allocatedCapacityPercent: 30,
    computeMultiplier: 1,
    createdAtMinutes: 0,
    acquired: false,
    brandAwareness: 0.35,
    brandTrust: 0.72,
    priceSentiment: 0,
    monetizationIntensity: intensity,
    freeTierPercent: freeTierPercent,
  );
}
