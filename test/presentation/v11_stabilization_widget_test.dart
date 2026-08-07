import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:founder_os/application/localization/app_text.dart';
import 'package:founder_os/presentation/shared/widgets/metric_card.dart';
import 'package:founder_os/presentation/shared/widgets/responsive_info_row.dart';

void main() {
  testWidgets('long infrastructure values do not overflow on iPhone width', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      const MaterialApp(
        locale: Locale('ru'),
        supportedLocales: <Locale>[Locale('ru'), Locale('en')],
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        home: Scaffold(
          body: Padding(
            padding: EdgeInsets.all(32),
            child: ResponsiveInfoRow(
              'Серверная',
              'Технический шкаф • подготовка к миграции',
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();
    expect(find.text('Серверная'), findsOneWidget);
    expect(
      find.text('Технический шкаф • подготовка к миграции'),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('AppText raw keeps promo codes and technical names unchanged', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        locale: Locale('ru'),
        supportedLocales: <Locale>[Locale('ru'), Locale('en')],
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        home: Scaffold(
          body: Column(
            children: [
              AppText('FOUNDER-RICH', translate: false),
              AppText('FreeLane Performance', translate: false),
              AppText('Frontend / Backend', translate: false),
            ],
          ),
        ),
      ),
    );

    expect(find.text('FOUNDER-RICH'), findsOneWidget);
    expect(find.text('FreeLane Performance'), findsOneWidget);
    expect(find.text('Frontend / Backend'), findsOneWidget);
  });

  testWidgets('MetricCard exposes a tappable period control', (tester) async {
    var daily = false;
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('ru'),
        supportedLocales: const <Locale>[Locale('ru'), Locale('en')],
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        home: StatefulBuilder(
          builder: (context, setState) => Scaffold(
            body: MetricCard(
              label: daily ? 'Прибыль / день' : 'Прибыль / мес.',
              value: daily ? '1 000 ₽' : '30 000 ₽',
              onTap: () => setState(() => daily = !daily),
            ),
          ),
        ),
      ),
    );

    expect(find.text('Прибыль / мес.'), findsOneWidget);
    await tester.tap(find.text('Прибыль / мес.'));
    await tester.pump();
    expect(find.text('Прибыль / день'), findsOneWidget);
  });
}
