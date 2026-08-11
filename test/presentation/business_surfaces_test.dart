import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:founder_os/application/settings/display_preferences.dart';
import 'package:founder_os/domain/catalog/contract_catalog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:founder_os/domain/entities/game_state.dart';
import 'package:founder_os/domain/entities/v17_models.dart';
import 'package:founder_os/presentation/features/contracts/contracts_screen.dart';
import 'package:founder_os/presentation/features/finance/finance_screen.dart';
import 'package:founder_os/presentation/features/products/product_workspace_screen.dart';
import 'package:founder_os/presentation/features/research/research_screen.dart';
import 'package:founder_os/presentation/shared/widgets/formatters.dart';

import '../support/fixtures.dart';
import '../support/widget_harness.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final preferences = DisplayPreferences.instance;
    await preferences.initialize();
    await preferences.setLanguage(AppLanguage.ru);
    await preferences.setCurrency(DisplayCurrency.rub);
  });

  testWidgets('R&D screen shows research price before player starts it', (
    tester,
  ) async {
    final controller = await controllerFor(
      GameState.initial().copyWith(cash: 100000000),
    );
    addTearDown(controller.dispose);
    await tester.binding.setSurfaceSize(const Size(900, 1200));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MaterialApp(home: ResearchScreen(controller: controller)),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('research-screen-list')), findsOneWidget);
    expect(
      find.byKey(const Key('research-screen-technology-redis')),
      findsOneWidget,
    );
    final cost = controller.state.researchCost(
      ResearchTargetKind.technology,
      'redis',
    );
    expect(find.textContaining(money(cost)), findsWidgets);
  });

  testWidgets('credit flow shows amount and approval risk before result', (
    tester,
  ) async {
    final controller = await controllerFor(GameState.initial());
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

    expect(find.text('Запрос бизнес-кредита'), findsOneWidget);
    expect(find.text('Шанс одобрения'), findsOneWidget);
    expect(find.text('Сумма кредита'), findsOneWidget);

    await tester.tap(find.text('Отправить заявку'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('credit-result-message')), findsOneWidget);
  });

  testWidgets('contracts screen accepts bootstrap client order', (
    tester,
  ) async {
    final controller = await controllerFor(liveWebsiteState(cash: 1000000));
    addTearDown(controller.dispose);
    await tester.binding.setSurfaceSize(const Size(430, 932));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MaterialApp(home: ContractsScreen(controller: controller)),
    );
    await tester.pumpAndSettle();

    expect(controller.state.contractsUnlocked, isTrue);
    final state = controller.state;
    final offer = ContractCatalog.weeklyOffers(
      seed: state.rngSeed,
      week: state.simulationMinutes ~/ (7 * 1440),
      completedCount: state.completedContracts.length,
    ).first;

    final listView = find.byType(ListView);
    expect(listView, findsOneWidget);
    final scrollable = find.descendant(
      of: listView,
      matching: find.byWidgetPredicate(
        (widget) =>
            widget is Scrollable &&
            widget.physics is! NeverScrollableScrollPhysics,
      ),
    );
    expect(scrollable, findsOneWidget);

    final accept = find.byKey(Key('accept-contract-${offer.id}'));
    var offerBuilt = accept.evaluate().isNotEmpty;
    for (var step = 0; step < 48 && !offerBuilt; step += 1) {
      final position = tester.state<ScrollableState>(scrollable).position;
      if (position.extentAfter <= 0.5) break;
      final next = (position.pixels + 320.0).clamp(
        position.minScrollExtent,
        position.maxScrollExtent,
      );
      position.jumpTo(next);
      await tester.pumpAndSettle();
      offerBuilt = accept.evaluate().isNotEmpty;
    }

    expect(offerBuilt, isTrue);
    await tester.ensureVisible(accept);
    await tester.pumpAndSettle();
    await tester.tap(accept);
    await tester.pumpAndSettle();

    expect(controller.state.activeContracts, hasLength(1));
    expect(controller.state.activeContracts.single.templateId, offer.id);
  });

  testWidgets('monetization surface exposes concrete R16 business metrics', (
    tester,
  ) async {
    final state = liveSaasState();
    final controller = await controllerFor(state);
    addTearDown(controller.dispose);
    await tester.binding.setSurfaceSize(const Size(900, 1200));
    addTearDown(() => tester.binding.setSurfaceSize(null));
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
    expect(find.text('Удовлетворённость'), findsWidgets);
    expect(find.text('Конверсия в оплату'), findsOneWidget);
    expect(find.text('Ожидаемая выручка'), findsOneWidget);
  });
}
