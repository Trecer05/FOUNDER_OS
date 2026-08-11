import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:founder_os/application/settings/display_preferences.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:founder_os/presentation/features/products/product_detail_screen.dart';
import 'package:founder_os/presentation/features/products/product_workspace_screen.dart';
import 'package:founder_os/presentation/features/team/team_screen.dart';

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

  testWidgets(
    'player creates bootstrap website through current product wizard',
    (tester) async {
      final controller = await pumpFounderApp(tester);
      await tester.tap(find.byIcon(Icons.apps_outlined));
      await tester.pumpAndSettle();

      final builderButton = find.byKey(const Key('open-product-builder'));
      expect(builderButton, findsOneWidget);
      await tester.tap(builderButton);
      await tester.pumpAndSettle();

      expect(find.text('Новый проект • 1/7'), findsOneWidget);
      expect(find.text('Сайт компании'), findsOneWidget);

      for (var step = 0; step < 6; step += 1) {
        final next = find.byKey(const Key('product-wizard-next'));
        expect(next, findsOneWidget);
        await tester.tap(next);
        await tester.pumpAndSettle();
      }

      final createButton = find.byKey(const Key('create-configured-product'));
      expect(createButton, findsOneWidget);
      await tester.tap(createButton);
      await tester.pumpAndSettle();

      expect(controller.state.products, hasLength(1));
      expect(controller.state.products.single.blueprintId, 'company_website');
    },
  );

  testWidgets('team screen exposes filters and numeric candidate metrics', (
    tester,
  ) async {
    final controller = await pumpFounderApp(tester);
    await tester.tap(find.byIcon(Icons.groups_2_outlined));
    await tester.pumpAndSettle();
    expect(find.byType(TeamScreen), findsOneWidget);

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

    final target = controller.state.candidates.firstWhere(
      (item) => item.remote && item.languageIds.isNotEmpty,
    );
    await tester.enterText(searchField, target.name);
    await tester.pumpAndSettle();
    final card = find.byKey(Key('candidate-card-${target.id}'));
    for (
      var attempt = 0;
      attempt < 20 && card.evaluate().isEmpty;
      attempt += 1
    ) {
      await tester.drag(teamList, const Offset(0, -240));
      await tester.pumpAndSettle();
    }
    expect(card, findsOneWidget);
    expect(find.byKey(Key('hire-${target.id}')), findsOneWidget);
    expect(find.text('${target.skill}'), findsWidgets);
    expect(find.text('${target.quality}'), findsWidgets);
  });

  testWidgets('live subscription product exposes working price control', (
    tester,
  ) async {
    final state = liveSaasState();
    final controller = await controllerFor(state);
    addTearDown(controller.dispose);
    await tester.binding.setSurfaceSize(const Size(430, 932));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        home: ProductDetailScreen(
          controller: controller,
          productId: state.products.single.id,
        ),
      ),
    );
    await tester.pumpAndSettle();

    final priceSlider = find.byKey(const Key('subscription-price-slider'));
    final detailsList = find.byType(ListView).first;
    for (
      var attempt = 0;
      attempt < 20 && priceSlider.evaluate().isEmpty;
      attempt += 1
    ) {
      await tester.drag(detailsList, const Offset(0, -400));
      await tester.pumpAndSettle();
    }
    expect(priceSlider, findsOneWidget);
    final slider = tester.widget<Slider>(priceSlider);
    slider.onChangeEnd!(1500);
    await tester.pumpAndSettle();
    expect(controller.state.products.single.price, 1500);
  });

  testWidgets(
    'product rename dialog can close by back without lifecycle exception',
    (tester) async {
      final state = liveWebsiteState();
      final controller = await controllerFor(state);
      addTearDown(controller.dispose);
      await tester.binding.setSurfaceSize(const Size(900, 1000));
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
      await tester.tap(find.byKey(const Key('rename-product')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('rename-product-field')), findsOneWidget);
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(
        find.byKey(const Key('product-user-satisfaction')),
        findsOneWidget,
      );
    },
  );
}
