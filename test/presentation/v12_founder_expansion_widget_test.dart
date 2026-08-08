import 'package:flutter/material.dart';
import 'package:founder_os/app/app.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:founder_os/application/controllers/game_controller.dart';
import 'package:founder_os/application/localization/app_localizer.dart';
import 'package:founder_os/application/settings/display_preferences.dart';
import 'package:founder_os/domain/commands/game_action.dart';
import 'package:founder_os/domain/entities/game_state.dart';
import 'package:founder_os/domain/entities/models.dart';
import 'package:founder_os/domain/entities/product_evolution_models.dart';
import 'package:founder_os/domain/entities/v12_models.dart';
import 'package:founder_os/domain/simulation/engine/game_engine.dart';
import 'package:founder_os/persistence/storage/snapshot_store.dart';
import 'package:founder_os/presentation/features/products/product_development_experience.dart';
import 'package:founder_os/presentation/features/products/product_detail_screen.dart';
import 'package:founder_os/presentation/shared/widgets/company_logo.dart';

void main() {
  testWidgets('company logo asset renders without exception', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(child: CompanyLogo(logoId: 'company_logo_25', size: 80)),
        ),
      ),
    );
    await tester.pump();
    expect(find.byType(Image), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('new game opens company setup before the tutorial', (
    tester,
  ) async {
    await DisplayPreferences.instance.setLanguage(AppLanguage.ru);
    final controller = GameController(
      snapshotStore: _MemoryStore(GameState.initial()),
      startClock: false,
    );
    await controller.initialize();
    addTearDown(controller.dispose);

    await tester.pumpWidget(FounderOsApp(controller: controller));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('company-name-field')), findsOneWidget);
    expect(find.byKey(const Key('founder-name-field')), findsOneWidget);

    final setupList = find.byType(ListView).last;
    final logoGridFinder = find.byKey(const Key('company-logo-grid'));

    await _scrollUntilFound(
      tester,
      target: logoGridFinder,
      scrollable: setupList,
    );

    expect(logoGridFinder, findsOneWidget);

    final logoGrid = tester.widget<GridView>(logoGridFinder);
    final logoDelegate = logoGrid.childrenDelegate;

    expect(logoDelegate, isA<SliverChildBuilderDelegate>());
    expect(
      (logoDelegate as SliverChildBuilderDelegate).estimatedChildCount,
      25,
    );
    expect(find.byType(CompanyLogo), findsWidgets);

    final createButton = find.byKey(const Key('create-company-button'));

    await _scrollUntilFound(
      tester,
      target: createButton,
      scrollable: setupList,
    );

    expect(createButton, findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('development stage experience fits narrow iPhone width', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final controller = await _controller();
    addTearDown(controller.dispose);
    final product = controller.state.products.single;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: ProductDevelopmentExperience(
              controller: controller,
              product: product,
            ),
          ),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.byKey(const Key('v12-development-experience')), findsOneWidget);
    expect(find.byKey(const Key('development-mini-game')), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'technical improvement renders immediately without Bad state No element',
    (tester) async {
      const engine = GameEngine();
      var state = await _configuredState();
      final product = state.products.single;
      state = state.copyWith(
        products: <Product>[
          product.copyWith(
            stage: ProductStage.live,
            developmentProgress: 1,
            allocatedCapacityPercent: 30,
          ),
        ],
      );
      state = engine.reduce(
        state,
        ApplyProductImprovement(
          productId: product.id,
          type: ProductImprovementType.performance,
        ),
      );
      final controller = GameController(
        snapshotStore: _MemoryStore(state),
        startClock: false,
      );
      await controller.initialize();
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        MaterialApp(
          home: ProductDetailScreen(
            controller: controller,
            productId: product.id,
          ),
        ),
      );
      await tester.pumpAndSettle();

      final improvementTitle = find.textContaining('Оптимизация скорости');

      await _scrollUntilFound(
        tester,
        target: improvementTitle,
        scrollable: find.byType(ListView).first,
      );

      expect(improvementTitle, findsWidgets);
      expect(tester.takeException(), isNull);
    },
  );

  test('English lexicon translates common full-screen terminology', () {
    expect(AppLocalizer.toEnglish('Аренда офиса'), 'Office rental');
    expect(
      AppLocalizer.toEnglish('Что сейчас делает команда'),
      'What the team is doing now',
    );
    expect(AppLocalizer.toRussian('Hiring'), 'Бонус к найму');
    expect(AppLocalizer.toRussian('Frontend'), 'Frontend');
    expect(AppLocalizer.toRussian('Backend'), 'Backend');
  });

  testWidgets('English locale rebuilds navigation and full feature screens', (
    tester,
  ) async {
    await DisplayPreferences.instance.setLanguage(AppLanguage.en);
    addTearDown(() => DisplayPreferences.instance.setLanguage(AppLanguage.ru));
    final controller = await _controller();
    addTearDown(controller.dispose);

    await tester.pumpWidget(FounderOsApp(controller: controller));
    await tester.pumpAndSettle();

    expect(find.text('Overview'), findsWidgets);
    expect(find.text('Products'), findsWidgets);
    expect(find.text('Team'), findsWidgets);
    expect(find.text('Infrastructure'), findsWidgets);
    expect(find.text('More'), findsWidgets);

    final pendingChallenge = find.byKey(const Key('skip-project-challenge'));
    if (pendingChallenge.evaluate().isNotEmpty) {
      await tester.tap(pendingChallenge);
      await tester.pumpAndSettle();
    }

    await tester.tap(find.text('Infrastructure').last);
    await tester.pumpAndSettle();
    expect(find.text('Infrastructure'), findsWidgets);
    expect(find.text('Offices'), findsWidgets);

    await tester.tap(find.text('More').last);
    await tester.pumpAndSettle();

    expect(find.text('Strategy'), findsWidgets);

    final languageSection = find.text('Language and currency');

    await _scrollUntilFound(
      tester,
      target: languageSection,
      scrollable: find.byType(ListView).last,
    );

    expect(languageSection, findsWidgets);
    expect(tester.takeException(), isNull);
  });

  test('twenty five logo ids map to distinct transparent asset paths', () {
    final paths = <String>{
      for (var i = 1; i <= 25; i += 1)
        CompanyLogo.assetFor('company_logo_${i.toString().padLeft(2, '0')}'),
    };
    expect(paths, hasLength(25));
    expect(paths.every((path) => path.endsWith('.png')), isTrue);
  });
}

Future<void> _scrollUntilFound(
  WidgetTester tester, {
  required Finder target,
  required Finder scrollable,
  int maxDrags = 30,
  double dragDistance = 450,
}) async {
  for (
    var attempt = 0;
    attempt < maxDrags && target.evaluate().isEmpty;
    attempt += 1
  ) {
    expect(scrollable, findsOneWidget);

    await tester.drag(scrollable, Offset(0, -dragDistance));
    await tester.pumpAndSettle();
  }

  expect(
    target,
    findsWidgets,
    reason: 'Target was not reached after $maxDrags scroll attempts.',
  );
}

Future<GameState> _configuredState() async {
  const engine = GameEngine();
  var state = engine.reduce(
    GameState.initial(),
    const ConfigureCompany(
      companyName: 'Widget Labs',
      founderName: 'Alex',
      logoId: 'company_logo_04',
      startingBudget: 750000,
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
  );
  state = engine.reduce(
    state,
    const CreateConfiguredProduct(
      name: 'Widget Product',
      blueprintId: 'company_website',
      frameworkId: 'static_web',
      languageIds: <String>['html_css'],
      technologyIds: <String>[],
      featureIds: <String>['landing_page'],
    ),
  );
  state = state.copyWith(
    products: <Product>[
      state.products.single.copyWith(developmentProgress: 0.50),
    ],
  );
  return state.copyWith(onboardingCompleted: true);
}

Future<GameController> _controller() async {
  final controller = GameController(
    snapshotStore: _MemoryStore(await _configuredState()),
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
