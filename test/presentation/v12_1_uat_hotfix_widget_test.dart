import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:founder_os/app/app.dart';
import 'package:founder_os/application/controllers/game_controller.dart';
import 'package:founder_os/application/localization/app_localizer.dart';
import 'package:founder_os/application/settings/display_preferences.dart';
import 'package:founder_os/domain/commands/game_action.dart';
import 'package:founder_os/domain/entities/game_state.dart';
import 'package:founder_os/domain/entities/models.dart';
import 'package:founder_os/domain/entities/v12_models.dart';
import 'package:founder_os/domain/simulation/engine/game_engine.dart';
import 'package:founder_os/persistence/storage/snapshot_store.dart';
import 'package:founder_os/presentation/features/products/create_product_screen.dart';
import 'package:founder_os/presentation/shared/widgets/development_stage_progress_rail.dart';

void main() {
  testWidgets('reset starts company and CEO setup again', (tester) async {
    await DisplayPreferences.instance.setLanguage(AppLanguage.ru);
    final initial = GameState.initial().copyWith(
      onboardingCompleted: true,
      companyProfile: const FounderCompanyProfile.legacy(),
    );
    final controller = GameController(
      snapshotStore: _MemoryStore(initial),
      startClock: false,
    );
    await controller.initialize();
    addTearDown(controller.dispose);

    await tester.pumpWidget(FounderOsApp(controller: controller));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('company-name-field')), findsNothing);

    await controller.reset();
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('company-name-field')), findsOneWidget);
    expect(find.byKey(const Key('founder-name-field')), findsOneWidget);

    final setupList = find.byType(ListView).last;
    final logoGrid = find.byKey(const Key('company-logo-grid'));
    await _scrollUntilFound(tester, target: logoGrid, scrollable: setupList);
    expect(logoGrid, findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('four development stages are visible on narrow phone', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final state = _developmentState(progress: 0.50);
    final product = state.products.single;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(12),
            child: DevelopmentStageProgressRail(
              state: state,
              product: product,
              compact: true,
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Проектирование'), findsOneWidget);
    expect(find.text('Дизайн'), findsOneWidget);
    expect(find.text('Разработка'), findsOneWidget);
    expect(find.text('Отладка'), findsOneWidget);
    expect(find.textContaining('Сейчас: Разработка'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'project review shows selected stack payroll and compute on phone',
    (tester) async {
      await DisplayPreferences.instance.setLanguage(AppLanguage.ru);
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final state = _configuredCompanyState();
      final controller = GameController(
        snapshotStore: _MemoryStore(state),
        startClock: false,
      );
      await controller.initialize();
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        MaterialApp(home: CreateProductScreen(controller: controller)),
      );
      await tester.pumpAndSettle();

      for (var step = 0; step < 6; step += 1) {
        final next = find.byKey(const Key('product-wizard-next'));
        expect(next, findsOneWidget);
        await tester.tap(next);
        await tester.pumpAndSettle();
      }

      expect(find.text('Проверка проекта'), findsOneWidget);
      final summaryList = find.byType(ListView).last;

      final cost = find.text('Ориентировочная стоимость разработки');
      await _scrollUntilFound(tester, target: cost, scrollable: summaryList);
      expect(cost, findsOneWidget);

      final compute = find.text('Мощность инфраструктуры');
      await _scrollUntilFound(tester, target: compute, scrollable: summaryList);
      expect(compute, findsOneWidget);

      final languages = find.text('Языки');
      await _scrollUntilFound(
        tester,
        target: languages,
        scrollable: summaryList,
      );
      expect(languages, findsOneWidget);
      expect(find.textContaining('HTML'), findsWidgets);

      final technologies = find.text('Технологии');
      await _scrollUntilFound(
        tester,
        target: technologies,
        scrollable: summaryList,
      );
      expect(technologies, findsOneWidget);
      expect(find.text('Не выбраны'), findsOneWidget);

      final specialists = find.text('Нужные специалисты');
      await _scrollUntilFound(
        tester,
        target: specialists,
        scrollable: summaryList,
      );
      expect(specialists, findsOneWidget);
      expect(find.textContaining('База масштаба'), findsNothing);
      expect(find.textContaining('динамический лимит'), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  test('Russian UI translations cover UAT terms', () {
    expect(AppLocalizer.toRussian('Capacity'), 'Мощность разработки');
    expect(AppLocalizer.toRussian('Security'), 'Безопасность');
    expect(AppLocalizer.toRussian('Incident multiplier'), 'Коэффициент риска');
    expect(AppLocalizer.toRussian('Setup'), 'Разовая настройка');
    expect(AppLocalizer.toRussian('Users'), 'Пользователи');
    expect(AppLocalizer.toRussian('Rating'), 'Рейтинг');
    expect(AppLocalizer.toRussian('Load'), 'Загрузка');
    expect(AppLocalizer.toRussian('Fresh'), 'Свежесть');
    expect(AppLocalizer.toRussian('Secure SDLC'), 'Безопасный SDLC');
    expect(
      AppLocalizer.toRussian('SAST + dependency scanning'),
      'SAST + сканирование зависимостей',
    );
  });
}

Future<void> _scrollUntilFound(
  WidgetTester tester, {
  required Finder target,
  required Finder scrollable,
  int maxDrags = 24,
}) async {
  for (
    var attempt = 0;
    attempt < maxDrags && target.evaluate().isEmpty;
    attempt += 1
  ) {
    expect(scrollable, findsOneWidget);
    await tester.drag(scrollable, const Offset(0, -260));
    await tester.pumpAndSettle();
  }
  expect(target, findsWidgets);
}

GameState _configuredCompanyState() {
  const engine = GameEngine();
  return engine
      .reduce(
        GameState.initial(),
        const ConfigureCompany(
          companyName: 'UAT Labs',
          founderName: 'Алекс',
          logoId: 'company_logo_01',
          startingBudget: 1200000,
          background: FounderBackground.engineer,
          skills: <FounderSkill, int>{
            FounderSkill.engineering: 4,
            FounderSkill.design: 2,
            FounderSkill.product: 2,
            FounderSkill.growth: 1,
            FounderSkill.negotiation: 1,
            FounderSkill.operations: 2,
          },
        ),
      )
      .copyWith(onboardingCompleted: true);
}

GameState _developmentState({required double progress}) {
  const engine = GameEngine();
  var state = engine.reduce(
    GameState.initial(),
    const ConfigureCompany(
      companyName: 'UAT Labs',
      founderName: 'Alex',
      logoId: 'company_logo_01',
      startingBudget: 750000,
      background: FounderBackground.engineer,
      skills: <FounderSkill, int>{
        FounderSkill.engineering: 4,
        FounderSkill.design: 2,
        FounderSkill.product: 2,
        FounderSkill.growth: 1,
        FounderSkill.negotiation: 1,
        FounderSkill.operations: 2,
      },
    ),
  );
  state = engine.reduce(
    state,
    const CreateConfiguredProduct(
      name: 'Stage Test',
      blueprintId: 'company_website',
      frameworkId: 'static_web',
      languageIds: <String>['html_css'],
      technologyIds: <String>[],
      featureIds: <String>['landing_page'],
    ),
  );
  return state.copyWith(
    onboardingCompleted: true,
    products: <Product>[
      state.products.single.copyWith(developmentProgress: progress),
    ],
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
