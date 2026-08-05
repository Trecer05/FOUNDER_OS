import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:founder_os/app/app.dart';
import 'package:founder_os/application/controllers/game_controller.dart';
import 'package:founder_os/domain/commands/game_action.dart';
import 'package:founder_os/domain/entities/game_state.dart';
import 'package:founder_os/domain/simulation/engine/game_engine.dart';
import 'package:founder_os/persistence/storage/snapshot_store.dart';
import 'package:founder_os/presentation/features/contracts/contract_detail_screen.dart';
import 'package:founder_os/presentation/features/team/team_screen.dart';

void main() {
  testWidgets('global time controls stay visible on pushed detail route', (
    tester,
  ) async {
    final controller = await _controllerWithContract();
    addTearDown(controller.dispose);
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(FounderOsApp(controller: controller));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('global-time-toggle')), findsOneWidget);

    final navigator = tester.state<NavigatorState>(find.byType(Navigator));
    navigator.push<void>(
      MaterialPageRoute(
        builder: (_) => ContractDetailScreen(
          controller: controller,
          contractId: controller.state.activeContracts.single.id,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(ContractDetailScreen), findsOneWidget);
    expect(find.byKey(const Key('global-time-toggle')), findsOneWidget);
  });

  testWidgets('tutorial is not shown for an existing day seven company', (
    tester,
  ) async {
    final store = _MemorySnapshotStore()
      ..value = GameState.initial().copyWith(
        simulationMinutes: 6 * 1440 + 8 * 60,
        onboardingCompleted: false,
      );
    final controller = GameController(snapshotStore: store, startClock: false);
    addTearDown(controller.dispose);
    await controller.initialize();
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(FounderOsApp(controller: controller));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('tutorial-skip')), findsNothing);
    expect(controller.state.onboardingCompleted, isTrue);
  });

  testWidgets('team average cards do not overflow on narrow iPhone size', (
    tester,
  ) async {
    const engine = GameEngine();
    var state = GameState.initial().copyWith(
      cash: 10000000,
      onboardingCompleted: true,
    );
    state = engine.reduce(state, const HireCandidate('c_anna'));
    state = engine.reduce(state, const HireCandidate('c_daria'));
    final store = _MemorySnapshotStore()..value = state;
    final controller = GameController(snapshotStore: store, startClock: false);
    addTearDown(controller.dispose);
    await controller.initialize();
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: TeamScreen(controller: controller)),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('Средние показатели'), findsOneWidget);
  });

  testWidgets('contract team sheet keeps multiple selections until save', (
    tester,
  ) async {
    final controller = await _controllerWithContract();
    addTearDown(controller.dispose);
    await tester.binding.setSurfaceSize(const Size(430, 932));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final contractId = controller.state.activeContracts.single.id;

    await tester.pumpWidget(
      MaterialApp(
        home: ContractDetailScreen(
          controller: controller,
          contractId: contractId,
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(Key('manage-contract-team-$contractId')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(Key('contract-$contractId-employee-c_anna')));
    await tester.tap(find.byKey(Key('contract-$contractId-employee-c_daria')));
    await tester.pumpAndSettle();

    expect(controller.state.employeesForContract(contractId), isEmpty);
    expect(find.byKey(Key('save-contract-team-$contractId')), findsOneWidget);

    await tester.tap(find.byKey(Key('save-contract-team-$contractId')));
    await tester.pumpAndSettle();
    expect(controller.state.employeesForContract(contractId), hasLength(2));
  });
}

Future<GameController> _controllerWithContract() async {
  const engine = GameEngine();
  var state = GameState.initial().copyWith(
    cash: 10000000,
    onboardingCompleted: true,
  );
  state = engine.reduce(state, const HireCandidate('c_anna'));
  state = engine.reduce(state, const HireCandidate('c_daria'));
  state = engine.reduce(state, const AcceptClientContract('landing_launch'));
  final store = _MemorySnapshotStore()..value = state;
  final controller = GameController(snapshotStore: store, startClock: false);
  await controller.initialize();
  return controller;
}

class _MemorySnapshotStore implements SnapshotStore {
  GameState? value;

  @override
  Future<void> clear() async => value = null;

  @override
  Future<GameState?> load() async => value;

  @override
  Future<void> save(GameState state) async => value = state;
}
