import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:founder_os/app/app.dart';
import 'package:founder_os/application/controllers/game_controller.dart';
import 'package:founder_os/domain/entities/game_state.dart';
import 'package:founder_os/domain/entities/v12_models.dart';
import 'package:founder_os/persistence/storage/snapshot_store.dart';

void main() {
  testWidgets('production shell opens menu and continues an existing company', (
    tester,
  ) async {
    final store = _MemoryStore()
      ..value = GameState.initial(seed: 7).copyWith(
        onboardingCompleted: true,
        companyProfile: const FounderCompanyProfile.legacy(),
      );
    final controller = GameController(snapshotStore: store, startClock: false);
    addTearDown(controller.dispose);
    await controller.initialize();

    await tester.pumpWidget(
      FounderOsApp(
        controller: controller,
        startAtMainMenu: true,
        showGlobalTimeControls: true,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('FOUNDER.OS'), findsWidgets);
    expect(find.byKey(const Key('main-menu-continue')), findsOneWidget);
    expect(find.byKey(const Key('global-time-toggle')), findsNothing);

    await tester.tap(find.byKey(const Key('main-menu-continue')));
    await tester.pumpAndSettle();

    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.byKey(const Key('global-time-toggle')), findsOneWidget);
  });
}

class _MemoryStore implements SnapshotStore {
  GameState? value;

  @override
  Future<void> clear() async => value = null;

  @override
  Future<GameState?> load() async => value;

  @override
  Future<void> save(GameState state) async => value = state;
}
