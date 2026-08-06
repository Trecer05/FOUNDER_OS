import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:founder_os/application/controllers/game_controller.dart';
import 'package:founder_os/domain/commands/game_action.dart';
import 'package:founder_os/domain/entities/game_state.dart';
import 'package:founder_os/domain/simulation/engine/game_engine.dart';
import 'package:founder_os/persistence/storage/snapshot_store.dart';
import 'package:founder_os/presentation/features/products/product_workspace_screen.dart';
import 'package:founder_os/presentation/shared/widgets/global_time_control_bar.dart';

void main() {
  testWidgets('global bar keeps time and cash visible without decoration', (
    tester,
  ) async {
    final controller = GameController(
      snapshotStore: _MemoryStore(GameState.initial()),
      startClock: false,
    );
    await controller.initialize();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: GlobalTimeControlBar(controller: controller)),
      ),
    );

    expect(find.byKey(const Key('global-current-time')), findsOneWidget);
    expect(find.byKey(const Key('global-current-cash')), findsOneWidget);
    final timeText = tester.widget<Text>(
      find.descendant(
        of: find.byKey(const Key('global-current-time')),
        matching: find.byType(Text),
      ),
    );
    expect(timeText.style?.decoration, TextDecoration.none);
    controller.dispose();
  });

  testWidgets('product workspace exposes six grouped sections', (tester) async {
    const engine = GameEngine();
    final state = engine.reduce(
      GameState.initial().copyWith(cash: 100000000),
      const CreateConfiguredProduct(
        name: 'Workspace',
        blueprintId: 'team_saas',
        frameworkId: 'next_nest',
        languageIds: <String>['typescript'],
        technologyIds: <String>['postgresql'],
        featureIds: <String>['team_spaces'],
      ),
    );
    final controller = GameController(
      snapshotStore: _MemoryStore(state),
      startClock: false,
    );
    await controller.initialize();

    await tester.pumpWidget(
      MaterialApp(
        home: ProductWorkspaceScreen(
          controller: controller,
          productId: state.products.single.id,
        ),
      ),
    );
    await tester.pumpAndSettle();

    for (final label in <String>[
      'Обзор',
      'Разработка',
      'Команда',
      'Реклама',
      'Метрики',
      'Инфра',
    ]) {
      expect(find.text(label), findsOneWidget);
    }
    controller.dispose();
  });
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
