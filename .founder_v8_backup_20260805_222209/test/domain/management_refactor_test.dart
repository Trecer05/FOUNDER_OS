import 'package:flutter_test/flutter_test.dart';
import 'package:founder_os/application/controllers/game_controller.dart';
import 'package:founder_os/domain/commands/game_action.dart';
import 'package:founder_os/domain/entities/game_state.dart';
import 'package:founder_os/domain/entities/models.dart';
import 'package:founder_os/domain/entities/product_evolution_models.dart';
import 'package:founder_os/domain/simulation/engine/game_engine.dart';
import 'package:founder_os/persistence/storage/snapshot_store.dart';

void main() {
  const engine = GameEngine();

  test('live monetization can change only once per 30 game days', () {
    var state = _stateWithProduct(engine);
    final product = state.products.single;
    state = state.copyWith(
      products: <Product>[
        product.copyWith(stage: ProductStage.live, developmentProgress: 1),
      ],
    );

    state = engine.reduce(
      state,
      SetProductMonetization(
        productId: product.id,
        model: MonetizationModel.advertising,
      ),
    );
    expect(
      state.productById(product.id)!.monetization,
      MonetizationModel.advertising,
    );
    expect(state.monetizationCooldownRemainingDays(product.id), 30);

    final tenDaysLater = state.copyWith(
      simulationMinutes: state.simulationMinutes + 10 * 1440,
    );
    final blocked = engine.reduce(
      tenDaysLater,
      SetProductMonetization(
        productId: product.id,
        model: MonetizationModel.subscription,
      ),
    );
    expect(
      blocked.productById(product.id)!.monetization,
      MonetizationModel.advertising,
    );

    final afterCooldown = state.copyWith(
      simulationMinutes: state.simulationMinutes + 31 * 1440,
    );
    final changed = engine.reduce(
      afterCooldown,
      SetProductMonetization(
        productId: product.id,
        model: MonetizationModel.subscription,
      ),
    );
    expect(
      changed.productById(product.id)!.monetization,
      MonetizationModel.subscription,
    );
  });

  test('product and contract teams are exclusive and atomic', () {
    var state = _stateWithProduct(engine);
    state = engine.reduce(state, const HireCandidate('c_anna'));
    state = engine.reduce(state, const HireCandidate('c_daria'));
    state = engine.reduce(state, const AcceptClientContract('landing_launch'));

    final productId = state.products.single.id;
    final contractId = state.activeContracts.single.id;

    state = engine.reduce(
      state,
      SetProductTeam(productId: productId, employeeIds: const ['c_anna']),
    );
    expect(state.employeesForProduct(productId).map((item) => item.id), [
      'c_anna',
    ]);

    state = engine.reduce(
      state,
      SetContractTeam(
        contractId: contractId,
        employeeIds: const ['c_anna', 'c_daria'],
      ),
    );
    expect(state.employeesForProduct(productId), isEmpty);
    expect(
      state.employeesForContract(contractId).map((item) => item.id).toSet(),
      {'c_anna', 'c_daria'},
    );

    state = engine.reduce(
      state,
      SetProductTeam(productId: productId, employeeIds: const ['c_anna']),
    );
    expect(state.employeesForProduct(productId).single.id, 'c_anna');
    expect(state.employeesForContract(contractId).single.id, 'c_daria');
  });

  test('finance history is sampled after crossing a game day', () {
    var state = GameState.initial().copyWith(
      paused: false,
      simulationMinutes: 1439,
    );
    final previousCount = state.financeHistory.length;
    state = engine.reduce(state, const AdvanceTime(1));
    expect(state.financeHistory.length, previousCount + 1);
    expect(
      state.financeHistory.last.simulationMinutes,
      greaterThanOrEqualTo(1440),
    );
  });

  test('snapshot v7 keeps contract teams monetization and finance history', () {
    var state = _stateWithProduct(engine);
    final product = state.products.single;
    state = state.copyWith(
      paused: false,
      products: <Product>[
        product.copyWith(stage: ProductStage.live, developmentProgress: 1),
      ],
      employees: <Employee>[state.candidateById('c_anna')!.toEmployee()],
    );
    state = engine.reduce(state, const AcceptClientContract('landing_launch'));
    state = engine.reduce(
      state,
      SetContractTeam(
        contractId: state.activeContracts.single.id,
        employeeIds: const <String>['c_anna'],
      ),
    );
    state = engine.reduce(
      state,
      SetProductMonetization(
        productId: product.id,
        model: MonetizationModel.advertising,
      ),
    );
    state = state.copyWith(simulationMinutes: 1439);
    state = engine.reduce(state, const AdvanceTime(1));

    final restored = GameState.decode(state.encode());
    expect(restored.snapshotVersion, currentSnapshotVersion);
    expect(restored.contractEmployeeAssignments, hasLength(1));
    expect(restored.monetizationChanges, hasLength(1));
    expect(restored.financeHistory, isNotEmpty);
    expect(restored.financeTransactions, isNotEmpty);
  });

  test('product improvement survives snapshot round trip', () {
    var state = _stateWithProduct(engine);
    final product = state.products.single;
    state = state.copyWith(
      products: <Product>[
        product.copyWith(stage: ProductStage.live, developmentProgress: 1),
      ],
    );
    state = engine.reduce(
      state,
      ApplyProductImprovement(
        productId: product.id,
        type: ProductImprovementType.performance,
      ),
    );

    final restored = GameState.decode(state.encode());
    expect(
      restored.improvementLevel(product.id, ProductImprovementType.performance),
      1,
    );
    expect(restored.latestProductUpdate(product), isNotNull);
  });

  test('serialized controller saves keep the newest state', () async {
    final store = _DelayedSnapshotStore();
    final controller = GameController(snapshotStore: store, startClock: false);
    addTearDown(controller.dispose);
    await controller.initialize();

    controller.dispatch(const CompleteOnboarding());
    controller.dispatch(const SetGameSpeed(GameSpeed.x4));
    await controller.saveNow();

    expect(store.saved, isNotNull);
    expect(store.saved!.onboardingCompleted, isTrue);
    expect(store.saved!.speed, GameSpeed.x4);
    expect(store.saved!.encode(), controller.state.encode());
  });
}

GameState _stateWithProduct(GameEngine engine) => engine.reduce(
  GameState.initial().copyWith(cash: 10000000, onboardingCompleted: true),
  const CreateConfiguredProduct(
    name: 'Nova',
    blueprintId: 'team_saas',
    frameworkId: 'flutter_firebase',
    languageIds: <String>['typescript'],
    technologyIds: <String>['postgresql'],
    featureIds: <String>['realtime_collaboration'],
  ),
);

class _DelayedSnapshotStore implements SnapshotStore {
  GameState? saved;

  @override
  Future<void> clear() async => saved = null;

  @override
  Future<GameState?> load() async => saved;

  @override
  Future<void> save(GameState state) async {
    await Future<void>.delayed(const Duration(milliseconds: 5));
    saved = state;
  }
}
