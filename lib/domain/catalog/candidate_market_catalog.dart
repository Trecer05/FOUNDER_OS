// UAT_FIXPACK_R1
import '../entities/models.dart';

/// Deterministic procedural labour market.
///
/// Only the name pools and grade bands are authored. Every candidate profile
/// (role, seniority, skills, salary, languages and work format) is generated
/// from the game seed and a never-reused market ordinal.
abstract final class CandidateMarketCatalog {
  static const int initialMarketSize = 48;
  static const int weeklyRefreshCount = 8;
  static const int maximumVisibleCandidates = 64;

  static const List<String> firstNames = <String>[
    'Александр',
    'Алексей',
    'Алина',
    'Алёна',
    'Анастасия',
    'Андрей',
    'Анна',
    'Антон',
    'Арина',
    'Артём',
    'Артур',
    'Борис',
    'Вадим',
    'Валерия',
    'Варвара',
    'Вера',
    'Вероника',
    'Виктор',
    'Виктория',
    'Влад',
    'Владимир',
    'Галина',
    'Георгий',
    'Глеб',
    'Даниил',
    'Дарья',
    'Денис',
    'Диана',
    'Дмитрий',
    'Евгений',
    'Евгения',
    'Егор',
    'Екатерина',
    'Елена',
    'Иван',
    'Илья',
    'Ирина',
    'Кирилл',
    'Ксения',
    'Лев',
    'Леонид',
    'Лилия',
    'Макар',
    'Максим',
    'Маргарита',
    'Марина',
    'Мария',
    'Марк',
    'Матвей',
    'Михаил',
    'Надежда',
    'Наталья',
    'Никита',
    'Олег',
    'Ольга',
    'Павел',
    'Полина',
    'Роман',
    'Светлана',
    'Семён',
    'Сергей',
    'София',
    'Степан',
    'Тамара',
    'Татьяна',
    'Тимур',
    'Фёдор',
    'Юлия',
    'Юрий',
    'Яна',
    'Ярослав',
    'Амир',
    'Арсен',
    'Ринат',
    'Майя',
    'Элина',
    'Роберт',
    'Эмиль',
    'Камилла',
    'Милана',
  ];

  static const Set<String> _femaleFirstNames = <String>{
    'Алина',
    'Алёна',
    'Анастасия',
    'Анна',
    'Арина',
    'Валерия',
    'Варвара',
    'Вера',
    'Вероника',
    'Виктория',
    'Галина',
    'Дарья',
    'Диана',
    'Евгения',
    'Екатерина',
    'Елена',
    'Ирина',
    'Ксения',
    'Лилия',
    'Маргарита',
    'Марина',
    'Мария',
    'Надежда',
    'Наталья',
    'Ольга',
    'Полина',
    'Светлана',
    'София',
    'Тамара',
    'Татьяна',
    'Юлия',
    'Яна',
    'Майя',
    'Элина',
    'Камилла',
    'Милана',
  };

  static const List<String> lastNames = <String>[
    'Абрамов',
    'Агапов',
    'Акимов',
    'Александров',
    'Андреев',
    'Анисимов',
    'Антонов',
    'Баранов',
    'Белов',
    'Беляев',
    'Богданов',
    'Борисов',
    'Быков',
    'Васильев',
    'Виноградов',
    'Власов',
    'Волков',
    'Воробьёв',
    'Воронцов',
    'Гаврилов',
    'Герасимов',
    'Голубев',
    'Горбунов',
    'Громов',
    'Гусев',
    'Давыдов',
    'Данилов',
    'Демидов',
    'Денисов',
    'Дмитриев',
    'Дорофеев',
    'Егоров',
    'Елисеев',
    'Ершов',
    'Ефимов',
    'Жуков',
    'Зайцев',
    'Захаров',
    'Зотов',
    'Иванов',
    'Ильин',
    'Карпов',
    'Ким',
    'Кириллов',
    'Киселёв',
    'Ковалёв',
    'Комаров',
    'Королёв',
    'Котов',
    'Крылов',
    'Кузнецов',
    'Куликов',
    'Лазарев',
    'Лебедев',
    'Макаров',
    'Мартынов',
    'Матвеев',
    'Мельников',
    'Миронов',
    'Михайлов',
    'Морозов',
    'Наумов',
    'Назаров',
    'Никитин',
    'Новиков',
    'Орлов',
    'Осипов',
    'Павлов',
    'Панов',
    'Петров',
    'Поляков',
    'Попов',
    'Родионов',
    'Романов',
    'Руденко',
    'Рябов',
    'Сафин',
    'Семёнов',
    'Сидоров',
    'Смирнов',
    'Соболев',
    'Соколов',
    'Соловьёв',
    'Сорокин',
    'Степанов',
    'Тарасов',
    'Титов',
    'Тихонов',
    'Третьяков',
    'Фёдоров',
    'Фомин',
    'Фролов',
    'Харитонов',
    'Чернов',
    'Шаров',
    'Шестаков',
    'Щербаков',
    'Юдин',
    'Яковлев',
    'Яшин',
  ];

  static String surnameForFirstName(String firstName, String surname) {
    if (!_femaleFirstNames.contains(firstName)) return surname;
    if (surname.endsWith('\u0441\u043a\u0438\u0439')) {
      return '${surname.substring(0, surname.length - 4)}\u0441\u043a\u0430\u044f';
    }
    if (surname.endsWith('\u0446\u043a\u0438\u0439')) {
      return '${surname.substring(0, surname.length - 4)}\u0446\u043a\u0430\u044f';
    }
    if (surname.endsWith('\u0451\u0432')) {
      return '$surname\u0430';
    }
    if (surname.endsWith('\u043e\u0432') ||
        surname.endsWith('\u0435\u0432') ||
        surname.endsWith('\u0438\u043d') ||
        surname.endsWith('\u044b\u043d')) {
      return '$surname\u0430';
    }
    return surname;
  }

  static List<Candidate> initialMarket({required int seed}) =>
      _generate(seed: seed, startOrdinal: 0, count: initialMarketSize);

  static List<Candidate> weeklyArrivals({
    required int seed,
    required int week,
  }) {
    final normalizedWeek = week < 1 ? 1 : week;
    return _generate(
      seed: seed,
      startOrdinal:
          initialMarketSize + (normalizedWeek - 1) * weeklyRefreshCount,
      count: weeklyRefreshCount,
    );
  }

  static Candidate? sourceForHr({
    required int seed,
    required EmployeeRole role,
    required EmployeeGrade maximumGrade,
    required Set<String> excludedIds,
    required Set<String> excludedNames,
    bool requireRemote = false,
  }) {
    final scanEnd = nameCombinationCount < initialMarketSize + 2400
        ? nameCombinationCount
        : initialMarketSize + 2400;
    for (
      var gradeIndex = maximumGrade.index;
      gradeIndex >= 0;
      gradeIndex -= 1
    ) {
      final grade = EmployeeGrade.values[gradeIndex];
      for (var ordinal = initialMarketSize; ordinal < scanEnd; ordinal += 1) {
        final candidate = _candidate(seed, ordinal);
        if (candidate.isHr ||
            candidate.role != role ||
            candidate.grade != grade ||
            (requireRemote && !candidate.remote) ||
            excludedIds.contains(candidate.id) ||
            excludedNames.contains(candidate.name)) {
          continue;
        }
        return candidate;
      }
    }
    return null;
  }

  static List<Candidate> _generate({
    required int seed,
    required int startOrdinal,
    required int count,
  }) {
    final remainingUniqueNames = nameCombinationCount - startOrdinal;
    if (remainingUniqueNames <= 0) return const <Candidate>[];
    final safeCount = count < remainingUniqueNames
        ? count
        : remainingUniqueNames;
    return List<Candidate>.generate(
      safeCount,
      (index) => _candidate(seed, startOrdinal + index),
      growable: false,
    );
  }

  static Candidate _candidate(int seed, int ordinal) {
    final grade = _gradeFor(_roll(seed, ordinal, 1) % 100);
    final isHr = ordinal % 53 == 7;
    final role = isHr
        ? EmployeeRole.productManager
        : EmployeeRole.values[(_roll(seed, 0, 2) + ordinal * 5) %
              EmployeeRole.values.length];
    final band = _metricBand(grade);
    final skill = _between(seed, ordinal, 10, band.$1, band.$2);
    final speed = _between(seed, ordinal, 11, band.$1, band.$2);
    final quality = _between(seed, ordinal, 12, band.$1, band.$2);
    final autonomy = _between(seed, ordinal, 13, band.$1, band.$2);
    final communication = _between(seed, ordinal, 14, band.$1, band.$2);
    final reliability = _between(seed, ordinal, 15, band.$1, band.$2);
    final salaryBand = _salaryBand(grade);
    final salaryPosition = (skill + quality + autonomy + reliability) / 4 / 100;
    final salaryRaw =
        (salaryBand.$1 + (salaryBand.$2 - salaryBand.$1) * salaryPosition) *
        _roleSalaryMultiplier(role);
    final salary = (salaryRaw / 5000).round() * 5000.0;
    final nameIndex =
        (_roll(seed, 0, 91) + ordinal * 7919) % nameCombinationCount;
    final firstName = firstNames[nameIndex % firstNames.length];
    final lastName =
        lastNames[(nameIndex ~/ firstNames.length) % lastNames.length];
    final displayLastName = surnameForFirstName(firstName, lastName);

    return Candidate(
      id: 'candidate_${seed & 0xffff}_$ordinal',
      name: '$firstName $displayLastName',
      role: role,
      grade: grade,
      skill: skill,
      speed: speed,
      quality: quality,
      autonomy: autonomy,
      communication: communication,
      reliability: reliability,
      salary: salary,
      loyalty: _between(seed, ordinal, 16, 55, 94),
      remote: _roll(seed, ordinal, 17) % 100 < 72,
      languageIds: isHr
          ? const <String>[]
          : _languagesFor(role, grade, seed, ordinal),
      isHr: isHr,
    );
  }

  static int get nameCombinationCount => firstNames.length * lastNames.length;

  static EmployeeGrade _gradeFor(int roll) => switch (roll) {
    < 14 => EmployeeGrade.intern,
    < 44 => EmployeeGrade.junior,
    < 78 => EmployeeGrade.middle,
    _ => EmployeeGrade.senior,
  };

  static (int, int) _metricBand(EmployeeGrade grade) => switch (grade) {
    EmployeeGrade.intern => (28, 52),
    EmployeeGrade.junior => (44, 67),
    EmployeeGrade.middle => (61, 83),
    EmployeeGrade.senior => (78, 97),
  };

  static (double, double) _salaryBand(EmployeeGrade grade) => switch (grade) {
    EmployeeGrade.intern => (55000, 95000),
    EmployeeGrade.junior => (90000, 165000),
    EmployeeGrade.middle => (170000, 300000),
    EmployeeGrade.senior => (300000, 520000),
  };

  static double _roleSalaryMultiplier(EmployeeRole role) => switch (role) {
    EmployeeRole.aiMl => 1.20,
    EmployeeRole.security => 1.16,
    EmployeeRole.devOps => 1.12,
    EmployeeRole.backend => 1.08,
    EmployeeRole.productManager => 1.08,
    EmployeeRole.mobile => 1.05,
    EmployeeRole.frontend => 1.00,
    EmployeeRole.sales => 1.00,
    EmployeeRole.growth => 0.98,
    EmployeeRole.designer => 0.95,
    EmployeeRole.qa => 0.90,
    EmployeeRole.support => 0.76,
  };

  static List<String> _languagesFor(
    EmployeeRole role,
    EmployeeGrade grade,
    int seed,
    int ordinal,
  ) {
    final pool = switch (role) {
      EmployeeRole.frontend => const <String>[
        'typescript',
        'javascript',
        'html_css',
        'dart',
      ],
      EmployeeRole.backend => const <String>[
        'go',
        'typescript',
        'python',
        'java',
        'csharp',
        'ruby',
        'elixir',
        'scala',
        'php',
        'rust',
      ],
      EmployeeRole.mobile => const <String>['swift', 'kotlin', 'dart'],
      EmployeeRole.aiMl => const <String>['python', 'cpp', 'rust', 'go'],
      EmployeeRole.devOps => const <String>['go', 'python', 'rust', 'java'],
      EmployeeRole.security => const <String>['rust', 'go', 'cpp', 'java'],
      EmployeeRole.qa => const <String>[
        'typescript',
        'python',
        'java',
        'csharp',
      ],
      _ => const <String>[],
    };
    if (pool.isEmpty) return const <String>[];
    final desired = switch (grade) {
      EmployeeGrade.intern => 1,
      EmployeeGrade.junior => 2,
      EmployeeGrade.middle => 3,
      EmployeeGrade.senior => 3,
    };
    final start =
        (_roll(seed, 0, 31) + (ordinal ~/ EmployeeRole.values.length) * 3) %
        pool.length;
    return List<String>.generate(
      desired > pool.length ? pool.length : desired,
      (index) => pool[(start + index) % pool.length],
      growable: false,
    );
  }

  static int _between(
    int seed,
    int ordinal,
    int salt,
    int minimum,
    int maximum,
  ) => minimum + _roll(seed, ordinal, salt) % (maximum - minimum + 1);

  static int _roll(int seed, int ordinal, int salt) {
    var value =
        (seed ^ (ordinal * 0x45d9f3b) ^ (salt * 0x27d4eb2d)) & 0x7fffffff;
    value = ((value ^ (value >> 16)) * 0x45d9f3b) & 0x7fffffff;
    value = ((value ^ (value >> 16)) * 0x45d9f3b) & 0x7fffffff;
    return (value ^ (value >> 16)) & 0x7fffffff;
  }
}
