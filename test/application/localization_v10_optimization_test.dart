import 'package:flutter_test/flutter_test.dart';
import 'package:founder_os/application/localization/app_localizer.dart';

void main() {
  test('Russian UI normalizes accidental English implementation jargon', () {
    final result = AppLocalizer.toRussian(
      'Cash · Development capacity · Stack coherence · provider lock-in',
    );
    expect(result, contains('Деньги'));
    expect(result, contains('Скорость разработки'));
    expect(result, contains('Совместимость стека'));
    expect(result.toLowerCase(), isNot(contains('provider lock-in')));
  });

  test('Russian role and product labels use localized names', () {
    expect(AppLocalizer.toRussian('Product Manager'), 'Менеджер продукта');
    expect(
      AppLocalizer.toRussian('Security Engineer'),
      'Инженер по безопасности',
    );
    expect(AppLocalizer.toRussian('Company website'), 'Сайт компании');
    expect(AppLocalizer.toRussian('Cloud platform'), 'Облачная платформа');
  });

  test('Russian fallback contains no accidental lowercase Latin copy', () {
    final result = AppLocalizer.toRussian(
      'maximum remote performance unknownword',
    );
    expect(RegExp(r'[a-z]').hasMatch(result), isFalse);
  });

  test('founder handbook definitions use authored English copy', () {
    expect(
      AppLocalizer.toEnglish('Повторяющаяся месячная выручка.'),
      'Monthly recurring revenue.',
    );
    expect(
      AppLocalizer.toEnglish('Главное узкое место.'),
      'The primary bottleneck.',
    );
  });

  test('English UI never leaks Cyrillic', () {
    final result = AppLocalizer.toEnglish(
      'День 4 · Команда проекта · Вычислительная мощность · Переговоры',
    );
    expect(RegExp(r'[А-Яа-яЁё]').hasMatch(result), isFalse);
    expect(result, contains('Day'));
    expect(result.toLowerCase(), contains('project team'));
  });
}
