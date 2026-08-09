import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:founder_os/application/controllers/game_controller.dart';
import 'package:founder_os/application/settings/display_preferences.dart';
import 'package:founder_os/domain/commands/game_action.dart';
import 'package:founder_os/domain/entities/game_state.dart';
import 'package:founder_os/domain/entities/models.dart';
import 'package:founder_os/domain/simulation/engine/game_engine.dart';
import 'package:founder_os/persistence/storage/snapshot_store.dart';
import 'package:founder_os/presentation/features/finance/finance_screen.dart';
import 'package:founder_os/presentation/features/infrastructure/infrastructure_screen.dart';
import 'package:founder_os/presentation/features/products/product_workspace_screen.dart';
import 'package:founder_os/presentation/features/team/team_screen.dart';

void main() {
  setUp(() async {
    await DisplayPreferences.instance.setLanguage(AppLanguage.ru);
  });

  testWidgets('credit button shows an immediate approval or refusal result', (
    tester,
  ) async {
    final controller = await _controller(GameState.initial());
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      MaterialApp(home: FinanceScreen(controller: controller)),
    );
    await tester.pumpAndSettle();
    final loanButton = find.byKey(const Key('request-business-loan'));
    await tester.scrollUntilVisible(
      loanButton,
      320,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(loanButton);
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('credit-result-message')), findsOneWidget);
    expect(find.textContaining('Банк отказал'), findsOneWidget);
  });

  testWidgets('employee card shows productivity and its factors', (
    tester,
  ) async {
    final initial = GameState.initial().copyWith(cash: 1000000);
    const engine = GameEngine();
    final candidate = initial.candidates.firstWhere(
      (item) => !item.isHr && item.remote,
    );
    final state = engine.reduce(initial, HireCandidate(candidate.id));
    expect(state.employees, hasLength(1));
    final employee = state.employees.single;
    final controller = await _controller(state);
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: TeamScreen(controller: controller)),
      ),
    );
    await tester.pumpAndSettle();
    final teamList = find.byKey(const Key('team-screen-list'));
    final employeesTab = find.text('Сотрудники (${state.employees.length})');
    await _dragListUntilHitTestable(
      tester,
      list: teamList,
      target: employeesTab,
    );
    await tester.tap(employeesTab);
    await tester.pumpAndSettle();
    final productivity = find.byKey(
      Key('employee-productivity-${employee.id}'),
    );
    await _dragListUntilHitTestable(
      tester,
      list: teamList,
      target: productivity,
    );

    expect(productivity, findsOneWidget);
    expect(find.text('Текущая продуктивность'), findsOneWidget);
    expect(
      find.textContaining('Назначения без текущей разработки'),
      findsOneWidget,
    );
  });

  testWidgets('owned migration action lives next to compute allocation', (
    tester,
  ) async {
    final controller = await _controller(GameState.initial());
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: InfrastructureScreen(controller: controller)),
      ),
    );
    await tester.pumpAndSettle();
    await tester.drag(
      find.byType(SingleChildScrollView),
      const Offset(-500, 0),
    );
    await tester.pumpAndSettle();
    final allocationTab = find.text('Мощности').hitTestable();
    expect(allocationTab, findsOneWidget);
    await tester.tap(allocationTab);
    await tester.pumpAndSettle();

    expect(
      find.byKey(const Key('owned-migration-capacity-card')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('migrate-to-owned-from-capacity')),
      findsOneWidget,
    );
  });

  testWidgets('workspace restores monetization and has one channel selector', (
    tester,
  ) async {
    const engine = GameEngine();
    var state = engine.reduce(
      GameState.initial().copyWith(cash: 10000000),
      const CreateConfiguredProduct(
        name: 'Service',
        blueprintId: 'team_saas',
        frameworkId: 'next_nest',
        languageIds: <String>['typescript'],
        technologyIds: <String>['postgresql'],
        featureIds: <String>['team_spaces'],
      ),
    );
    final product = state.products.single;
    state = state.copyWith(
      products: <Product>[
        product.copyWith(stage: ProductStage.live, developmentProgress: 1),
      ],
    );
    final controller = await _controller(state);
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: ProductWorkspaceScreen(
          controller: controller,
          productId: product.id,
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Реклама'));
    await tester.pumpAndSettle();

    expect(
      find.byKey(const Key('workspace-monetization-controls')),
      findsOneWidget,
    );
    expect(find.byType(DropdownButtonFormField<String>), findsOneWidget);
    expect(find.text('Прогноз по всем каналам'), findsOneWidget);
  });
}

Future<void> _dragListUntilHitTestable(
  WidgetTester tester, {
  required Finder list,
  required Finder target,
}) async {
  expect(list, findsOneWidget);
  for (var attempt = 0; attempt < 10; attempt += 1) {
    if (target.hitTestable().evaluate().isNotEmpty) {
      return;
    }
    await tester.drag(list, const Offset(0, -280));
    await tester.pumpAndSettle();
  }
  expect(target.hitTestable(), findsOneWidget);
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

  GameState? state;

  @override
  Future<void> clear() async => state = null;

  @override
  Future<GameState?> load() async => state;

  @override
  Future<void> save(GameState value) async => state = value;
}
