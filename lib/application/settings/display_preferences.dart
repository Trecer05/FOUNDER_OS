import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum DisplayCurrency { rub, usd, eur }

enum AppLanguage { ru, en }

class DisplayPreferences extends ChangeNotifier {
  DisplayPreferences._();

  static final DisplayPreferences instance = DisplayPreferences._();

  static const _currencyKey = 'display_currency_v10';
  static const _languageKey = 'app_language_v10';

  // Bank of Russia official rates effective 06.08.2026.
  static const double rubPerUsd = 80.9293;
  static const double rubPerEur = 93.1901;

  SharedPreferences? _preferences;
  DisplayCurrency _currency = DisplayCurrency.rub;
  AppLanguage _language = AppLanguage.ru;

  DisplayCurrency get currency => _currency;
  AppLanguage get language => _language;
  bool get isEnglish => _language == AppLanguage.en;

  Future<void> initialize() async {
    _preferences = await SharedPreferences.getInstance();
    _currency = DisplayCurrency.values.firstWhere(
      (item) => item.name == _preferences?.getString(_currencyKey),
      orElse: () => DisplayCurrency.rub,
    );
    _language = AppLanguage.values.firstWhere(
      (item) => item.name == _preferences?.getString(_languageKey),
      orElse: () => AppLanguage.ru,
    );
  }

  Future<void> setCurrency(DisplayCurrency value) async {
    if (_currency == value) return;
    _currency = value;
    notifyListeners();
    await _preferences?.setString(_currencyKey, value.name);
  }

  Future<void> setLanguage(AppLanguage value) async {
    if (_language == value) return;
    _language = value;
    notifyListeners();
    await _preferences?.setString(_languageKey, value.name);
  }

  String text(String ru, String en) => isEnglish ? en : ru;

  double convertFromRub(double value) => switch (_currency) {
    DisplayCurrency.rub => value,
    DisplayCurrency.usd => value / rubPerUsd,
    DisplayCurrency.eur => value / rubPerEur,
  };

  String formatMoney(double rubValue) {
    final value = convertFromRub(rubValue);
    final sign = value < 0 ? '−' : '';
    final absolute = value.abs();
    final symbol = switch (_currency) {
      DisplayCurrency.rub => '₽',
      DisplayCurrency.usd => r'$',
      DisplayCurrency.eur => '€',
    };
    final billion = isEnglish ? 'B' : 'млрд';
    final million = isEnglish ? 'M' : 'млн';
    final thousand = isEnglish ? 'K' : 'тыс.';
    if (absolute >= 1000000000) {
      return '$sign${(absolute / 1000000000).toStringAsFixed(2)} $billion $symbol';
    }
    if (absolute >= 1000000) {
      return '$sign${(absolute / 1000000).toStringAsFixed(2)} $million $symbol';
    }
    if (absolute >= 1000) {
      return '$sign${(absolute / 1000).toStringAsFixed(1)} $thousand $symbol';
    }
    final digits = _currency == DisplayCurrency.rub ? 0 : 2;
    return '$sign${absolute.toStringAsFixed(digits)} $symbol';
  }

  String get currencyLabel => switch (_currency) {
    DisplayCurrency.rub => 'RUB · ₽',
    DisplayCurrency.usd => 'USD · \$',
    DisplayCurrency.eur => 'EUR · €',
  };

  String get rateNote => switch (_currency) {
    DisplayCurrency.rub => text(
      'Базовая игровая валюта. Цены хранятся в рублях.',
      'Base game currency. Prices are stored in rubles.',
    ),
    DisplayCurrency.usd => text(
      '1 USD = 80,9293 ₽ · курс ЦБ РФ на 06.08.2026.',
      '1 USD = 80.9293 RUB · Bank of Russia rate for 06 Aug 2026.',
    ),
    DisplayCurrency.eur => text(
      '1 EUR = 93,1901 ₽ · курс ЦБ РФ на 06.08.2026.',
      '1 EUR = 93.1901 RUB · Bank of Russia rate for 06 Aug 2026.',
    ),
  };
}
