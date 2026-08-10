import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:founder_os/application/controllers/game_controller.dart';
import 'package:founder_os/domain/entities/game_state.dart';
import 'package:founder_os/persistence/storage/snapshot_store.dart';
import 'package:founder_os/presentation/features/finance/finance_screen.dart';
import 'package:founder_os/presentation/features/infrastructure/infrastructure_screen.dart';
import 'package:founder_os/presentation/features/onboarding/company_setup_dialog.dart';
import 'package:founder_os/presentation/features/team/team_screen.dart';

void main() {
  testWidgets('new company setup exposes headquarters city choice', (
    tester,
  ) async {
    await _largeSurface(tester);
    final controller = await _controller(GameState.initial());
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => TextButton(
            key: const Key('open-company-setup-test'),
            onPressed: () => showCompanySetup(context, controller),
            child: const Text('open'),
          ),
        ),
      ),
    );
    await tester.tap(find.byKey(const Key('open-company-setup-test')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('company-headquarters-city')), findsOneWidget);
  });

  testWidgets('team screen exposes bulk development controls', (tester) async {
    await _largeSurface(tester);
    final candidates = GameState.initial().candidates
        .where((item) => item.remote && !item.isHr)
        .take(2)
        .toList(growable: false);
    final state = GameState.initial().copyWith(
      cash: 10000000,
      employees: candidates.map((item) => item.toEmployee()).toList(),
    );
    final controller = await _controller(state);
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: TeamScreen(controller: controller)),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Сотрудники (${state.employees.length})'));
    await tester.pumpAndSettle();

    await _scrollListUntilFound(
      tester,
      list: find.byKey(const Key('team-screen-list')),
      target: find.byKey(const Key('team-development-controls')),
    );

    expect(find.byKey(const Key('team-development-controls')), findsOneWidget);
    expect(find.byKey(const Key('team-select-all-visible')), findsOneWidget);
    expect(find.byKey(const Key('team-bulk-course-selector')), findsOneWidget);
    expect(find.byKey(const Key('team-target-grade-selector')), findsOneWidget);
  });

  testWidgets('infrastructure exposes owned office and data-center builders', (
    tester,
  ) async {
    await _largeSurface(tester);
    final controller = await _controller(
      GameState.initial().copyWith(cash: 500000000),
    );
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      MaterialApp(home: InfrastructureScreen(controller: controller)),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Офисы'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('build-owned-office')), findsOneWidget);

    await tester.tap(find.text('Серверные'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('build-owned-datacenter')), findsOneWidget);
  });

  testWidgets('finance shows annual tax reserve before payment', (
    tester,
  ) async {
    await _largeSurface(tester);
    final controller = await _controller(
      GameState.initial().copyWith(
        taxYearRevenueAccrued: 5000000,
        taxYearExpensesAccrued: 2000000,
        taxYearPayrollAccrued: 1000000,
      ),
    );
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      MaterialApp(home: FinanceScreen(controller: controller)),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('annual-tax-summary')), findsOneWidget);
  });
}

Future<void> _scrollListUntilFound(
  WidgetTester tester, {
  required Finder list,
  required Finder target,
  int maxDrags = 24,
}) async {
  expect(list, findsOneWidget);
  for (var attempt = 0; attempt < maxDrags; attempt += 1) {
    if (target.evaluate().isNotEmpty) return;
    await tester.drag(list, const Offset(0, -420));
    await tester.pumpAndSettle();
  }
  expect(
    target,
    findsOneWidget,
    reason: 'Target was not reached after $maxDrags Team list scrolls.',
  );
}

Future<void> _largeSurface(WidgetTester tester) async {
  await tester.binding.setSurfaceSize(const Size(1200, 3000));
  addTearDown(() => tester.binding.setSurfaceSize(null));
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
