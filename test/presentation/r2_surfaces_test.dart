import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:founder_os/presentation/features/company/company_notification_center_screen.dart';
import 'package:founder_os/presentation/features/products/product_workspace_screen.dart';
import 'package:founder_os/domain/entities/v17_models.dart';

import '../support/fixtures.dart';
import '../support/widget_harness.dart';

void main() {
  testWidgets(
    'notification center marks only visible items and can clear all',
    (tester) async {
      final notifications = List<CompanyNotification>.generate(
        30,
        (index) => CompanyNotification(
          id: 'n$index',
          kind: index.isEven
              ? CompanyNotificationKind.contract
              : CompanyNotificationKind.development,
          title: 'Notification $index',
          body: 'Body $index',
          simulationMinutes: index,
          read: false,
        ),
      );
      final controller = await controllerFor(
        fundedInitial().copyWith(companyNotifications: notifications),
      );
      addTearDown(controller.dispose);
      await tester.binding.setSurfaceSize(const Size(390, 760));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        MaterialApp(
          home: CompanyNotificationCenterScreen(controller: controller),
        ),
      );
      await tester.pumpAndSettle();

      final readCount = controller.state.companyNotifications
          .where((item) => item.read)
          .length;
      expect(readCount, greaterThan(0));
      expect(readCount, lessThan(30));
      expect(find.byKey(const Key('notification-dot-contract')), findsWidgets);
      expect(
        find.byKey(const Key('notification-dot-development')),
        findsWidgets,
      );

      await tester.tap(find.byKey(const Key('clear-all-notifications')));
      await tester.pumpAndSettle();
      expect(controller.state.companyNotifications, isEmpty);
    },
  );

  testWidgets(
    'dashboard exposes Contracts as a primary destination and top bell',
    (tester) async {
      await pumpFounderApp(tester);
      expect(find.byIcon(Icons.handshake_outlined), findsOneWidget);
      expect(
        find.byKey(const Key('open-company-notifications')),
        findsOneWidget,
      );
    },
  );

  testWidgets('released product shows live roadmap impact', (tester) async {
    final state = liveWebsiteState();
    final controller = await controllerFor(state);
    addTearDown(controller.dispose);
    await tester.binding.setSurfaceSize(const Size(430, 932));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        home: ProductWorkspaceScreen(
          controller: controller,
          productId: 'website',
        ),
      ),
    );
    await tester.pumpAndSettle();

    final devTab = find.text('Разработка');
    if (devTab.evaluate().isNotEmpty) {
      await tester.tap(devTab.first);
      await tester.pumpAndSettle();
    }
    expect(find.byKey(const Key('live-roadmap-impact')), findsOneWidget);
    expect(
      find.byKey(const Key('development-technical-summary')),
      findsOneWidget,
    );
  });
}
