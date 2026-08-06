import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:founder_os/presentation/shared/widgets/scoped_listenable_builder.dart';

void main() {
  testWidgets('inactive retained tab ignores listenable notifications', (
    tester,
  ) async {
    final notifier = _TestNotifier();
    addTearDown(notifier.dispose);
    var builds = 0;

    Widget tree(bool active) => Directionality(
      textDirection: TextDirection.ltr,
      child: ActiveTabScope(
        active: active,
        child: ScopedListenableBuilder(
          listenable: notifier,
          builder: (context, child) {
            builds += 1;
            return const SizedBox();
          },
        ),
      ),
    );

    await tester.pumpWidget(tree(false));
    expect(builds, 1);

    notifier.ping();
    await tester.pump();
    expect(builds, 1);

    await tester.pumpWidget(tree(true));
    expect(builds, 2);

    notifier.ping();
    await tester.pump();
    expect(builds, 3);
  });
}

class _TestNotifier extends ChangeNotifier {
  void ping() => notifyListeners();
}
