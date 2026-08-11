import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:founder_os/application/controllers/game_controller.dart';
import 'package:founder_os/domain/commands/game_action.dart';
import 'package:founder_os/domain/entities/game_state.dart';
import 'package:founder_os/domain/entities/management_models.dart';
import 'package:founder_os/domain/entities/models.dart';
import 'package:founder_os/domain/entities/operations_models.dart';
import 'package:founder_os/domain/entities/v12_models.dart';
import 'package:founder_os/domain/entities/v16_models.dart';
import 'package:founder_os/domain/simulation/engine/game_engine.dart';
import 'package:founder_os/persistence/storage/snapshot_store.dart';
import 'package:founder_os/presentation/features/dashboard/founder_dashboard.dart';
import 'package:founder_os/presentation/features/finance/finance_screen.dart';
import 'package:founder_os/presentation/features/infrastructure/infrastructure_screen.dart';
import 'package:founder_os/presentation/features/products/product_detail_screen.dart';
import 'package:founder_os/presentation/features/products/product_workspace_screen.dart';
import 'package:founder_os/presentation/features/team/team_screen.dart';

void main() {
  testWidgets(
    'monetization guide starts collapsed and uses understandable controls',
    (tester) async {
      await _largeSurface(tester);
      final state = _liveWebsite();
      final controller = await _controller(state);
      addTearDown(controller.dispose);
      await tester.pumpWidget(
        MaterialApp(
          home: ProductWorkspaceScreen(
            controller: controller,
            productId: state.products.single.id,
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Монетизация'));
      await tester.pumpAndSettle();

      expect(
        find.byKey(const Key('workspace-monetization-guide-expansion')),
        findsOneWidget,
      );
      expect(find.text('Интенсивность монетизации'), findsNothing);
      expect(find.text('Жёсткость paywall'), findsOneWidget);
      expect(find.text('Удовлетворённость'), findsWidgets);
      expect(find.text('Конверсия в оплату'), findsOneWidget);
      expect(find.text('Ожидаемая выручка'), findsOneWidget);

      await tester.tap(find.text('Справочник по моделям монетизации'));
      await tester.pumpAndSettle();
      expect(
        find.textContaining('Subscription — повторяющаяся'),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'legacy incompatible monetization opens product detail without dropdown assertion',
    (tester) async {
      await _largeSurface(tester);
      final state = _liveWebsite();
      final controller = await _controller(state);
      addTearDown(controller.dispose);
      await tester.pumpWidget(
        MaterialApp(
          home: ProductDetailScreen(
            controller: controller,
            productId: state.products.single.id,
          ),
        ),
      );
      await tester.pumpAndSettle();
      await _scrollUntilFound(
        tester,
        list: find.byType(ListView).last,
        target: find.text('Монетизация и маркетинг'),
      );

      expect(tester.takeException(), isNull);
      expect(find.text('Монетизация и маркетинг'), findsOneWidget);
    },
  );

  testWidgets('marketing exposes always-on monthly channels and stop action', (
    tester,
  ) async {
    await _largeSurface(tester);
    var state = _liveWebsite();
    const engine = GameEngine();
    final product = state.products.single;
    state = engine.reduce(
      state,
      StartAdvertisingCampaign(
        productId: product.id,
        agencyId: 'signal_labs',
        channelId: 'search_ads',
        budget: 300000,
      ),
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

    expect(find.textContaining('Бюджет / мес.'), findsWidgets);
    expect(find.text('Включить рекламный канал'), findsOneWidget);
    expect(find.text('Остановить канал'), findsOneWidget);
    expect(find.textContaining('7 дней'), findsNothing);
  });

  testWidgets(
    'product workspace survives rapid section switching without retained subtree assertions',
    (tester) async {
      await _largeSurface(tester);
      final state = _liveWebsite();
      final controller = await _controller(state);
      addTearDown(controller.dispose);
      await tester.pumpWidget(
        MaterialApp(
          home: ProductWorkspaceScreen(
            controller: controller,
            productId: state.products.single.id,
          ),
        ),
      );
      await tester.pumpAndSettle();

      for (final section in <String>[
        'monetization',
        'marketing',
        'infrastructure',
        'metrics',
        'team',
        'overview',
      ]) {
        final target = find.byKey(Key('workspace-section-$section'));
        expect(target, findsOneWidget);
        await tester.ensureVisible(target);
        await tester.tap(target);
        await tester.pump(const Duration(milliseconds: 30));
        expect(tester.takeException(), isNull);
      }
    },
  );

  testWidgets(
    'senior has no ordinary course and remote employee can relocate',
    (tester) async {
      await _largeSurface(tester);
      final base = GameState.initial();
      final candidates = base.candidates
          .where((item) => item.remote && !item.isHr)
          .take(2)
          .toList();
      final senior = candidates[0].toEmployee().managedCopyWith(
        skill: 90,
        grade: EmployeeGrade.senior,
      );
      final junior = candidates[1].toEmployee().managedCopyWith(
        skill: 55,
        grade: EmployeeGrade.junior,
      );
      final office = OwnedOfficeSite(
        id: 'office_test',
        cityId: 'warsaw',
        size: FacilitySize.small,
        fitoutQuality: FacilityQuality.standard,
        equipmentQuality: FacilityQuality.standard,
        builtAtMinutes: 0,
      );
      final state = base.copyWith(
        cash: 10000000,
        employees: <Employee>[senior, junior],
        ownedOffices: <OwnedOfficeSite>[office],
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

      await _scrollUntilFound(
        tester,
        list: find.byKey(const Key('team-screen-list')),
        target: find.byKey(Key('senior-development-${senior.id}')),
      );
      expect(find.byKey(Key('train-${senior.id}')), findsNothing);
      expect(
        find.byKey(Key('senior-development-${senior.id}')),
        findsOneWidget,
      );

      await _scrollUntilFound(
        tester,
        list: find.byKey(const Key('team-screen-list')),
        target: find.byKey(Key('relocate-${junior.id}')),
      );
      expect(find.byKey(Key('relocate-${junior.id}')), findsOneWidget);
    },
  );

  testWidgets(
    'owned office and data-center cards fit narrow iPhone and are numbered',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(390, 844));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final state = GameState.initial().copyWith(
        cash: 500000000,
        ownedOffices: const <OwnedOfficeSite>[
          OwnedOfficeSite(
            id: 'office_1',
            cityId: 'warsaw',
            size: FacilitySize.campus,
            fitoutQuality: FacilityQuality.premium,
            equipmentQuality: FacilityQuality.premium,
            builtAtMinutes: 0,
          ),
        ],
        ownedDataCenters: const <OwnedDataCenterSite>[
          OwnedDataCenterSite(
            id: 'dc_1',
            cityId: 'bangalore',
            size: FacilitySize.campus,
            facilityQuality: FacilityQuality.premium,
            equipmentQuality: FacilityQuality.premium,
            builtAtMinutes: 0,
          ),
        ],
      );
      final controller = await _controller(state);
      addTearDown(controller.dispose);
      await tester.pumpWidget(
        MaterialApp(home: InfrastructureScreen(controller: controller)),
      );
      await tester.pumpAndSettle();

      for (final tab in <String>[
        'hosting',
        'offices',
        'rooms',
        'hardware',
        'allocation',
      ]) {
        final target = find.byKey(Key('infra-tab-$tab'));
        expect(target, findsOneWidget);
        final rect = tester.getRect(target);
        expect(rect.left, greaterThanOrEqualTo(0));
        expect(rect.right, lessThanOrEqualTo(390));
      }
      final officesTab = find.byKey(const Key('infra-tab-offices'));
      final roomsTab = find.byKey(const Key('infra-tab-rooms'));

      await tester.tap(officesTab);
      await tester.pumpAndSettle();
      expect(find.textContaining('Офис #1'), findsOneWidget);
      expect(tester.takeException(), isNull);

      await tester.tap(roomsTab);
      await tester.pumpAndSettle();
      expect(find.textContaining('ЦОД #1'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('team averages stay visible at the top on narrow iPhone', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final controller = await _controller(GameState.initial());
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: TeamScreen(controller: controller)),
      ),
    );
    await tester.pumpAndSettle();

    final title = find.text('Средние показатели');
    expect(title, findsOneWidget);
    expect(tester.getRect(title).bottom, lessThanOrEqualTo(844));
    expect(tester.takeException(), isNull);
  });

  testWidgets('dashboard bottom navigation remains tappable at 800 by 600', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(800, 600));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final state = GameState.initial().copyWith(
      companyProfile: const FounderCompanyProfile.legacy(),
      onboardingCompleted: true,
    );
    final controller = await _controller(state);
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      MaterialApp(home: FounderDashboard(controller: controller)),
    );
    await tester.pumpAndSettle();

    final infrastructure = find.text('Инфра').last;
    expect(infrastructure, findsOneWidget);
    final infrastructureRect = tester.getRect(infrastructure);
    expect(infrastructureRect.top, greaterThanOrEqualTo(0));
    expect(infrastructureRect.bottom, lessThanOrEqualTo(600));
    await tester.tap(infrastructure);
    await tester.pumpAndSettle();
    expect(find.byType(InfrastructureScreen), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'dashboard survives rapid tab switching without inherited dependents assertion',
    (tester) async {
      await _largeSurface(tester);
      final state = GameState.initial().copyWith(
        companyProfile: const FounderCompanyProfile.legacy(),
        onboardingCompleted: true,
      );
      final controller = await _controller(state);
      addTearDown(controller.dispose);
      await tester.pumpWidget(
        MaterialApp(home: FounderDashboard(controller: controller)),
      );
      await tester.pumpAndSettle();

      for (final icon in <IconData>[
        Icons.apps_outlined,
        Icons.groups_2_outlined,
        Icons.dns_outlined,
        Icons.notifications_outlined,
        Icons.grid_view_rounded,
        Icons.space_dashboard_outlined,
      ]) {
        final target = find.byIcon(icon);
        expect(target, findsWidgets);
        await tester.tap(target.last);
        await tester.pump(const Duration(milliseconds: 50));
        expect(tester.takeException(), isNull);
      }
    },
  );

  testWidgets(
    'finance history can be scrubbed by finger and shows selected detail',
    (tester) async {
      await _largeSurface(tester);
      final history = <FinanceHistoryPoint>[
        const FinanceHistoryPoint(
          simulationMinutes: 0,
          cash: 1000000,
          incomeRunRate: 0,
          expenseRunRate: 100000,
          profitRunRate: -100000,
        ),
        const FinanceHistoryPoint(
          simulationMinutes: 1440,
          cash: 1300000,
          incomeRunRate: 500000,
          expenseRunRate: 150000,
          profitRunRate: 350000,
        ),
      ];
      final controller = await _controller(
        GameState.initial().copyWith(financeHistory: history),
      );
      addTearDown(controller.dispose);
      await tester.pumpWidget(
        MaterialApp(home: FinanceScreen(controller: controller)),
      );
      await tester.pumpAndSettle();

      await _scrollUntilFound(
        tester,
        list: find.byType(ListView).last,
        target: find.byKey(const Key('finance-history-chart')),
      );
      final chart = find.byKey(const Key('finance-history-chart'));
      await tester.drag(chart, const Offset(-120, 0));
      await tester.pumpAndSettle();

      expect(
        find.byKey(const Key('finance-history-selection')),
        findsOneWidget,
      );
      expect(find.textContaining('проведите пальцем'), findsOneWidget);
    },
  );
}

GameState _liveWebsite() {
  const engine = GameEngine();
  var state = engine.reduce(
    GameState.initial().copyWith(cash: 10000000),
    const RentHostingPlan('shared_launch'),
  );
  state = engine.reduce(
    state,
    const CreateConfiguredProduct(
      name: 'Widget Web',
      blueprintId: 'company_website',
      frameworkId: 'static_web',
      languageIds: <String>['html_css'],
      technologyIds: <String>[],
      featureIds: <String>['landing_page'],
    ),
  );
  final product = state.products.single.copyWith(
    stage: ProductStage.live,
    developmentProgress: 1,
    users: 20000,
    mau: 12000,
    dau: 2000,
    monetization: MonetizationModel.subscription,
    price: 199,
    releasedAtMinutes: state.simulationMinutes,
  );
  return state.copyWith(products: <Product>[product]);
}

Future<void> _scrollUntilFound(
  WidgetTester tester, {
  required Finder list,
  required Finder target,
  int maxDrags = 30,
}) async {
  expect(list, findsOneWidget);
  for (
    var attempt = 0;
    attempt < maxDrags && target.evaluate().isEmpty;
    attempt += 1
  ) {
    await tester.drag(list, const Offset(0, -420));
    await tester.pumpAndSettle();
  }
  expect(target, findsOneWidget);
}

Future<void> _largeSurface(WidgetTester tester) async {
  await tester.binding.setSurfaceSize(const Size(1200, 3200));
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
