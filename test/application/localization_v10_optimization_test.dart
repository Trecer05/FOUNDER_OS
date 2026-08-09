import 'package:flutter_test/flutter_test.dart';
import 'package:founder_os/application/localization/app_localizer.dart';
import 'package:founder_os/application/localization/v13_english_lexicon.dart';
import 'package:founder_os/application/settings/display_preferences.dart';
import 'package:founder_os/presentation/shared/widgets/formatters.dart';

String _normalizeGeneratedTemplate(String value) => value
    .replaceAll(r'\n', '\n')
    .replaceAll(r'\r', '\r')
    .replaceAll(r'\t', '\t');

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
    expect(
      RegExp(r'[А-Яа-яЁё]').hasMatch(result),
      isFalse,
      reason: 'source remained partially untranslated: $result',
    );
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

  test('complete English lexicon contains no Cyrillic output', () {
    final cyrillic = RegExp(r'[А-Яа-яЁё]');
    for (final entry in V13EnglishLexicon.exact.entries) {
      expect(cyrillic.hasMatch(entry.value), isFalse, reason: entry.key);
      expect(
        cyrillic.hasMatch(AppLocalizer.toEnglish(entry.key)),
        isFalse,
        reason: entry.key,
      );
    }
    for (final entry in V13EnglishLexicon.overrides.entries) {
      expect(cyrillic.hasMatch(entry.value), isFalse, reason: entry.key);
    }
    for (final template in V13EnglishLexicon.templates) {
      expect(
        cyrillic.hasMatch(template.target),
        isFalse,
        reason: template.source,
      );
      final runtimeSource = _normalizeGeneratedTemplate(template.source);
      expect(
        cyrillic.hasMatch(AppLocalizer.toEnglish(runtimeSource)),
        isFalse,
        reason: template.source,
      );
    }
    for (final entry in V13EnglishLexicon.templateOverrides.entries) {
      expect(cyrillic.hasMatch(entry.value), isFalse, reason: entry.key);
    }
  });

  test('English dynamic labels preserve values and translate the whole UI', () {
    expect(AppLocalizer.toEnglish('Найм +20%'), 'Hiring +20%');
    expect(AppLocalizer.toEnglish('Часы +45'), 'Hours +45');
    expect(AppLocalizer.toEnglish('Новый проект • 2/6'), 'New project • 2/6');
    expect(
      AppLocalizer.toEnglish('Сохранение повреждено: invalid snapshot'),
      'Save is corrupted: invalid snapshot',
    );
    expect(AppLocalizer.toEnglish('Сергей Третьяков'), 'Sergey Tretyakov');
    expect(AppLocalizer.toEnglish('С'), 'S');
  });

  test('multiline dynamic hints use the runtime template representation', () {
    expect(
      AppLocalizer.toEnglish('Недоступно\n\nСледующий шаг: Недоступно'),
      'Unavailable\n\nNext step: Unavailable',
    );
  });

  test('publisher UAT screenshot strings never leak Cyrillic in English', () {
    final cyrillic = RegExp(r'[А-Яа-яЁё]');
    for (final source in <String>[
      '+ Дешёвый найм',
      '− Ошибки растут вместе с кодовой базой',
      'Исследование и требования • 0%',
      '8.9 тыс. показов • 494 переходов • 48–142 пользователей',
      'Плюсы: Дешёвый старт • Не нужен DevOps',
      'Nova One → MERCURY.com • AI-автоматизация • интеграция ещё 12 дн. • рост +4% • compute ×1.16',
      'Активная работа',
      'Причины последних изменений',
    ]) {
      final translated = AppLocalizer.toEnglish(source);
      expect(cyrillic.hasMatch(translated), isFalse, reason: source);
    }
  });

  test('compact English metrics use K and M suffixes', () async {
    await DisplayPreferences.instance.setLanguage(AppLanguage.en);
    expect(compactNumber(8900), '8.9 K');
    expect(compactNumber(260000000), '260.0 M');
    await DisplayPreferences.instance.setLanguage(AppLanguage.ru);
  });

  test('nested candidate copy cannot leak Russian into English hints', () {
    final result = AppLocalizer.toEnglish(
      'Junior • Backend: Открывает автоматический подбор команды под проект. '
      'Грейд задаёт вилку зарплаты и показателей, конкретный профиль сгенерирован для этой игры. '
      'Языки: не указаны. Remote-кандидат не занимает офисное место.',
    );
    expect(RegExp(r'[А-Яа-яЁё]').hasMatch(result), isFalse);
    expect(result, contains('Grade determines'));
    expect(result, contains('Languages: not specified'));
  });
}
