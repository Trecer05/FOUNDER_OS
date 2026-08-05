import 'package:flutter_test/flutter_test.dart';
import 'package:founder_os/domain/catalog/game_catalog.dart';
import 'package:founder_os/domain/catalog/product_strategy_catalog.dart';
import 'package:founder_os/domain/commands/game_action.dart';
import 'package:founder_os/domain/entities/business_models.dart';
import 'package:founder_os/domain/entities/game_state.dart';
import 'package:founder_os/domain/entities/models.dart';
import 'package:founder_os/domain/entities/operations_models.dart';
import 'package:founder_os/domain/entities/product_strategy_models.dart';
import 'package:founder_os/domain/simulation/engine/game_engine.dart';
import 'package:founder_os/domain/simulation/product_estimator.dart';

void main() {
  const engine = GameEngine();

  test('new company starts lean and cannot fund a moonshot by accident', () {
    final state = GameState.initial();

    expect(state.cash, 450000);
    expect(
      ProductStrategyCatalog.strategyFor('city_system').setupCost,
      greaterThan(state.cash),
    );
  });

  test('company website monetizes only through advertising', () {
    final strategy = ProductStrategyCatalog.strategyFor('company_website');

    expect(strategy.allowedMonetizationModels, const <MonetizationModel>[
      MonetizationModel.advertising,
    ]);
  });

  test('candidate market covers every selectable programming language', () {
    final selectableLanguages = GameCatalog.languages
        .map((item) => item.id)
        .toSet();
    final candidateLanguages = GameCatalog.initialCandidates
        .expand((candidate) => candidate.languageIds)
        .toSet();

    expect(GameCatalog.initialCandidates.length, greaterThanOrEqualTo(24));
    expect(candidateLanguages, containsAll(selectableLanguages));
    expect(
      GameCatalog.initialCandidates.any(
        (candidate) => candidate.languageIds.contains('php'),
      ),
      isTrue,
    );
  });

  test('framework requirements and stack limits block invalid projects', () {
    var state = GameState.initial().copyWith(cash: 10000000);

    state = engine.reduce(
      state,
      const CreateConfiguredProduct(
        name: 'Broken Site',
        blueprintId: 'company_website',
        frameworkId: 'static_web',
        languageIds: <String>['javascript'],
        technologyIds: <String>[],
        featureIds: <String>['landing_page'],
      ),
    );
    expect(state.products, isEmpty);
    expect(state.feed.first, contains('HTML + CSS'));

    state = engine.reduce(
      state,
      const CreateConfiguredProduct(
        name: 'Everything Site',
        blueprintId: 'company_website',
        frameworkId: 'static_web',
        languageIds: <String>['html_css', 'javascript', 'typescript'],
        technologyIds: <String>['postgresql', 'redis'],
        featureIds: <String>['landing_page'],
      ),
    );
    expect(state.products, isEmpty);
    expect(state.feed.first, contains('максимум'));
  });

  test('framework choice produces visible schedule and cost tradeoffs', () {
    final staticProjection = ProductEstimator.estimate(
      blueprintId: 'company_website',
      frameworkId: 'static_web',
      languageIds: const <String>['html_css'],
      technologyIds: const <String>[],
      featureIds: const <String>['landing_page'],
    );
    final laravelProjection = ProductEstimator.estimate(
      blueprintId: 'company_website',
      frameworkId: 'laravel_web',
      languageIds: const <String>['php'],
      technologyIds: const <String>['postgresql'],
      featureIds: const <String>['landing_page', 'contact_form'],
    );

    expect(
      staticProjection.developmentHours,
      isNot(laravelProjection.developmentHours),
    );
    expect(
      staticProjection.monthlyTechCost,
      lessThan(laravelProjection.monthlyTechCost),
    );
    expect(
      staticProjection.developmentCost,
      lessThan(laravelProjection.developmentCost),
    );
  });

  test('city system is blocked until five investors are signed', () {
    const action = CreateConfiguredProduct(
      name: 'City Grid',
      blueprintId: 'city_system',
      frameworkId: 'java_enterprise',
      languageIds: <String>['java'],
      technologyIds: <String>['postgresql'],
      featureIds: <String>['public_portal'],
      monetization: MonetizationModel.usageBased,
    );

    var blocked = engine.reduce(
      GameState.initial().copyWith(cash: 10000000),
      action,
    );
    expect(blocked.products, isEmpty);
    expect(blocked.feed.first, contains('нужно инвесторов 5'));

    final funded = _withInvestorCount(
      GameState.initial().copyWith(cash: 10000000),
      5,
    );
    final created = engine.reduce(funded, action);
    expect(created.products.single.blueprintId, 'city_system');
  });

  test('large product cannot finish in two game days', () {
    var state = _withInvestorCount(
      GameState.initial().copyWith(cash: 10000000, paused: false),
      2,
    );
    state = engine.reduce(
      state,
      const CreateConfiguredProduct(
        name: 'Luma',
        blueprintId: 'privacy_browser',
        frameworkId: 'chromium_fork',
        languageIds: <String>['cpp', 'typescript'],
        technologyIds: <String>['observability_stack'],
        featureIds: <String>['tracker_blocking'],
        monetization: MonetizationModel.advertising,
      ),
    );
    for (final candidateId in const <String>[
      'c_anna',
      'c_daria',
      'c_sonya',
      'c_alina',
      'c_nikita',
      'c_vika',
      'c_maria',
    ]) {
      state = engine.reduce(state, HireCandidate(candidateId));
    }
    final productId = state.products.single.id;
    state = engine.reduce(
      state,
      SetProductTeam(
        productId: productId,
        employeeIds: state.employees.map((item) => item.id).toList(),
      ),
    );

    state = engine.reduce(state, const AdvanceTime(720));

    expect(state.products.single.developmentProgress, greaterThan(0));
    expect(state.products.single.developmentProgress, lessThan(0.20));
    expect(state.products.single.stage, ProductStage.development);
  });

  test('overstaffing is reported and loses coordination efficiency', () {
    var state = engine.reduce(
      GameState.initial().copyWith(cash: 10000000),
      const CreateConfiguredProduct(
        name: 'Crowded Site',
        blueprintId: 'company_website',
        frameworkId: 'static_web',
        languageIds: <String>['html_css'],
        technologyIds: <String>[],
        featureIds: <String>['landing_page'],
      ),
    );
    final productId = state.products.single.id;
    final employees = List<Employee>.generate(
      5,
      (index) => Employee(
        id: 'web_$index',
        name: 'Web $index',
        role: index == 0
            ? EmployeeRole.productManager
            : index == 1
            ? EmployeeRole.backend
            : EmployeeRole.frontend,
        skill: 80,
        speed: 80,
        quality: 80,
        autonomy: 80,
        communication: 80,
        reliability: 80,
        salary: 100000,
        loyalty: 80,
        morale: 80,
        workload: 60,
        remote: true,
        languageIds: const <String>['html_css'],
      ),
    );
    state = state.copyWith(
      employees: employees,
      employeeAssignments: employees
          .map(
            (employee) => EmployeeAssignment(
              employeeId: employee.id,
              productId: productId,
              assignedAtMinutes: state.simulationMinutes,
            ),
          )
          .toList(),
    );

    final staffing = state.developmentStaffingFor(productId);
    expect(staffing.status, contains('Перегруз'));
    expect(staffing.efficiency, lessThan(1));
    expect(staffing.movableEmployeeIds, isNotEmpty);
  });

  test('post-release feature queues work hours without direct purchase', () {
    var state = _releasedWebsite(engine).copyWith(cash: 350000);
    final product = state.products.single;
    final beforeCash = state.cash;

    state = engine.reduce(
      state,
      AddProductFeature(productId: product.id, featureId: 'contact_form'),
    );

    expect(state.cash, beforeCash);
    expect(
      state.productById(product.id)!.featureIds,
      isNot(contains('contact_form')),
    );
    expect(state.activeFeatureDevelopmentFor(product.id), isNotNull);
    expect(state.featureDevelopmentRemainingHours(product.id), greaterThan(0));
  });

  test('contracts unlock only after releasing the company website', () {
    var state = engine.reduce(
      GameState.initial(),
      const AcceptClientContract('landing_launch'),
    );
    expect(state.activeContracts, isEmpty);
    expect(state.feed.first, contains('Сначала выпустите сайт'));

    state = engine.reduce(
      _releasedWebsite(engine),
      const AcceptClientContract('landing_launch'),
    );
    expect(state.activeContracts, hasLength(1));
  });

  test('price forecast exposes churn and sentiment decays with time', () {
    var state = _releasedSubscriptionProduct(engine);
    final product = state.products.single;
    final forecast = state.priceImpactForecast(product, product.price * 1.5);

    expect(forecast.expectedUserChangePercent, lessThan(0));
    expect(forecast.expectedChurnDelta, greaterThan(0));
    expect(forecast.sentimentShock, greaterThan(0));

    state = engine.reduce(
      state,
      SetProductPrice(productId: product.id, price: product.price * 1.5),
    );
    final shocked = state.productById(product.id)!;
    expect(state.currentPriceSentiment(shocked), greaterThan(0));

    final settled = state.copyWith(
      simulationMinutes: state.simulationMinutes + 46 * 1440,
    );
    expect(settled.currentPriceSentiment(shocked), 0);
  });

  test('new unknown brand cannot buy a million users on release day', () {
    final state = _releasedWebsite(engine).copyWith(cash: 10000000);
    final product = state.products.single;
    final forecast = state.advertisingForecast(
      product: product,
      agencyId: 'signal_labs',
      channelId: 'social_feed',
      budget: 1000000,
    );

    expect(forecast.usersExpected, lessThan(5000));
    expect(forecast.note, contains('не доверяют'));
    expect(forecast.impressions, greaterThan(forecast.usersExpected));
  });

  test(
    'negative cash offers a controllable loan and early relapse ends game',
    () {
      final initial = GameState.initial();

      var state = initial.copyWith(
        cash: -1000,
        paused: false,
        negativeCashSinceMinutes: initial.simulationMinutes,
        clientContracts: const <ClientContract>[
          ClientContract(
            id: 'fixture_completed_contract',
            templateId: 'fixture_contract',
            status: ContractStatus.completed,
            progress: 1,
            acceptedAtMinutes: 0,
            deadlineAtMinutes: 7 * 1440,
            reward: 100000,
          ),
        ],
      );

      state = engine.reduce(state, const AdvanceTime(2520));

      expect(state.creditOffered, isTrue);
      expect(state.gameOver, isFalse);
      expect(state.criticalEvent, CriticalEventType.none);

      state = engine.reduce(state, const AcceptEmergencyLoan());

      expect(state.activeLoan, isNotNull);
      expect(state.cash, greaterThan(0));
      expect(state.gameOver, isFalse);

      state = state.copyWith(
        cash: -1,
        paused: false,
        negativeCashSinceMinutes: state.simulationMinutes,
      );

      state = engine.reduce(state, const AdvanceTime(1));

      expect(state.gameOver, isTrue);
      expect(state.criticalEvent, CriticalEventType.insolvency);
    },
  );

  test(
    'mostly repaid loan grants one final week instead of instant game over',
    () {
      final base = _releasedWebsite(engine);
      final loan = CompanyLoan(
        principal: 1000000,
        remaining: 250000,
        issuedAtMinutes: base.simulationMinutes - 10 * 1440,
        weeklyPayment: 50000,
        interestRate: 0.12,
      );
      var state = base.copyWith(
        cash: -1000,
        paused: false,
        activeLoan: loan,
        negativeCashSinceMinutes: base.simulationMinutes,
      );

      state = engine.reduce(state, const AdvanceTime(1));

      expect(state.gameOver, isFalse);
      expect(state.liquidityGraceUsed, isTrue);
      expect(state.feed.first, contains('последнюю неделю'));
    },
  );

  test('debug promo codes support rich and insolvency scenarios', () {
    final initial = GameState.initial();
    final rich = engine.reduce(initial, const RedeemDebugPromo('FOUNDER-RICH'));
    expect(rich.cash, initial.cash + 5000000);

    final broke = engine.reduce(rich, const RedeemDebugPromo('FOUNDER-BROKE'));
    expect(broke.cash, -500000);
    expect(broke.negativeCashSinceMinutes, isNotNull);
  });
}

GameState _withInvestorCount(GameState state, int count) => state.copyWith(
  investorAgreements: List<InvestorAgreement>.generate(
    count,
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

GameState _releasedWebsite(GameEngine engine) {
  var state = engine.reduce(
    GameState.initial().copyWith(cash: 10000000),
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
  final product = state.products.single;
  return state.copyWith(
    products: <Product>[
      product.copyWith(stage: ProductStage.live, developmentProgress: 1),
    ],
  );
}

GameState _releasedSubscriptionProduct(GameEngine engine) {
  var state = engine.reduce(
    GameState.initial().copyWith(cash: 10000000),
    const CreateConfiguredProduct(
      name: 'Flowspace',
      blueprintId: 'team_saas',
      frameworkId: 'flutter_firebase',
      languageIds: <String>['dart'],
      technologyIds: <String>['postgresql'],
      featureIds: <String>['realtime_collaboration'],
      monetization: MonetizationModel.subscription,
    ),
  );
  final product = state.products.single;
  return state.copyWith(
    products: <Product>[
      product.copyWith(
        stage: ProductStage.live,
        developmentProgress: 1,
        users: 12000,
        mau: 8000,
        dau: 1800,
        retention30d: 0.52,
        churnRate: 0.08,
        brandAwareness: 0.28,
        brandTrust: 0.34,
      ),
    ],
  );
}
