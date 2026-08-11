import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:founder_os/app/app.dart';
import 'package:founder_os/application/settings/display_preferences.dart';
import 'package:founder_os/presentation/features/dashboard/founder_dashboard.dart';
import 'package:founder_os/presentation/features/menu/save_slots_dialog.dart';
import 'package:founder_os/presentation/features/research/research_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../support/fixtures.dart';
import '../support/widget_harness.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await DisplayPreferences.instance.initialize();
    await DisplayPreferences.instance.setLanguage(AppLanguage.ru);
  });

  testWidgets('R&D stays responsive on narrow iPhone viewport', (tester) async {
    final controller = await controllerFor(fundedInitial());
    addTearDown(controller.dispose);
    await tester.binding.setSurfaceSize(const Size(393, 852));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(home: ResearchScreen(controller: controller)),
    );
    await tester.pumpAndSettle();

    final list = find.byKey(const Key('research-screen-list'));
    expect(list, findsOneWidget);

    // The features group is intentionally below the full technology tree and
    // may not be built by ListView yet. Traverse the real scroll position and
    // assert it becomes reachable rather than requiring an off-screen lazy
    // child to exist at frame zero.
    final scrollable = find.descendant(
      of: list,
      matching: find.byType(Scrollable),
    );
    expect(scrollable, findsOneWidget);

    final featuresHeading = find.text('Функции продукта');
    var exposed = featuresHeading.evaluate().isNotEmpty;
    for (var step = 0; step < 40 && !exposed; step += 1) {
      final position = tester.state<ScrollableState>(scrollable).position;
      if (position.extentAfter <= 0.5) break;
      final next = (position.pixels + 420.0).clamp(
        position.minScrollExtent,
        position.maxScrollExtent,
      );
      position.jumpTo(next);
      await tester.pumpAndSettle();
      exposed = featuresHeading.evaluate().isNotEmpty;
    }

    expect(
      exposed,
      isTrue,
      reason: 'Product features group must be reachable on a narrow iPhone.',
    );
    expect(featuresHeading, findsOneWidget);
  });

  testWidgets('manual save dialog scrolls without narrow-screen overflow', (
    tester,
  ) async {
    final controller = await controllerFor(fundedInitial());
    addTearDown(controller.dispose);
    await tester.binding.setSurfaceSize(const Size(393, 780));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: FilledButton(
                key: const Key('open-save-test'),
                onPressed: () => showSaveSlotsDialog(
                  context,
                  controller,
                  mode: SaveSlotDialogMode.save,
                ),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.byKey(const Key('open-save-test')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('save-slots-scroll')), findsOneWidget);
    expect(find.text('Сохранить игру'), findsOneWidget);
    expect(find.byKey(const Key('save-slot-action-slot_1')), findsOneWidget);
    expect(find.byType(Dialog), findsOneWidget);
  });

  testWidgets('popup route blocks global time controls behind modal', (
    tester,
  ) async {
    final controller = await controllerFor(
      fundedInitial().copyWith(paused: true),
    );
    addTearDown(controller.dispose);
    await tester.binding.setSurfaceSize(const Size(430, 932));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      FounderOsApp(controller: controller, showGlobalTimeControls: true),
    );
    await tester.pumpAndSettle();

    final skip = find.byKey(const Key('tutorial-skip'));
    if (skip.evaluate().isNotEmpty) {
      await tester.tap(skip);
      await tester.pumpAndSettle();
    }

    final dashboardContext = tester.element(find.byType(FounderDashboard));
    showDialog<void>(
      context: dashboardContext,
      barrierDismissible: false,
      builder: (_) => const AlertDialog(
        title: Text('modal'),
        content: Text('blocks background'),
      ),
    );
    await tester.pumpAndSettle();

    expect(controller.state.paused, isTrue);
    await tester.tap(
      find.byKey(const Key('global-time-toggle')),
      warnIfMissed: false,
    );
    await tester.pump();
    expect(controller.state.paused, isTrue);

    Navigator.of(tester.element(find.byType(AlertDialog))).pop();
    await tester.pumpAndSettle();
  });
}
