// UAT_FIXPACK_R1
import '../entities/business_models.dart';
import '../entities/models.dart';

abstract final class ContractCatalog {
  static const List<ContractTemplate> templates = <ContractTemplate>[
    ContractTemplate(
      id: 'landing_launch',
      name: 'Лендинг запуска',
      client: 'Northline Foods',
      description: 'Одностраничный сайт с формой заявки и базовой аналитикой.',
      reward: 220000,
      developmentHours: 70,
      deadlineDays: 10,
      upfrontPercent: 0.30,
      requiredRoles: <EmployeeRole>[EmployeeRole.frontend],
      graceDays: 3,
    ),
    ContractTemplate(
      id: 'internal_dashboard',
      name: 'Внутренняя панель',
      client: 'Atlas Logistics',
      description:
          'Авторизация, таблицы, роли и отчётность для операционной команды.',
      reward: 520000,
      developmentHours: 170,
      deadlineDays: 18,
      upfrontPercent: 0.25,
      requiredRoles: <EmployeeRole>[
        EmployeeRole.frontend,
        EmployeeRole.backend,
      ],
      graceDays: 4,
    ),
    ContractTemplate(
      id: 'mobile_prototype',
      name: 'Мобильный прототип',
      client: 'Luma Retail',
      description:
          'Прототип клиентского приложения с каталогом и авторизацией.',
      reward: 760000,
      developmentHours: 230,
      deadlineDays: 24,
      upfrontPercent: 0.25,
      requiredRoles: <EmployeeRole>[
        EmployeeRole.mobile,
        EmployeeRole.designer,
        EmployeeRole.qa,
      ],
      graceDays: 5,
    ),
    ContractTemplate(
      id: 'api_integration',
      name: 'API-интеграция',
      client: 'Boreal Systems',
      description:
          'Интеграционный слой, очереди и наблюдаемость для внешних сервисов.',
      reward: 980000,
      developmentHours: 285,
      deadlineDays: 28,
      upfrontPercent: 0.20,
      requiredRoles: <EmployeeRole>[
        EmployeeRole.backend,
        EmployeeRole.devOps,
        EmployeeRole.qa,
      ],
      graceDays: 5,
    ),
    ContractTemplate(
      id: 'ai_support_pilot',
      name: 'AI-пилот поддержки',
      client: 'Vertex Travel',
      description:
          'Пилотный AI-помощник для классификации обращений и черновиков ответов.',
      reward: 1350000,
      developmentHours: 360,
      deadlineDays: 32,
      upfrontPercent: 0.20,
      requiredRoles: <EmployeeRole>[
        EmployeeRole.aiMl,
        EmployeeRole.backend,
        EmployeeRole.qa,
      ],
      graceDays: 6,
    ),
  ];

  static const List<String> _clients = <String>[
    'Northline Foods',
    'Atlas Logistics',
    'Luma Retail',
    'Boreal Systems',
    'Vertex Travel',
    'Orion Health',
    'Pinecone Commerce',
    'Helix Manufacturing',
    'Nimbus Media',
    'Copper Bank',
    'Solis Mobility',
    'Arctic Labs',
    'Mosaic Education',
    'Harbor Hotels',
    'Keystone Energy',
    'Vela Studios',
  ];

  static const List<String> _simpleNames = <String>[
    'Промо-лендинг',
    'Сайт события',
    'Форма заявок',
    'Мини-кабинет',
    'Каталог услуг',
    'Панель отчётности',
  ];

  static const List<String> _growthNames = <String>[
    'Клиентский портал',
    'Мобильный MVP',
    'CRM-модуль',
    'Интеграционный API',
    'Система аналитики',
    'Автоматизация операций',
  ];

  static const List<String> _scaleNames = <String>[
    'B2B-платформа',
    'Платёжный модуль',
    'Realtime workspace',
    'Data platform',
    'AI-пилот',
    'Мультисервисная интеграция',
  ];

  static const List<String> _enterpriseNames = <String>[
    'Enterprise platform',
    'AI operations suite',
    'Глобальная data-система',
    'Финансовый контур',
    'Высоконагруженный marketplace',
    'Cloud migration program',
  ];

  static int tierForCompleted(int completedCount) => switch (completedCount) {
    < 3 => 0,
    < 8 => 1,
    < 15 => 2,
    _ => 3,
  };

  static List<ContractTemplate> weeklyOffers({
    required int seed,
    required int week,
    required int completedCount,
    int count = 6,
  }) {
    final safeCount = count.clamp(3, 8).toInt();
    final tier = tierForCompleted(completedCount);
    final seedToken = seed & 0xffff;
    return List<ContractTemplate>.generate(
      safeCount,
      (slot) => _generatedOffer(
        seedToken: seedToken,
        week: week < 0 ? 0 : week,
        tier: tier,
        slot: slot,
      ),
      growable: false,
    );
  }

  static ContractTemplate byId(String id) {
    final staticMatches = templates.where((item) => item.id == id);
    if (staticMatches.isNotEmpty) {
      return staticMatches.first;
    }
    if (id.startsWith('weekly_')) {
      final parts = id.split('_');
      if (parts.length == 5) {
        final seedToken = int.tryParse(parts[1]);
        final week = int.tryParse(parts[2]);
        final tier = int.tryParse(parts[3]);
        final slot = int.tryParse(parts[4]);
        if (seedToken != null &&
            week != null &&
            tier != null &&
            slot != null &&
            tier >= 0 &&
            tier <= 3 &&
            slot >= 0 &&
            slot < 8) {
          return _generatedOffer(
            seedToken: seedToken,
            week: week,
            tier: tier,
            slot: slot,
          );
        }
      }
    }
    throw ArgumentError.value(id, 'id', 'Unknown contract template');
  }

  static ContractTemplate _generatedOffer({
    required int seedToken,
    required int week,
    required int tier,
    required int slot,
  }) {
    final roll = _hash(seedToken, week, tier, slot);
    final names = switch (tier) {
      0 => _simpleNames,
      1 => _growthNames,
      2 => _scaleNames,
      _ => _enterpriseNames,
    };
    final name = names[(roll ~/ 7) % names.length];
    final client = _clients[(roll ~/ 31 + week + slot * 3) % _clients.length];
    final roles = _rolesFor(tier, roll);

    final baseReward = switch (tier) {
      0 => 150000.0,
      1 => 360000.0,
      2 => 820000.0,
      _ => 1750000.0,
    };
    final baseHours = switch (tier) {
      0 => 54.0,
      1 => 125.0,
      2 => 280.0,
      _ => 590.0,
    };
    final spread = 0.86 + ((roll % 29) / 100);
    final reward =
        ((baseReward * spread * (1 + slot * 0.025)) / 5000).round() * 5000.0;
    final hours = (baseHours * (0.88 + ((roll ~/ 13) % 31) / 100))
        .roundToDouble();
    final deadlineDays = switch (tier) {
      0 => 8 + roll % 7,
      1 => 15 + roll % 9,
      2 => 24 + roll % 13,
      _ => 38 + roll % 18,
    };
    final upfront = switch (tier) {
      0 => 0.32,
      1 => 0.28,
      2 => 0.24,
      _ => 0.20,
    };

    return ContractTemplate(
      id: 'weekly_${seedToken}_${week}_${tier}_$slot',
      name: name,
      client: client,
      description: switch (tier) {
        0 =>
          'Небольшой заказ с коротким сроком. Хорош для первых выполненных контрактов.',
        1 =>
          'Рабочий продукт для действующего бизнеса: требуется несколько специальностей.',
        2 =>
          'Сложный коммерческий проект с интеграциями, качеством и заметной ответственностью за срок.',
        _ =>
          'Крупный enterprise-заказ: дорогой, долгий и требовательный к сильной многопрофильной команде.',
      },
      reward: reward,
      developmentHours: hours,
      deadlineDays: deadlineDays,
      upfrontPercent: upfront,
      requiredRoles: roles,
      graceDays: 3 + tier,
    );
  }

  static List<EmployeeRole> _rolesFor(int tier, int roll) {
    const pools = <List<EmployeeRole>>[
      <EmployeeRole>[
        EmployeeRole.frontend,
        EmployeeRole.backend,
        EmployeeRole.mobile,
        EmployeeRole.designer,
      ],
      <EmployeeRole>[
        EmployeeRole.frontend,
        EmployeeRole.backend,
        EmployeeRole.mobile,
        EmployeeRole.qa,
        EmployeeRole.designer,
        EmployeeRole.devOps,
      ],
      <EmployeeRole>[
        EmployeeRole.backend,
        EmployeeRole.mobile,
        EmployeeRole.qa,
        EmployeeRole.devOps,
        EmployeeRole.security,
        EmployeeRole.aiMl,
        EmployeeRole.frontend,
      ],
      <EmployeeRole>[
        EmployeeRole.productManager,
        EmployeeRole.backend,
        EmployeeRole.frontend,
        EmployeeRole.qa,
        EmployeeRole.devOps,
        EmployeeRole.security,
        EmployeeRole.aiMl,
        EmployeeRole.mobile,
      ],
    ];
    final pool = pools[tier];
    final count = switch (tier) {
      0 => 1 + roll % 2,
      1 => 2 + roll % 2,
      2 => 3 + roll % 2,
      _ => 4 + roll % 2,
    };
    final start = (roll ~/ 17) % pool.length;
    final result = <EmployeeRole>[];
    for (var index = 0; index < count; index += 1) {
      final role = pool[(start + index) % pool.length];
      if (!result.contains(role)) result.add(role);
    }
    return List<EmployeeRole>.unmodifiable(result);
  }

  static int _hash(int seed, int week, int tier, int slot) {
    var value = (seed ^ (week * 0x45d9f3b) ^ (tier * 0x27d4eb2d)) & 0x7fffffff;
    value = (value + slot * 0x165667b1) & 0x7fffffff;
    value = ((value ^ (value >> 16)) * 0x45d9f3b) & 0x7fffffff;
    value = ((value ^ (value >> 16)) * 0x45d9f3b) & 0x7fffffff;
    return (value ^ (value >> 16)) & 0x7fffffff;
  }
}
