import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:founder_os/app/app.dart';
import 'package:founder_os/application/controllers/game_controller.dart';
import 'package:founder_os/application/settings/display_preferences.dart';
import 'package:founder_os/domain/commands/game_action.dart';
import 'package:founder_os/domain/entities/game_state.dart';
import 'package:founder_os/domain/entities/models.dart';
import 'package:founder_os/domain/entities/v12_game_state_extensions.dart';
import 'package:founder_os/domain/entities/v12_models.dart';
import 'package:founder_os/domain/simulation/engine/game_engine.dart';
import 'package:founder_os/persistence/storage/snapshot_store.dart';
import 'package:founder_os/presentation/features/operations/operations_screen.dart';
import 'package:founder_os/presentation/features/products/products_screen.dart';

void main() {
  testWidgets('new company reset clears the entire previous simulation cycle', (
    tester,
  ) async {
    var state = _website(_configuredCompany()).copyWith(
      simulationMinutes: 17 * 1440 + 8 * 60,
      selectedOfficeId: 'garage',
    );
    const engine = GameEngine();
    final candidate = state.candidates.firstWhere((item) => !item.isHr);
    state = engine.reduce(state, HireCandidate(candidate.id));
    expect(state.day, 18);
    expect(state.products, isNotEmpty);
    expect(state.employees, isNotEmpty);

    final store = _MemoryStore(state);
    final controller = GameController(snapshotStore: store, startClock: false);
    await controller.initialize();
    addTearDown(controller.dispose);

    await controller.reset();

    expect(controller.state.day, 1);
    expect(controller.state.simulationMinutes, 8 * 60);
    expect(controller.state.products, isEmpty);
    expect(controller.state.employees, isEmpty);
    expect(controller.state.clientContracts, isEmpty);
    expect(controller.state.employeeAssignments, isEmpty);
    expect(controller.state.contractEmployeeAssignments, isEmpty);
    expect(controller.state.companyProfile.configured, isFalse);
    expect(store.state?.products, isEmpty);
    expect(store.state?.day, 1);
  });

  testWidgets('CEO is pinned automatically in product team management', (
    tester,
  ) async {
    await DisplayPreferences.instance.setLanguage(AppLanguage.ru);
    final state = _website(_configuredCompany());
    final product = state.products.single;
    final controller = GameController(
      snapshotStore: _MemoryStore(state),
      startClock: false,
    );
    await controller.initialize();
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      MaterialApp(home: OperationsScreen(controller: controller)),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(Key('manage-team-${product.id}')));
    await tester.pumpAndSettle();

    expect(find.text('Алекс'), findsWidgets);
    expect(find.textContaining('CEO участвует автоматически'), findsOneWidget);
    expect(find.textContaining('FTE'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('released product does not show active four-stage rail', (
    tester,
  ) async {
    var state = _website(_configuredCompany());
    final created = state.products.single;
    state = state.copyWith(
      products: <Product>[
        created.copyWith(stage: ProductStage.live, developmentProgress: 1),
      ],
    );
    final controller = GameController(
      snapshotStore: _MemoryStore(state),
      startClock: false,
    );
    await controller.initialize();
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      MaterialApp(home: ProductsScreen(controller: controller)),
    );
    await tester.pumpAndSettle();

    expect(
      find.byKey(Key('development-stage-progress-${created.id}')),
      findsNothing,
    );
    expect(find.text('Проектирование'), findsNothing);
    expect(find.text('Отладка'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('project challenge appears as a global once-per-project modal', (
    tester,
  ) async {
    await DisplayPreferences.instance.setLanguage(AppLanguage.ru);
    var state = _website(_configuredCompany());
    final created = state.products.single;
    state = state.copyWith(
      products: <Product>[created.copyWith(developmentProgress: 0.45)],
    );
    final controller = GameController(
      snapshotStore: _MemoryStore(state),
      startClock: false,
    );
    await controller.initialize();
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      FounderOsApp(controller: controller, showGlobalTimeControls: false),
    );
    await tester.pumpAndSettle();

    expect(find.text('Технический вызов проекта'), findsOneWidget);
    expect(find.byKey(const Key('start-project-challenge')), findsOneWidget);
    expect(find.byKey(const Key('skip-project-challenge')), findsOneWidget);

    await tester.tap(find.byKey(const Key('skip-project-challenge')));
    await tester.pumpAndSettle();

    final latest = controller.state.products.single;
    expect(controller.state.projectChallengeHandled(latest), isTrue);
    expect(find.text('Технический вызов проекта'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}

GameState _configuredCompany() {
  const engine = GameEngine();
  return engine
      .reduce(
        GameState.initial(),
        const ConfigureCompany(
          companyName: 'Preflight Labs',
          founderName: 'Алекс',
          logoId: 'company_logo_01',
          startingBudget: 1200000,
          background: FounderBackground.engineer,
          skills: <FounderSkill, int>{
            FounderSkill.engineering: 7,
            FounderSkill.design: 3,
            FounderSkill.product: 4,
            FounderSkill.growth: 2,
            FounderSkill.negotiation: 2,
            FounderSkill.operations: 4,
          },
        ),
      )
      .copyWith(onboardingCompleted: true);
}

GameState _website(GameState state) {
  const engine = GameEngine();
  return engine.reduce(
    state,
    const CreateConfiguredProduct(
      name: 'Preflight Site',
      blueprintId: 'company_website',
      frameworkId: 'static_web',
      languageIds: <String>['html_css'],
      technologyIds: <String>[],
      featureIds: <String>['landing_page'],
    ),
  );
}

class _MemoryStore implements SnapshotStore {
  _MemoryStore(this.state);

  GameState? state;

  @override
  Future<void> clear() async => state = null;

  @override
  Future<GameState?> load() async => state;

  @override
  Future<void> save(GameState value) async => state = value;
}
