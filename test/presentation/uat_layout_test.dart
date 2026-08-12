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

    expect(find.byKey(const Key('research-screen-list')), findsOneWidget);
    await tester.tap(find.text('Функции продукта').last);
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('research-feature-list')), findsOneWidget);
    expect(tester.takeException(), isNull);
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
