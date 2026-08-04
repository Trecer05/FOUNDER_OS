import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:founder_os/app/app.dart';
import 'package:founder_os/application/controllers/game_controller.dart';
import 'package:founder_os/domain/entities/game_state.dart';
import 'package:founder_os/persistence/storage/snapshot_store.dart';

class _MemorySnapshotStore implements SnapshotStore {
  GameState? value;

  @override
  Future<void> clear() async => value = null;

  @override
  Future<GameState?> load() async => value;

  @override
  Future<void> save(GameState state) async => value = state;
}

Future<GameController> _pumpApp(WidgetTester tester) async {
  await tester.binding.setSurfaceSize(const Size(430, 932));
  addTearDown(() => tester.binding.setSurfaceSize(null));

  final controller = GameController(
    snapshotStore: _MemorySnapshotStore(),
    startClock: false,
  );
  addTearDown(controller.dispose);

  await controller.initialize();
  await tester.pumpWidget(FounderOsApp(controller: controller));
  await tester.pumpAndSettle();

  return controller;
}

void main() {
  testWidgets('player configures a product from the product list', (
    tester,
  ) async {
    final controller = await _pumpApp(tester);

    await tester.tap(find.byIcon(Icons.apps_outlined));
    await tester.pumpAndSettle();

    final builderButton = find.byKey(const Key('open-product-builder'));
    expect(builderButton, findsOneWidget);

    await tester.tap(builderButton);
    await tester.pumpAndSettle();

    expect(find.text('Новый продукт'), findsOneWidget);
    expect(find.text('Тип продукта'), findsOneWidget);

    final productList = find.byType(Scrollable).first;

    await tester.scrollUntilVisible(
      find.text('Название и framework'),
      350,
      scrollable: productList,
    );
    await tester.pumpAndSettle();

    expect(find.text('Название и framework'), findsOneWidget);
    expect(find.text('Flutter + Firebase'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Функции'),
      350,
      scrollable: productList,
    );
    await tester.pumpAndSettle();

    expect(find.text('Функции'), findsOneWidget);

    final createButton = find.byKey(const Key('create-configured-product'));
    expect(createButton, findsOneWidget);

    await tester.tap(createButton);
    await tester.pumpAndSettle();

    expect(controller.state.products, hasLength(1));
    expect(controller.state.products.single.name, 'Nova One');
    expect(find.text('Nova One'), findsWidgets);
  });

  testWidgets('team screen exposes filters and numeric hiring metrics', (
    tester,
  ) async {
    await _pumpApp(tester);

    await tester.tap(find.byIcon(Icons.groups_2_outlined));
    await tester.pumpAndSettle();

    expect(find.text('Все роли'), findsOneWidget);
    expect(find.text('Сортировка'), findsOneWidget);

    final searchField = find.byType(TextField).first;
    await tester.enterText(searchField, 'Анна');
    await tester.pumpAndSettle();

    expect(find.text('Анна Миронова'), findsOneWidget);
    expect(find.byKey(const Key('hire-c_anna')), findsOneWidget);

    expect(find.text('78'), findsOneWidget);
    expect(find.text('84'), findsOneWidget);
    expect(find.text('73'), findsOneWidget);
    expect(find.text('68'), findsOneWidget);
    expect(find.text('80'), findsOneWidget);
    expect(find.text('74'), findsOneWidget);
  });
}
