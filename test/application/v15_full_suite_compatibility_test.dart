import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:founder_os/application/controllers/game_controller.dart';
import 'package:founder_os/domain/commands/game_action.dart';
import 'package:founder_os/domain/entities/game_state.dart';
import 'package:founder_os/domain/entities/models.dart';
import 'package:founder_os/domain/entities/product_strategy_models.dart';
import 'package:founder_os/domain/simulation/engine/game_engine.dart';
import 'package:founder_os/persistence/storage/snapshot_store.dart';
import 'package:founder_os/presentation/shared/widgets/global_time_control_bar.dart';

void main() {
  const engine = GameEngine();

  testWidgets('failed slot load always restarts the simulation clock', (
    tester,
  ) async {
    final store = _FailingSlotStore();
    final controller = GameController(
      snapshotStore: store,
      tickInterval: const Duration(milliseconds: 10),
    );
    try {
      await controller.initialize();
      controller.dispatch(const TogglePause());

      await expectLater(controller.loadFromSlot('slot_1'), throwsStateError);
      final before = controller.state.simulationMinutes;
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 1100)),
      );
      await tester.pump(const Duration(milliseconds: 10));

      expect(controller.state.simulationMinutes, greaterThan(before));
    } finally {
      controller.dispose();
    }
  });

  test('shared launch safely hosts the first basic company website', () {
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
    final product = state.products.single;
    state = state.copyWith(
      products: <Product>[
        product.copyWith(stage: ProductStage.live, developmentProgress: 1),
      ],
    );

    expect(
      state.productServerLoad(state.products.single),
      lessThanOrEqualTo(1.35),
    );
  });

  test('mostly repaid loan grace is not masked by basic-site RAM load', () {
    var base = engine.reduce(
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
    final product = base.products.single;
    base = base.copyWith(
      products: <Product>[
        product.copyWith(stage: ProductStage.live, developmentProgress: 1),
      ],
    );
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
  });

  test('product advantage survives overload penalty before critical stop', () {
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
  });

  testWidgets('global time pill remains one undecorated text block', (
    tester,
  ) async {
    final controller = GameController(
      snapshotStore: _MemoryStore(GameState.initial()),
      startClock: false,
    );
    await controller.initialize();
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: GlobalTimeControlBar(controller: controller)),
      ),
    );

    final timeTexts = find.descendant(
      of: find.byKey(const Key('global-current-time')),
      matching: find.byType(Text),
    );
    expect(timeTexts, findsOneWidget);
    final timeText = tester.widget<Text>(timeTexts);
    expect(timeText.style?.decoration, TextDecoration.none);
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
    'flutter_firebase' => const <String>['dart'],
    'fastapi_react' => const <String>['python', 'typescript'],
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

class _FailingSlotStore implements SnapshotStore, SaveSlotStore {
  GameState? saved;

  @override
  Future<void> clear() async => saved = null;

  @override
  Future<void> deleteSlot(String slotId) async {}

  @override
  Future<List<SaveSlotSummary>> listSlots() async => const <SaveSlotSummary>[];

  @override
  Future<GameState?> load() async => saved;

  @override
  Future<GameState?> loadSlot(String slotId) async {
    throw StateError('damaged slot');
  }

  @override
  Future<void> save(GameState state) async => saved = state;

  @override
  Future<void> saveSlot(String slotId, GameState state) async {}
}

class _MemoryStore implements SnapshotStore {
  _MemoryStore(this.state);

  GameState? state;

  @override
  Future<void> clear() async => state = null;

  @override
  Future<GameState?> load() async => state;

  @override
  Future<void> save(GameState state) async => this.state = state;
}
