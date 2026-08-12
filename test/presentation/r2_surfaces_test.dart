import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:founder_os/domain/commands/game_action.dart';
import 'package:founder_os/domain/entities/models.dart';
import 'package:founder_os/presentation/features/company/company_notification_center_screen.dart';
import 'package:founder_os/presentation/features/products/product_workspace_screen.dart';
import 'package:founder_os/presentation/shared/widgets/company_notification_toast_host.dart';
import 'package:founder_os/domain/entities/v17_models.dart';
import 'package:founder_os/presentation/features/company/company_hub_screen.dart';

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

  testWidgets(
    'top toast ignores unread backlog and opens safe notification center',
    (tester) async {
      const oldNotification = CompanyNotification(
        id: 'old_unread',
        kind: CompanyNotificationKind.investor,
        title: 'Old',
        body: 'Backlog',
        simulationMinutes: 1,
        read: false,
      );
      final product = productFixture(
        id: 'toast_product',
        stage: ProductStage.development,
        featureIds: const <String>[],
      ).copyWith(developmentProgress: 1);
      final controller = await controllerFor(
        fundedInitial().copyWith(
          selectedHostingPlanId: 'shared_launch',
          products: <Product>[product],
          companyNotifications: const <CompanyNotification>[oldNotification],
        ),
      );
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        MaterialApp(
          home: CompanyNotificationToastHost(
            controller: controller,
            child: const Scaffold(body: SizedBox.expand()),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(
        find.byKey(const Key('top-company-notification-toast')),
        findsNothing,
      );

      controller.dispatch(
        const LaunchProduct('toast_product'),
        playSound: false,
      );
      await tester.pump();
      expect(
        find.byKey(const Key('top-company-notification-toast')),
        findsOneWidget,
      );

      await tester.tap(find.byKey(const Key('top-company-notification-toast')));
      await tester.pumpAndSettle();
      expect(find.byType(CompanyNotificationCenterScreen), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('top toast can be dismissed upward', (tester) async {
    final product = productFixture(
      id: 'swipe_product',
      stage: ProductStage.development,
      featureIds: const <String>[],
    ).copyWith(developmentProgress: 1);
    final controller = await controllerFor(
      fundedInitial().copyWith(
        selectedHostingPlanId: 'shared_launch',
        products: <Product>[product],
      ),
    );
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: CompanyNotificationToastHost(
          controller: controller,
          child: const Scaffold(body: SizedBox.expand()),
        ),
      ),
    );
    await tester.pumpAndSettle();

    controller.dispatch(const LaunchProduct('swipe_product'), playSound: false);
    await tester.pump();
    final toast = find.byKey(const Key('top-company-notification-toast'));
    expect(toast, findsOneWidget);

    await tester.fling(toast, const Offset(0, -260), 1400);
    await tester.pumpAndSettle();
    expect(toast, findsNothing);
    final development = controller.state.companyNotifications.firstWhere(
      (item) => item.id.startsWith('development_release_'),
    );
    expect(development.read, isTrue);
  });

  testWidgets(
    'company hub shows events legacy and world projects without notification tab',
    (tester) async {
      final controller = await controllerFor(fundedInitial());
      addTearDown(controller.dispose);
      await tester.binding.setSurfaceSize(const Size(430, 932));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        MaterialApp(home: CompanyHubScreen(controller: controller)),
      );
      await tester.pumpAndSettle();

      expect(find.text('События и достижения'), findsOneWidget);
      expect(find.text('Мероприятия'), findsOneWidget);
      expect(find.text('Мировые проекты'), findsOneWidget);
      expect(find.text('Уведомления'), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );
}
