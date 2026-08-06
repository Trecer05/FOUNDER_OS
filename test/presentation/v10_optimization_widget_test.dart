import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:founder_os/application/localization/app_text.dart';
import 'package:founder_os/application/settings/display_preferences.dart';

void main() {
  testWidgets('AppText presents one alphabet for each locale', (tester) async {
    addTearDown(() => DisplayPreferences.instance.setLanguage(AppLanguage.ru));
    await DisplayPreferences.instance.setLanguage(AppLanguage.en);
    await tester.pumpWidget(
      const MaterialApp(
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        locale: Locale('en'),
        supportedLocales: <Locale>[Locale('en'), Locale('ru')],
        home: Scaffold(
          body: AppText('Деньги · Команда проекта · Вычислительная мощность'),
        ),
      ),
    );
    final english = tester
        .widget<Text>(
          find.descendant(
            of: find.byType(AppText),
            matching: find.byType(Text),
          ),
        )
        .data!;
    expect(RegExp(r'[А-Яа-яЁё]').hasMatch(english), isFalse);

    await DisplayPreferences.instance.setLanguage(AppLanguage.ru);
    await tester.pumpWidget(
      const MaterialApp(
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        locale: Locale('ru'),
        supportedLocales: <Locale>[Locale('en'), Locale('ru')],
        home: Scaffold(
          body: AppText('Cash · Development capacity · Stack coherence'),
        ),
      ),
    );
    final russian = tester
        .widget<Text>(
          find.descendant(
            of: find.byType(AppText),
            matching: find.byType(Text),
          ),
        )
        .data!;
    expect(russian, contains('Деньги'));
    expect(russian, contains('Скорость разработки'));
  });
}
