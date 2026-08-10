import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:founder_os/application/controllers/game_controller.dart';
import 'package:founder_os/domain/catalog/v17_endgame_catalog.dart';
import 'package:founder_os/domain/entities/game_state.dart';
import 'package:founder_os/domain/entities/models.dart';
import 'package:founder_os/domain/entities/v12_models.dart';
import 'package:founder_os/domain/entities/v17_models.dart';
import 'package:founder_os/persistence/storage/snapshot_store.dart';
import 'package:founder_os/presentation/features/company/company_hub_screen.dart';
import 'package:founder_os/presentation/features/dashboard/founder_dashboard.dart';
import 'package:founder_os/presentation/features/products/product_workspace_screen.dart';
import 'package:founder_os/presentation/features/team/team_screen.dart';

void main() {
  testWidgets('dashboard exposes a dedicated notifications and events tab', (
    tester,
  ) async {
    await _largeSurface(tester);
    final state = GameState.initial().copyWith(
      companyProfile: const FounderCompanyProfile.legacy(),
      onboardingCompleted: true,
      companyNotifications: const <CompanyNotification>[
        CompanyNotification(
          id: 'tax_test',
          kind: CompanyNotificationKind.tax,
          title: 'Скоро налоги',
          body: 'Проверьте резерв.',
          simulationMinutes: 0,
          read: false,
        ),
      ],
    );
    final controller = await _controller(state);
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      MaterialApp(home: FounderDashboard(controller: controller)),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.notifications_outlined).last);
    await tester.pumpAndSettle();
    expect(find.text('События'), findsWidgets);
    expect(find.byKey(const Key('company-notifications')), findsOneWidget);
    expect(find.text('Скоро налоги'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('company events hub fits a narrow iPhone without overflow', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final controller = await _controller(GameState.initial());
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: CompanyHubScreen(controller: controller)),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('company-hub-sections')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('notification hub marks all important events read', (
    tester,
  ) async {
    await _largeSurface(tester);
    final state = GameState.initial().copyWith(
      companyNotifications: const <CompanyNotification>[
        CompanyNotification(
          id: 'legend_test',
          kind: CompanyNotificationKind.legend,
          title: 'Легенда на рынке',
          body: 'Редкое окно.',
          simulationMinutes: 0,
          read: false,
        ),
      ],
    );
    final controller = await _controller(state);
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: CompanyHubScreen(controller: controller)),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('mark-company-notifications-read')));
    await tester.pumpAndSettle();
    expect(controller.state.unreadCompanyNotificationCount, 0);
  });

  testWidgets(
    'opportunity event UI enforces a maximum of three paid product slots',
    (tester) async {
      await _largeSurface(tester);
      final products = <Product>[
        _product('One'),
        _product('Two'),
        _product('Three'),
        _product('Four'),
      ];
      final state = GameState.initial().copyWith(
        cash: 500000000,
        products: products,
        industryEventOpportunities: const <IndustryEventOpportunity>[
          IndustryEventOpportunity(
            id: 'widget_event',
            templateId: 'global_tech_expo',
            availableUntilMinutes: 10000,
            eventAtMinutes: 20000,
          ),
        ],
      );
      final controller = await _controller(state);
      addTearDown(controller.dispose);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: CompanyHubScreen(controller: controller)),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Возможности'));
      await tester.pumpAndSettle();
      final checks = find.byType(CheckboxListTile);
      expect(checks, findsNWidgets(4));
      for (var index = 0; index < 4; index += 1) {
        await tester.tap(checks.at(index));
        await tester.pump();
      }
      expect(find.textContaining('Забронировать 3/3'), findsOneWidget);
    },
  );

  testWidgets(
    'legacy hub contains three world projects and deep AURA OS upgrades',
    (tester) async {
      await _largeSurface(tester);
      final os = V17EndgameCatalog.worldProjectById('world_os');
      final state = GameState.initial().copyWith(
        cash: 500000000000,
        worldProjects: <WorldProjectProgress>[
          WorldProjectProgress(
            projectId: 'world_os',
            completedPhases: os.phaseCosts.length,
            activePhaseCompletesAtMinutes: -1,
            completedUpgradeIds: const <String>[],
            activeUpgradeId: '',
            activeUpgradeCompletesAtMinutes: -1,
          ),
        ],
      );
      final controller = await _controller(state);
      addTearDown(controller.dispose);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: CompanyHubScreen(controller: controller)),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Наследие'));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('world-project-world_os')), findsOneWidget);
      expect(find.byKey(const Key('world-project-free_ai')), findsOneWidget);
      expect(
        find.byKey(const Key('world-project-planet_compute')),
        findsOneWidget,
      );
      expect(find.text('Developer SDK'), findsOneWidget);
      expect(find.text('System AI'), findsOneWidget);
      expect(find.text('App Store'), findsOneWidget);
    },
  );

  testWidgets('team exposes perks legends and resignation counter offer', (
    tester,
  ) async {
    await _largeSurface(tester);
    final candidate = GameState.initial().candidates.firstWhere(
      (item) => !item.isHr,
    );
    final employee = candidate.toEmployee();
    final state = GameState.initial().copyWith(
      cash: 500000000,
      employees: <Employee>[employee],
      pendingEmployeeDepartures: <PendingEmployeeDeparture>[
        PendingEmployeeDeparture(
          employeeId: employee.id,
          createdAtMinutes: 0,
          deadlineMinutes: 3 * 1440,
          requiredRaisePercent: 20,
        ),
      ],
    );
    final controller = await _controller(state);
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: TeamScreen(controller: controller)),
      ),
    );
    await tester.pumpAndSettle();

    final list = find.byKey(const Key('team-screen-list'));
    await _scrollUntilFound(
      tester,
      list: list,
      target: find.byKey(const Key('team-company-perks')),
    );
    expect(find.byKey(const Key('team-company-perks')), findsOneWidget);
    expect(find.byKey(const Key('team-legend-market')), findsOneWidget);
    expect(find.byKey(const Key('team-departure-risks')), findsOneWidget);
    expect(find.byKey(Key('counter-offer-${employee.id}')), findsOneWidget);
  });

  testWidgets(
    'post-release feature shows paid research before implementation',
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

      await tester.tap(find.text('Разработка'));
      await tester.pumpAndSettle();
      await _scrollUntilFound(
        tester,
        list: find.byType(ListView).last,
        target: find.byKey(const Key('post-release-roadmap')),
      );
      await tester.tap(find.textContaining('Функции • установлено').first);
      await tester.pumpAndSettle();
      expect(find.textContaining('R&D:'), findsWidgets);
      expect(
        find.byKey(const Key('research-feature-contact_form')),
        findsOneWidget,
      );
    },
  );
}

GameState _liveWebsite() {
  final base = GameState.initial();
  return base.copyWith(
    cash: 100000000,
    products: <Product>[_product('Widget Web')],
  );
}

Product _product(String name) => Product(
  id: name.toLowerCase().replaceAll(' ', '_'),
  blueprintId: 'company_website',
  name: name,
  category: ProductCategory.saas,
  stage: ProductStage.live,
  frameworkId: 'static_web',
  languageIds: const <String>['html_css'],
  technologyIds: const <String>[],
  featureIds: const <String>['landing_page'],
  developmentProgress: 1,
  users: 20000,
  dau: 2000,
  mau: 12000,
  activationRate: 0.55,
  retention30d: 0.42,
  churnRate: 0.06,
  rating: 4.3,
  speedMs: 240,
  designScore: 80,
  securityScore: 78,
  reliability: 0.99,
  featureCoverage: 0.85,
  qualityScore: 84,
  monthlyRevenue: 1000000,
  monthlyCost: 100000,
  monthlyGrowth: 1000,
  price: 199,
  monetization: MonetizationModel.subscription,
  marketingBudget: 0,
  allocatedCapacityPercent: 30,
  computeMultiplier: 1,
  createdAtMinutes: 0,
  acquired: false,
  brandAwareness: 0.5,
  brandTrust: 0.7,
  releasedAtMinutes: 0,
);

Future<void> _largeSurface(WidgetTester tester) async {
  await tester.binding.setSurfaceSize(const Size(1200, 3600));
  addTearDown(() => tester.binding.setSurfaceSize(null));
}

Future<void> _scrollUntilFound(
  WidgetTester tester, {
  required Finder list,
  required Finder target,
  int maxDrags = 30,
}) async {
  for (
    var attempt = 0;
    attempt < maxDrags && target.evaluate().isEmpty;
    attempt += 1
  ) {
    await tester.drag(list, const Offset(0, -450));
    await tester.pumpAndSettle();
  }
  expect(target, findsOneWidget);
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
