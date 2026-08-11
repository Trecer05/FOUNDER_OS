import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:founder_os/application/settings/display_preferences.dart';
import 'package:founder_os/domain/entities/game_state.dart';
import 'package:founder_os/domain/entities/v12_models.dart';
import 'package:founder_os/presentation/features/infrastructure/infrastructure_screen.dart';
import 'package:founder_os/presentation/features/more/more_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../support/widget_harness.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final preferences = DisplayPreferences.instance;
    await preferences.initialize();
    await preferences.setLanguage(AppLanguage.ru);
    await preferences.setCurrency(DisplayCurrency.rub);
  });

  testWidgets('narrow infrastructure selector stays inside phone viewport', (
    tester,
  ) async {
    final controller = await controllerFor(GameState.initial());
    addTearDown(controller.dispose);
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MaterialApp(home: InfrastructureScreen(controller: controller)),
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('infra-tab-rooms')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('more screen exposes current strategic systems', (tester) async {
    final controller = await controllerFor(
      GameState.initial().copyWith(
        companyProfile: const FounderCompanyProfile.legacy(),
        onboardingCompleted: true,
      ),
    );
    addTearDown(controller.dispose);

    await tester.binding.setSurfaceSize(const Size(900, 1800));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(home: MoreScreen(controller: controller)),
    );
    await tester.pumpAndSettle();

    expect(find.text('Исследования R&D'), findsOneWidget);
    expect(find.text('Центр безопасности'), findsOneWidget);
    expect(find.text('Финансы и P&L'), findsOneWidget);

    final listView = find.byType(ListView);
    expect(listView, findsOneWidget);

    final scrollable = find.descendant(
      of: listView,
      matching: find.byType(Scrollable),
    );
    expect(scrollable, findsOneWidget);

    var sawEcosystem = false;
    var sawInvestors = false;
    var sawMarket = false;
    var sawNews = false;
    var sawLanguage = false;
    var reachedEnd = false;

    for (var step = 0; step < 64; step += 1) {
      sawEcosystem =
          sawEcosystem ||
          find.text('Экосистема продуктов').evaluate().isNotEmpty;
      sawInvestors =
          sawInvestors ||
          find.text('Инвесторы и структура владения').evaluate().isNotEmpty;
      sawMarket = sawMarket || find.text('Рынок и M&A').evaluate().isNotEmpty;
      sawNews = sawNews || find.text('Новости').evaluate().isNotEmpty;
      sawLanguage =
          sawLanguage || find.text('Язык и валюта').evaluate().isNotEmpty;

      final position = tester.state<ScrollableState>(scrollable).position;
      if (position.extentAfter <= 0.5) {
        reachedEnd = true;
        break;
      }

      final next = (position.pixels + 400.0).clamp(
        position.minScrollExtent,
        position.maxScrollExtent,
      );
      position.jumpTo(next);
      await tester.pumpAndSettle();
    }

    sawEcosystem =
        sawEcosystem || find.text('Экосистема продуктов').evaluate().isNotEmpty;
    sawInvestors =
        sawInvestors ||
        find.text('Инвесторы и структура владения').evaluate().isNotEmpty;
    sawMarket = sawMarket || find.text('Рынок и M&A').evaluate().isNotEmpty;
    sawNews = sawNews || find.text('Новости').evaluate().isNotEmpty;
    sawLanguage =
        sawLanguage || find.text('Язык и валюта').evaluate().isNotEmpty;

    expect(reachedEnd, isTrue, reason: 'MoreScreen ListView did not reach end');
    expect(sawEcosystem, isTrue, reason: 'Ecosystem section was never exposed');
    expect(sawInvestors, isTrue, reason: 'Investors section was never exposed');
    expect(sawMarket, isTrue, reason: 'M&A section was never exposed');
    expect(sawNews, isTrue, reason: 'News section was never exposed');
    expect(sawLanguage, isTrue, reason: 'Language section was never exposed');
  });

  testWidgets(
    'display language can switch to English without changing game state',
    (tester) async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      final preferences = DisplayPreferences.instance;
      await preferences.initialize();
      final state = GameState.initial().copyWith(
        companyProfile: const FounderCompanyProfile.legacy(),
        onboardingCompleted: true,
        cash: 123456,
      );
      final controller = await controllerFor(state);
      addTearDown(controller.dispose);

      await preferences.setLanguage(AppLanguage.en);
      await tester.pumpWidget(
        MaterialApp(home: MoreScreen(controller: controller)),
      );
      await tester.pumpAndSettle();
      expect(controller.state.cash, 123456);
      await preferences.setLanguage(AppLanguage.ru);
    },
  );

  testWidgets(
    'rapid app navigation on compact desktop baseline has no exception',
    (tester) async {
      await pumpFounderApp(tester, size: const Size(800, 600));
      for (var round = 0; round < 2; round += 1) {
        for (final icon in <IconData>[
          Icons.apps_outlined,
          Icons.groups_2_outlined,
          Icons.dns_outlined,
          Icons.notifications_outlined,
          Icons.grid_view_rounded,
        ]) {
          final finder = find.byIcon(icon);
          if (finder.evaluate().isNotEmpty) {
            await tester.tap(finder);
            await tester.pump();
          }
        }
      }
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    },
  );
}
