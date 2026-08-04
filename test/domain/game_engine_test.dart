import 'package:flutter_test/flutter_test.dart';
import 'package:founder_os/domain/commands/game_action.dart';
import 'package:founder_os/domain/entities/game_state.dart';
import 'package:founder_os/domain/entities/models.dart';
import 'package:founder_os/domain/simulation/engine/game_engine.dart';

void main() {
  const engine = GameEngine();

  test('same seed and actions produce exactly the same state', () {
    final actions = <GameAction>[
      _configuredProduct(
        name: 'Nova',
        blueprintId: 'ai_assistant',
        frameworkId: 'fastapi_react',
        featureIds: const <String>['chat_history', 'file_analysis'],
      ),
      const HireCandidate('c_anna'),
      const TogglePause(),
      const AdvanceTime(60),
      const SetGameSpeed(GameSpeed.x4),
      const AdvanceTime(30),
    ];

    GameState run() {
      var state = GameState.initial();
      for (final action in actions) {
        state = engine.reduce(state, action);
      }
      return state;
    }

    expect(run().encode(), equals(run().encode()));
  });

  test('candidate hiring respects numeric office capacity', () {
    var state = GameState.initial();
    state = engine.reduce(state, const HireCandidate('c_anna'));
    state = engine.reduce(state, const HireCandidate('c_timur'));
    state = engine.reduce(state, const HireCandidate('c_daria'));
    final fullOffice = engine.reduce(state, const HireCandidate('c_ilya'));

    expect(state.employees, hasLength(3));
    expect(state.candidateById('c_anna'), isNull);
    expect(fullOffice.employees, hasLength(3));
    expect(fullOffice.office.capacity, 3);
  });

  test(
    'ecosystem supports many links, rejects duplicates and keeps products',
    () {
      var state = GameState.initial().copyWith(cash: 10000000);
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

      expect(state.ecosystemLinks, hasLength(2));
      expect(duplicate.ecosystemLinks, hasLength(2));
      expect(state.connectedProductIds(ai.id), hasLength(2));
      expect(state.ecosystemBoostFor(ai.id), closeTo(0.05, 0.0001));
      expect(state.products.map((item) => item.id).toSet(), hasLength(3));
    },
  );

  test('product roadmap adds a real feature and charges exact cost', () {
    var state = GameState.initial().copyWith(cash: 10000000);
    state = engine.reduce(
      state,
      _configuredProduct(
        name: 'Nova',
        blueprintId: 'ai_assistant',
        frameworkId: 'fastapi_react',
        featureIds: const <String>['chat_history'],
      ),
    );
    final product = state.products.single;
    final cashBefore = state.cash;
    final coverageBefore = product.featureCoverage;

    state = engine.reduce(
      state,
      AddProductFeature(productId: product.id, featureId: 'file_analysis'),
    );

    final updated = state.productById(product.id)!;
    expect(updated.featureIds, contains('file_analysis'));
    expect(updated.featureCoverage, greaterThan(coverageBefore));
    expect(state.cash, cashBefore - 78000);
  });

  test(
    'market rewards product advantage even when weaker rival spends on ads',
    () {
      var state = GameState.initial().copyWith(cash: 20000000);
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
      var state = GameState.initial().copyWith(cash: 10000000);
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
      expect(state.investorOffers.single.offeredAmount, 500000);

      state = engine.reduce(
        state,
        AcceptInvestorOffer(state.investorOffers.single.id),
      );
      expect(state.investorAgreements, hasLength(1));
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
      final state = GameState.initial().copyWith(
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
      var state = GameState.initial().copyWith(cash: 10000000);
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
    var state = GameState.initial().copyWith(cash: 10000000);
    final rejected = engine.reduce(state, const InstallServer('cluster_x12'));
    expect(rejected.installedCount('cluster_x12'), 0);
    expect(rejected.installedCount('edge_s1'), state.installedCount('edge_s1'));

    state = engine.reduce(state, const RentServerRoom('regional_dc'));
    state = engine.reduce(state, const InstallServer('cluster_x12'));
    expect(state.installedCount('cluster_x12'), 1);
    expect(state.infrastructureFitsRoom, isTrue);
  });

  test('acquired product migration requires prepared compute capacity', () {
    var state = GameState.initial().copyWith(cash: 30000000);
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
    state = engine.reduce(state, const InstallServer('cluster_x12'));
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
    var state = GameState.initial().copyWith(cash: 10000000);
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
}

CreateConfiguredProduct _configuredProduct({
  required String name,
  required String blueprintId,
  required String frameworkId,
  required List<String> featureIds,
}) {
  return CreateConfiguredProduct(
    name: name,
    blueprintId: blueprintId,
    frameworkId: frameworkId,
    languageIds: const <String>['typescript'],
    technologyIds: const <String>['postgresql', 'observability_stack'],
    featureIds: featureIds,
  );
}
