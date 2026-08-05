import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:founder_os/app/app.dart';
import 'package:founder_os/application/controllers/game_controller.dart';
import 'package:founder_os/domain/commands/game_action.dart';
import 'package:founder_os/domain/entities/game_state.dart';
import 'package:founder_os/domain/entities/models.dart';
import 'package:founder_os/domain/simulation/engine/game_engine.dart';
import 'package:founder_os/persistence/storage/snapshot_store.dart';
import 'package:founder_os/presentation/features/contracts/contracts_screen.dart';
import 'package:founder_os/presentation/features/operations/operations_screen.dart';
import 'package:founder_os/presentation/features/products/product_detail_screen.dart';
import 'package:founder_os/presentation/features/team/team_screen.dart';

class _MemorySnapshotStore implements SnapshotStore {
  GameState? value;

  @override
  Future<void> clear() async => value = null;

  @override
  Future<GameState?> load() async => value;

  @override
  Future<void> save(GameState state) async => value = state;
}

Future<GameController> _pumpApp(WidgetTester tester) async {
  await tester.binding.setSurfaceSize(const Size(430, 932));
  addTearDown(() => tester.binding.setSurfaceSize(null));

  final controller = GameController(
    snapshotStore: _MemorySnapshotStore(),
    startClock: false,
  );
  addTearDown(controller.dispose);

  await controller.initialize();
  await tester.pumpWidget(
    FounderOsApp(controller: controller, showGlobalTimeControls: false),
  );
  await tester.pumpAndSettle();

  final tutorialSkip = find.byKey(const Key('tutorial-skip'));
  if (tutorialSkip.evaluate().isNotEmpty) {
    await tester.tap(tutorialSkip);
    await tester.pumpAndSettle();
  }

  return controller;
}

void main() {
  testWidgets('player configures a product through the seven-step wizard', (
    tester,
  ) async {
    final controller = await _pumpApp(tester);

    await tester.tap(find.byIcon(Icons.apps_outlined));
    await tester.pumpAndSettle();

    final builderButton = find.byKey(const Key('open-product-builder'));
    expect(builderButton, findsOneWidget);
    await tester.tap(builderButton);
    await tester.pumpAndSettle();

    expect(find.text('Новый проект • 1/7'), findsOneWidget);
    expect(find.text('Что именно строим'), findsOneWidget);
    expect(find.text('Сайт компании'), findsOneWidget);

    for (var step = 0; step < 6; step += 1) {
      final next = find.byKey(const Key('product-wizard-next'));
      expect(next, findsOneWidget);
      await tester.tap(next);
      await tester.pumpAndSettle();
    }

    expect(find.text('Проверка проекта'), findsOneWidget);
    expect(find.textContaining('рабочих часов'), findsWidgets);
    final createButton = find.byKey(const Key('create-configured-product'));
    expect(createButton, findsOneWidget);
    await tester.tap(createButton);
    await tester.pumpAndSettle();

    expect(controller.state.products, hasLength(1));
    expect(controller.state.products.single.name, 'First Landing');
    expect(controller.state.products.single.blueprintId, 'company_website');
    expect(find.text('First Landing'), findsWidgets);
  });

  testWidgets(
    'team screen exposes filters languages and numeric hiring metrics',
    (tester) async {
      await _pumpApp(tester);

      await tester.tap(find.byIcon(Icons.groups_2_outlined));
      await tester.pumpAndSettle();

      expect(find.byType(TeamScreen), findsOneWidget);
      expect(find.text('Средние показатели'), findsOneWidget);

      final teamList = find.byKey(const Key('team-screen-list'));
      final searchField = find.byKey(const Key('team-candidate-search'));
      for (
        var attempt = 0;
        attempt < 12 && searchField.evaluate().isEmpty;
        attempt += 1
      ) {
        await tester.drag(teamList, const Offset(0, -240));
        await tester.pumpAndSettle();
      }

      expect(searchField, findsOneWidget);
      expect(find.text('Все роли'), findsOneWidget);
      await tester.enterText(searchField, 'Анна');
      await tester.pumpAndSettle();

      final candidateName = find.text('Анна Миронова');
      for (
        var attempt = 0;
        attempt < 12 && candidateName.evaluate().isEmpty;
        attempt += 1
      ) {
        await tester.drag(teamList, const Offset(0, -240));
        await tester.pumpAndSettle();
      }

      expect(candidateName, findsOneWidget);
      expect(find.byKey(const Key('hire-c_anna')), findsOneWidget);
      expect(find.textContaining('HTML + CSS'), findsWidgets);
      expect(find.text('78'), findsWidgets);
      expect(find.text('84'), findsWidgets);
    },
  );

  testWidgets('operations screen assigns an employee to a product', (
    tester,
  ) async {
    const engine = GameEngine();
    var state = GameState.initial().copyWith(cash: 10000000);
    state = engine.reduce(
      state,
      const CreateConfiguredProduct(
        name: 'Nova',
        blueprintId: 'ai_assistant',
        frameworkId: 'fastapi_react',
        languageIds: <String>['typescript', 'python'],
        technologyIds: <String>['postgresql', 'vector_db'],
        featureIds: <String>['chat_history', 'file_analysis'],
      ),
    );
    state = engine.reduce(state, const HireCandidate('c_anna'));
    state = engine.reduce(state, const HireCandidate('c_daria'));

    final store = _MemorySnapshotStore()..value = state;
    final controller = GameController(snapshotStore: store, startClock: false);
    addTearDown(controller.dispose);
    await controller.initialize();

    await tester.binding.setSurfaceSize(const Size(430, 932));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MaterialApp(home: OperationsScreen(controller: controller)),
    );
    await tester.pumpAndSettle();

    final productId = controller.state.products.single.id;
    await tester.tap(find.byKey(Key('manage-team-$productId')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(Key('assign-c_anna-to-$productId')));
    await tester.pumpAndSettle();
    expect(find.byKey(Key('save-team-$productId')), findsOneWidget);

    await tester.tap(find.byKey(Key('assign-c_daria-to-$productId')));
    await tester.pumpAndSettle();

    expect(controller.state.employeesForProduct(productId), isEmpty);
    expect(find.byKey(Key('save-team-$productId')), findsOneWidget);

    await tester.tap(find.byKey(Key('save-team-$productId')));
    await tester.pumpAndSettle();

    expect(controller.state.employeesForProduct(productId), hasLength(2));
  });

  testWidgets('overview shows every project from zero progress', (
    tester,
  ) async {
    const engine = GameEngine();
    var state = engine.reduce(
      GameState.initial().copyWith(cash: 10000000, onboardingCompleted: true),
      const CreateConfiguredProduct(
        name: 'Zero Start',
        blueprintId: 'team_saas',
        frameworkId: 'flutter_firebase',
        languageIds: <String>['dart'],
        technologyIds: <String>['postgresql'],
        featureIds: <String>['realtime_collaboration'],
      ),
    );
    final store = _MemorySnapshotStore()..value = state;
    final controller = GameController(snapshotStore: store, startClock: false);
    addTearDown(controller.dispose);
    await controller.initialize();

    await tester.binding.setSurfaceSize(const Size(430, 932));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      FounderOsApp(controller: controller, showGlobalTimeControls: false),
    );
    await tester.pumpAndSettle();

    final projectCard = find.byKey(
      Key('overview-project-${state.products.single.id}'),
    );
    await tester.scrollUntilVisible(
      projectCard,
      320,
      scrollable: find.byType(Scrollable).first,
    );

    expect(projectCard, findsOneWidget);
    expect(find.text('Исследование и требования • 0.0%'), findsOneWidget);
  });

  testWidgets('live subscription product exposes working price control', (
    tester,
  ) async {
    const engine = GameEngine();
    var state = engine.reduce(
      GameState.initial().copyWith(cash: 10000000),
      const CreateConfiguredProduct(
        name: 'Pricing UI',
        blueprintId: 'team_saas',
        frameworkId: 'flutter_firebase',
        languageIds: <String>['dart'],
        technologyIds: <String>['postgresql'],
        featureIds: <String>['realtime_collaboration'],
      ),
    );
    final created = state.products.single;
    state = state.copyWith(
      products: <Product>[
        created.copyWith(stage: ProductStage.live, developmentProgress: 1),
      ],
    );
    final store = _MemorySnapshotStore()..value = state;
    final controller = GameController(snapshotStore: store, startClock: false);
    addTearDown(controller.dispose);
    await controller.initialize();

    await tester.binding.setSurfaceSize(const Size(430, 932));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MaterialApp(
        home: ProductDetailScreen(
          controller: controller,
          productId: created.id,
        ),
      ),
    );
    await tester.pumpAndSettle();

    final priceSlider = find.byKey(const Key('subscription-price-slider'));
    await tester.scrollUntilVisible(
      priceSlider,
      350,
      scrollable: find.byType(Scrollable).first,
    );
    expect(priceSlider, findsOneWidget);

    final slider = tester.widget<Slider>(priceSlider);
    slider.onChangeEnd!(1500);
    await tester.pumpAndSettle();

    expect(controller.state.productById(created.id)!.price, 1500);
  });

  testWidgets('contracts screen accepts a simple client order', (tester) async {
    final store = _MemorySnapshotStore()..value = _releasedWebsiteState();
    final controller = GameController(snapshotStore: store, startClock: false);
    addTearDown(controller.dispose);
    await controller.initialize();

    await tester.binding.setSurfaceSize(const Size(430, 932));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MaterialApp(home: ContractsScreen(controller: controller)),
    );
    await tester.pumpAndSettle();

    final accept = find.byKey(const Key('accept-contract-landing_launch'));
    await tester.scrollUntilVisible(
      accept,
      320,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(accept);
    await tester.pumpAndSettle();

    expect(controller.state.activeContracts, hasLength(1));
    expect(controller.state.activeContracts.single.progress, 0);
  });
}

GameState _releasedWebsiteState() {
  const engine = GameEngine();
  var state = engine.reduce(
    GameState.initial().copyWith(cash: 1000000, onboardingCompleted: true),
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
