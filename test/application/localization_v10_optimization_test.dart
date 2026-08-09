import 'package:flutter_test/flutter_test.dart';
import 'package:founder_os/application/localization/app_localizer.dart';

void main() {
  test('Russian UI translates authored phrases without damaging tech copy', () {
    final result = AppLocalizer.toRussian(
      'Cash · Development capacity · Stack coherence · provider lock-in',
    );
    expect(result, contains('Деньги'));
    expect(result, contains('Скорость разработки'));
    expect(result, contains('Совместимость стека'));
    expect(result.toLowerCase(), isNot(contains('provider lock-in')));
  });

  test('Russian UI preserves technical roles units and promo codes', () {
    for (final value in <String>[
      'Frontend',
      'Backend',
      'Product Manager',
      'HR / People Partner',
      'Compute 45 CU',
      '8 U · 6.0 kW · 1 Gbps',
      'FOUNDER-RICH',
      'FOUNDER-BROKE',
      'FreeLane Performance',
    ]) {
      expect(AppLocalizer.toRussian(value), value, reason: value);
    }
  });

  test('unknown Latin copy is never converted into pseudo Cyrillic', () {
    const source = 'unknownProvider customMetric alphaBuild';
    expect(AppLocalizer.toRussian(source), source);
  });

  test('Russian product labels still use authored translations', () {
    expect(AppLocalizer.toRussian('Company website'), 'Сайт компании');
    expect(AppLocalizer.toRussian('Cloud platform'), 'Облачная платформа');
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

  test('authored English UI copy contains no Cyrillic', () {
    final result = AppLocalizer.toEnglish(
      'День 4 · Команда проекта · Вычислительная мощность · Переговоры',
    );
    expect(RegExp(r'[А-Яа-яЁё]').hasMatch(result), isFalse);
    expect(result, contains('Day'));
    expect(result.toLowerCase(), contains('project team'));
  });

  test('English overview uses authored copy instead of transliteration', () {
    const expected = <String, String>{
      'Операционная сводка': 'Operations overview',
      'Выделено продуктам': 'Allocated to products',
      'Активные контракты': 'Active contracts',
      'Портфель внешних долей': 'External equity portfolio',
      'Активная работа': 'Current work',
      'Собственных продуктов пока нет.': 'No owned products yet.',
      'Создайте первый продукт во вкладке «Продукты».':
          'Create your first product in the Products tab.',
      'Важные новости': 'Important news',
      'Пока пусто.': 'Nothing yet.',
      'Причины последних изменений': 'Reasons for recent changes',
      'Лента объясняет решения и ограничения.':
          'The feed explains decisions and constraints.',
    };

    for (final entry in expected.entries) {
      expect(AppLocalizer.toEnglish(entry.key), entry.value, reason: entry.key);
    }
  });

  test('missing English copy is never converted to pseudo-English', () {
    const source = 'Новая непереведённая фраза';
    expect(AppLocalizer.toEnglish(source), source);
  });
}
