import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:founder_os/application/settings/display_preferences.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:founder_os/domain/entities/game_state.dart';
import 'package:founder_os/domain/entities/v12_models.dart';

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
    'main game shell exposes all six current navigation destinations',
    (tester) async {
      await pumpFounderApp(tester);
      expect(find.byIcon(Icons.space_dashboard), findsWidgets);
      expect(find.byIcon(Icons.apps_outlined), findsOneWidget);
      expect(find.byIcon(Icons.groups_2_outlined), findsOneWidget);
      expect(find.byIcon(Icons.dns_outlined), findsOneWidget);
      expect(find.byIcon(Icons.handshake_outlined), findsOneWidget);
      expect(
        find.byKey(const Key('open-company-notifications')),
        findsOneWidget,
      );
      expect(find.byIcon(Icons.grid_view_rounded), findsOneWidget);
    },
  );

  testWidgets(
    'dashboard switches between all primary sections without exception',
    (tester) async {
      await pumpFounderApp(tester);
      for (final icon in <IconData>[
        Icons.apps_outlined,
        Icons.groups_2_outlined,
        Icons.dns_outlined,
        Icons.handshake_outlined,
        Icons.grid_view_rounded,
        Icons.space_dashboard_outlined,
      ]) {
        final finder = find.byIcon(icon);
        if (finder.evaluate().isNotEmpty) {
          await tester.tap(finder);
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
        }
      }
    },
  );

  testWidgets(
    'long company name keeps fans and reputation visible on narrow phone',
    (tester) async {
      const profile = FounderCompanyProfile(
        configured: true,
        companyName: 'Очень длинное название технологической компании',
        founderName: 'CEO',
        logoId: 'company_logo_01',
        startingBudget: 450000,
        background: FounderBackground.product,
        skills: <FounderSkill, int>{
          FounderSkill.engineering: 4,
          FounderSkill.design: 3,
          FounderSkill.product: 5,
          FounderSkill.growth: 3,
          FounderSkill.negotiation: 3,
          FounderSkill.operations: 4,
        },
      );
      final controller = await pumpFounderApp(
        tester,
        size: const Size(390, 844),
        state: GameState.initial().copyWith(
          companyProfile: profile,
          onboardingCompleted: true,
          companyFans: 1234567,
          brandReputation: 88,
        ),
      );
      expect(controller.state.companyFans, 1234567);
      expect(find.byIcon(Icons.favorite_outline), findsOneWidget);
      expect(find.byIcon(Icons.workspace_premium_outlined), findsWidgets);
      expect(tester.takeException(), isNull);
    },
  );
}
