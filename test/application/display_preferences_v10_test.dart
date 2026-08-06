import 'package:flutter_test/flutter_test.dart';
import 'package:founder_os/application/settings/display_preferences.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test(
    'display currency converts from rubles with fixed offline rates',
    () async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      final preferences = DisplayPreferences.instance;
      await preferences.initialize();

      await preferences.setCurrency(DisplayCurrency.usd);
      await preferences.setLanguage(AppLanguage.en);
      expect(
        preferences.formatMoney(DisplayPreferences.rubPerUsd),
        contains('1.00'),
      );
      expect(
        preferences.formatMoney(DisplayPreferences.rubPerUsd),
        contains(r'$'),
      );

      await preferences.setCurrency(DisplayCurrency.eur);
      expect(
        preferences.formatMoney(DisplayPreferences.rubPerEur),
        contains('1.00'),
      );
      expect(
        preferences.formatMoney(DisplayPreferences.rubPerEur),
        contains('€'),
      );

      await preferences.setCurrency(DisplayCurrency.rub);
      await preferences.setLanguage(AppLanguage.ru);
    },
  );

  test('display preferences persist language and currency', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final preferences = DisplayPreferences.instance;
    await preferences.initialize();
    await preferences.setCurrency(DisplayCurrency.usd);
    await preferences.setLanguage(AppLanguage.en);

    final storage = await SharedPreferences.getInstance();
    expect(storage.getString('display_currency_v10'), 'usd');
    expect(storage.getString('app_language_v10'), 'en');

    await preferences.setCurrency(DisplayCurrency.rub);
    await preferences.setLanguage(AppLanguage.ru);
  });
}
