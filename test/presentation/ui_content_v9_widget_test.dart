import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:founder_os/app/app.dart';
import 'package:founder_os/application/controllers/game_controller.dart';
import 'package:founder_os/domain/entities/game_state.dart';
import 'package:founder_os/persistence/storage/snapshot_store.dart';
import 'package:founder_os/presentation/features/help/glossary_screen.dart';
import 'package:founder_os/presentation/shared/widgets/compact_team_averages.dart';

void main() {
  testWidgets('floating time controls fit narrow iPhone SafeArea', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final controller = await _controller();
    addTearDown(controller.dispose);

    await tester.pumpWidget(FounderOsApp(controller: controller));
    await tester.pump();

    expect(find.byKey(const Key('global-time-floating')), findsOneWidget);
    expect(find.byKey(const Key('global-time-toggle')), findsOneWidget);
    expect(find.byKey(const Key('global-current-time')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('floating controls remain on nested route', (tester) async {
    final controller = await _controller();
    addTearDown(controller.dispose);
    await tester.pumpWidget(FounderOsApp(controller: controller));
    await tester.pump();
    final context = tester.element(find.byType(Scaffold).first);
    Navigator.of(context).push<void>(
      MaterialPageRoute(builder: (_) => const Scaffold(body: Text('Nested'))),
    );
    await tester.pumpAndSettle();

    expect(find.text('Nested'), findsOneWidget);
    expect(find.byKey(const Key('global-time-floating')), findsOneWidget);
  });

  testWidgets('keyboard hides controls instead of overlapping input', (
    tester,
  ) async {
    final controller = await _controller();
    addTearDown(controller.dispose);
    tester.view.viewInsets = FakeViewPadding(bottom: 280);
    addTearDown(tester.view.resetViewInsets);
    await tester.pumpWidget(FounderOsApp(controller: controller));
    await tester.pump();
    expect(find.byKey(const Key('global-time-floating')), findsNothing);
  });

  testWidgets('compact team averages stays below 25 percent of phone height', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: CompactTeamAverages(state: GameState.initial())),
      ),
    );
    final size = tester.getSize(find.byKey(const Key('compact-team-averages')));
    expect(size.height, lessThanOrEqualTo(148));
    expect(tester.takeException(), isNull);
  });

  testWidgets('glossary is permanent and searchable', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: GlossaryScreen()));
    expect(find.text('Метрики и терминология'), findsOneWidget);
    await tester.enterText(find.byKey(const Key('glossary-search')), 'runway');
    await tester.pump();
    expect(find.text('Runway'), findsOneWidget);
    expect(find.text('MRR'), findsNothing);
  });
}

Future<GameController> _controller() async {
  final controller = GameController(
    snapshotStore: _MemoryStore(
      GameState.initial().copyWith(onboardingCompleted: true),
    ),
    startClock: false,
  );
  await controller.initialize();
  return controller;
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
