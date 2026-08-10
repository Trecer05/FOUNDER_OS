import '../entities/models.dart';
import '../entities/v16_models.dart';
import '../entities/v17_models.dart';

class CompanyPerkDefinition {
  const CompanyPerkDefinition({
    required this.id,
    required this.name,
    required this.description,
    required this.upfrontCost,
    required this.monthlyCost,
    required this.loyaltyBonus,
    required this.moraleBonus,
    required this.productivityBonus,
  });

  final String id;
  final String name;
  final String description;
  final double upfrontCost;
  final double monthlyCost;
  final int loyaltyBonus;
  final int moraleBonus;
  final double productivityBonus;
}

class MarketLegendDefinition {
  const MarketLegendDefinition({
    required this.id,
    required this.name,
    required this.role,
    required this.salary,
    required this.signingCost,
    required this.requiredReleasedProducts,
    required this.requiredValuation,
    required this.requiredOfficeCityId,
    required this.requiredOfficeQuality,
    required this.bonusKinds,
    required this.description,
  });

  final String id;
  final String name;
  final EmployeeRole role;
  final double salary;
  final double signingCost;
  final int requiredReleasedProducts;
  final double requiredValuation;
  final String requiredOfficeCityId;
  final FacilityQuality? requiredOfficeQuality;
  final List<LegendProductBonusKind> bonusKinds;
  final String description;
}

class IndustryEventDefinition {
  const IndustryEventDefinition({
    required this.id,
    required this.name,
    required this.description,
    required this.entryCost,
    required this.productSlotCost,
    required this.baseUsersPerProduct,
    required this.baseFanGain,
    required this.reputationGain,
  });

  final String id;
  final String name;
  final String description;
  final double entryCost;
  final double productSlotCost;
  final int baseUsersPerProduct;
  final int baseFanGain;
  final double reputationGain;
}

class WorldProjectDefinition {
  const WorldProjectDefinition({
    required this.id,
    required this.name,
    required this.description,
    required this.phaseCosts,
    required this.phaseDays,
    required this.monthlyOperatingCost,
    required this.minimumValuation,
    required this.minimumFans,
    required this.requiredCompletedResearch,
    required this.requiredUpgradeCount,
  });

  final String id;
  final String name;
  final String description;
  final List<double> phaseCosts;
  final List<int> phaseDays;
  final double monthlyOperatingCost;
  final double minimumValuation;
  final int minimumFans;
  final int requiredCompletedResearch;
  final int requiredUpgradeCount;
}

class WorldProjectUpgradeDefinition {
  const WorldProjectUpgradeDefinition({
    required this.id,
    required this.projectId,
    required this.name,
    required this.description,
    required this.cost,
    required this.days,
  });

  final String id;
  final String projectId;
  final String name;
  final String description;
  final double cost;
  final int days;
}

abstract final class V17EndgameCatalog {
  static const companyPerks = <CompanyPerkDefinition>[
    CompanyPerkDefinition(
      id: 'premium_workstations',
      name: 'Премиальное железо',
      description: 'Топовые рабочие станции, мониторы и периферия.',
      upfrontCost: 2800000,
      monthlyCost: 180000,
      loyaltyBonus: 6,
      moraleBonus: 4,
      productivityBonus: 0.035,
    ),
    CompanyPerkDefinition(
      id: 'health_insurance',
      name: 'ДМС+',
      description: 'Расширенная медицина и стоматология для команды.',
      upfrontCost: 350000,
      monthlyCost: 420000,
      loyaltyBonus: 8,
      moraleBonus: 5,
      productivityBonus: 0.01,
    ),
    CompanyPerkDefinition(
      id: 'office_taxi',
      name: 'Такси до офиса',
      description:
          'Компания оплачивает поездки сотрудников, которые работают on-site.',
      upfrontCost: 180000,
      monthlyCost: 650000,
      loyaltyBonus: 6,
      moraleBonus: 6,
      productivityBonus: 0.012,
    ),
    CompanyPerkDefinition(
      id: 'meals_and_coffee',
      name: 'Питание и кофе',
      description: 'Полноценное питание в офисах и круглосуточные кухни.',
      upfrontCost: 500000,
      monthlyCost: 780000,
      loyaltyBonus: 5,
      moraleBonus: 7,
      productivityBonus: 0.015,
    ),
    CompanyPerkDefinition(
      id: 'education_budget',
      name: 'Личный бюджет развития',
      description: 'Конференции, книги и обучение без отдельного согласования.',
      upfrontCost: 900000,
      monthlyCost: 1100000,
      loyaltyBonus: 9,
      moraleBonus: 4,
      productivityBonus: 0.022,
    ),
    CompanyPerkDefinition(
      id: 'family_support',
      name: 'Family support',
      description:
          'Страхование семьи, помощь с детским садом и экстренными расходами.',
      upfrontCost: 1200000,
      monthlyCost: 1600000,
      loyaltyBonus: 12,
      moraleBonus: 8,
      productivityBonus: 0.01,
    ),
  ];

  static const legends = <MarketLegendDefinition>[
    MarketLegendDefinition(
      id: 'legend_architect',
      name: 'Алекс Рейн',
      role: EmployeeRole.backend,
      salary: 8500000,
      signingCost: 95000000,
      requiredReleasedProducts: 3,
      requiredValuation: 3000000000,
      requiredOfficeCityId: 'limassol',
      requiredOfficeQuality: FacilityQuality.premium,
      bonusKinds: <LegendProductBonusKind>[
        LegendProductBonusKind.performance,
        LegendProductBonusKind.reliability,
      ],
      description: 'Архитектор распределённых систем.',
    ),
    MarketLegendDefinition(
      id: 'legend_ai',
      name: 'Мира Чен',
      role: EmployeeRole.aiMl,
      salary: 12000000,
      signingCost: 180000000,
      requiredReleasedProducts: 4,
      requiredValuation: 8000000000,
      requiredOfficeCityId: 'san_francisco',
      requiredOfficeQuality: FacilityQuality.premium,
      bonusKinds: <LegendProductBonusKind>[
        LegendProductBonusKind.aiQuality,
        LegendProductBonusKind.retention,
      ],
      description: 'Исследователь мирового уровня в AI.',
    ),
    MarketLegendDefinition(
      id: 'legend_product',
      name: 'Ник Вейл',
      role: EmployeeRole.productManager,
      salary: 7200000,
      signingCost: 78000000,
      requiredReleasedProducts: 5,
      requiredValuation: 5000000000,
      requiredOfficeCityId: '',
      requiredOfficeQuality: FacilityQuality.premium,
      bonusKinds: <LegendProductBonusKind>[
        LegendProductBonusKind.activation,
        LegendProductBonusKind.retention,
      ],
      description: 'Создавал продукты с десятками миллионов пользователей.',
    ),
    MarketLegendDefinition(
      id: 'legend_growth',
      name: 'София Маркес',
      role: EmployeeRole.growth,
      salary: 6800000,
      signingCost: 72000000,
      requiredReleasedProducts: 4,
      requiredValuation: 6000000000,
      requiredOfficeCityId: 'dubai',
      requiredOfficeQuality: FacilityQuality.standard,
      bonusKinds: <LegendProductBonusKind>[
        LegendProductBonusKind.growth,
        LegendProductBonusKind.brand,
      ],
      description: 'Growth-лидер мирового уровня.',
    ),
    MarketLegendDefinition(
      id: 'legend_security',
      name: 'Итан Кроу',
      role: EmployeeRole.security,
      salary: 9000000,
      signingCost: 110000000,
      requiredReleasedProducts: 3,
      requiredValuation: 4500000000,
      requiredOfficeCityId: 'helsinki',
      requiredOfficeQuality: FacilityQuality.premium,
      bonusKinds: <LegendProductBonusKind>[
        LegendProductBonusKind.security,
        LegendProductBonusKind.reliability,
      ],
      description: 'Легенда application security.',
    ),
  ];

  static const industryEvents = <IndustryEventDefinition>[
    IndustryEventDefinition(
      id: 'global_tech_expo',
      name: 'Global Tech Expo',
      description: 'Крупнейшая мировая продуктовая выставка.',
      entryCost: 18000000,
      productSlotCost: 14000000,
      baseUsersPerProduct: 180000,
      baseFanGain: 95000,
      reputationGain: 4.5,
    ),
    IndustryEventDefinition(
      id: 'ai_world',
      name: 'AI World Summit',
      description: 'Саммит AI, инфраструктуры и инвесторов.',
      entryCost: 32000000,
      productSlotCost: 22000000,
      baseUsersPerProduct: 260000,
      baseFanGain: 140000,
      reputationGain: 6,
    ),
    IndustryEventDefinition(
      id: 'founder_week',
      name: 'Founder Week',
      description: 'Продуктовая конференция вокруг бренда и роста.',
      entryCost: 9500000,
      productSlotCost: 7500000,
      baseUsersPerProduct: 85000,
      baseFanGain: 70000,
      reputationGain: 3.2,
    ),
    IndustryEventDefinition(
      id: 'enterprise_forum',
      name: 'Enterprise Future Forum',
      description: 'Дорогой B2B-форум с крупными клиентами.',
      entryCost: 44000000,
      productSlotCost: 28000000,
      baseUsersPerProduct: 120000,
      baseFanGain: 55000,
      reputationGain: 7.5,
    ),
  ];

  static const worldProjects = <WorldProjectDefinition>[
    WorldProjectDefinition(
      id: 'world_os',
      name: 'AURA OS',
      description:
          'Собственная глобальная операционная система. Не стареет и имеет отдельное дерево платформенных возможностей.',
      phaseCosts: <double>[12000000000, 22000000000, 38000000000, 55000000000],
      phaseDays: <int>[45, 70, 95, 120],
      monthlyOperatingCost: 1800000000,
      minimumValuation: 25000000000,
      minimumFans: 1500000,
      requiredCompletedResearch: 12,
      requiredUpgradeCount: 8,
    ),
    WorldProjectDefinition(
      id: 'free_ai',
      name: 'OpenMind AI',
      description: 'Бесплатный AI мирового масштаба с огромным compute bill.',
      phaseCosts: <double>[18000000000, 32000000000, 52000000000, 78000000000],
      phaseDays: <int>[60, 85, 120, 150],
      monthlyOperatingCost: 2600000000,
      minimumValuation: 45000000000,
      minimumFans: 3000000,
      requiredCompletedResearch: 18,
      requiredUpgradeCount: 6,
    ),
    WorldProjectDefinition(
      id: 'planet_compute',
      name: 'Planet Compute Grid',
      description:
          'Глобальная вычислительная сеть из собственных ЦОДов и магистралей.',
      phaseCosts: <double>[25000000000, 45000000000, 80000000000, 125000000000],
      phaseDays: <int>[75, 110, 150, 180],
      monthlyOperatingCost: 3800000000,
      minimumValuation: 80000000000,
      minimumFans: 5000000,
      requiredCompletedResearch: 24,
      requiredUpgradeCount: 5,
    ),
  ];

  static const worldProjectUpgrades = <WorldProjectUpgradeDefinition>[
    WorldProjectUpgradeDefinition(
      id: 'os_sdk',
      projectId: 'world_os',
      name: 'Developer SDK',
      description: 'SDK и инструменты сторонних разработчиков.',
      cost: 5500000000,
      days: 30,
    ),
    WorldProjectUpgradeDefinition(
      id: 'os_store',
      projectId: 'world_os',
      name: 'App Store',
      description: 'Магазин приложений и экономика разработчиков.',
      cost: 9000000000,
      days: 45,
    ),
    WorldProjectUpgradeDefinition(
      id: 'os_security',
      projectId: 'world_os',
      name: 'Secure Enclave',
      description: 'Аппаратно-программная защита платформы.',
      cost: 7200000000,
      days: 36,
    ),
    WorldProjectUpgradeDefinition(
      id: 'os_sync',
      projectId: 'world_os',
      name: 'Cloud Sync',
      description: 'Синхронизация данных между устройствами.',
      cost: 6800000000,
      days: 34,
    ),
    WorldProjectUpgradeDefinition(
      id: 'os_ai',
      projectId: 'world_os',
      name: 'System AI',
      description: 'AI как системный слой ОС.',
      cost: 12000000000,
      days: 55,
    ),
    WorldProjectUpgradeDefinition(
      id: 'os_enterprise',
      projectId: 'world_os',
      name: 'Enterprise Fleet',
      description: 'Управление корпоративными устройствами.',
      cost: 8500000000,
      days: 42,
    ),
    WorldProjectUpgradeDefinition(
      id: 'os_privacy',
      projectId: 'world_os',
      name: 'Privacy Core',
      description: 'Приватность как архитектура платформы.',
      cost: 7600000000,
      days: 38,
    ),
    WorldProjectUpgradeDefinition(
      id: 'os_payments',
      projectId: 'world_os',
      name: 'Native Payments',
      description: 'Системные платежи и идентификация.',
      cost: 10500000000,
      days: 48,
    ),
    WorldProjectUpgradeDefinition(
      id: 'os_games',
      projectId: 'world_os',
      name: 'Graphics & Games',
      description: 'Игровой runtime и графический стек.',
      cost: 9800000000,
      days: 44,
    ),
    WorldProjectUpgradeDefinition(
      id: 'os_devices',
      projectId: 'world_os',
      name: 'Device Continuity',
      description: 'Единый UX между устройствами.',
      cost: 11500000000,
      days: 52,
    ),
    WorldProjectUpgradeDefinition(
      id: 'os_accessibility',
      projectId: 'world_os',
      name: 'Universal Access',
      description: 'Глубокие accessibility-функции.',
      cost: 4800000000,
      days: 28,
    ),
    WorldProjectUpgradeDefinition(
      id: 'os_open_api',
      projectId: 'world_os',
      name: 'Open Platform APIs',
      description: 'Открытые API экосистемы.',
      cost: 6200000000,
      days: 32,
    ),
    WorldProjectUpgradeDefinition(
      id: 'ai_multimodal',
      projectId: 'free_ai',
      name: 'Multimodal Core',
      description: 'Текст, голос, изображения и видео.',
      cost: 14000000000,
      days: 55,
    ),
    WorldProjectUpgradeDefinition(
      id: 'ai_agents',
      projectId: 'free_ai',
      name: 'Agent Runtime',
      description: 'Долгоживущие AI-агенты.',
      cost: 18000000000,
      days: 65,
    ),
    WorldProjectUpgradeDefinition(
      id: 'ai_local',
      projectId: 'free_ai',
      name: 'Local Models',
      description: 'Локальный inference и приватные модели.',
      cost: 12000000000,
      days: 48,
    ),
    WorldProjectUpgradeDefinition(
      id: 'ai_science',
      projectId: 'free_ai',
      name: 'Science Mode',
      description: 'Исследования, математика и инженерия.',
      cost: 20000000000,
      days: 72,
    ),
    WorldProjectUpgradeDefinition(
      id: 'ai_education',
      projectId: 'free_ai',
      name: 'Free Education',
      description: 'Бесплатный образовательный AI.',
      cost: 10000000000,
      days: 42,
    ),
    WorldProjectUpgradeDefinition(
      id: 'ai_translation',
      projectId: 'free_ai',
      name: 'Universal Translation',
      description: 'Перевод в реальном времени.',
      cost: 9000000000,
      days: 38,
    ),
    WorldProjectUpgradeDefinition(
      id: 'ai_enterprise',
      projectId: 'free_ai',
      name: 'Enterprise Isolation',
      description: 'Безопасный AI для организаций.',
      cost: 16500000000,
      days: 58,
    ),
    WorldProjectUpgradeDefinition(
      id: 'ai_creator',
      projectId: 'free_ai',
      name: 'Creator Studio',
      description: 'Инструменты создателей контента.',
      cost: 13000000000,
      days: 50,
    ),
    WorldProjectUpgradeDefinition(
      id: 'grid_backbone',
      projectId: 'planet_compute',
      name: 'Private Backbone',
      description: 'Собственная международная сеть.',
      cost: 22000000000,
      days: 70,
    ),
    WorldProjectUpgradeDefinition(
      id: 'grid_edge',
      projectId: 'planet_compute',
      name: 'Global Edge',
      description: 'Edge-узлы рядом с рынками.',
      cost: 18000000000,
      days: 58,
    ),
    WorldProjectUpgradeDefinition(
      id: 'grid_green',
      projectId: 'planet_compute',
      name: 'Green Power',
      description: 'Собственная энергетика для compute.',
      cost: 26000000000,
      days: 80,
    ),
    WorldProjectUpgradeDefinition(
      id: 'grid_ai_fabric',
      projectId: 'planet_compute',
      name: 'AI Fabric',
      description: 'Сеть для распределённого AI.',
      cost: 30000000000,
      days: 88,
    ),
    WorldProjectUpgradeDefinition(
      id: 'grid_failover',
      projectId: 'planet_compute',
      name: 'Planetary Failover',
      description: 'Глобальное аварийное переключение.',
      cost: 24000000000,
      days: 76,
    ),
    WorldProjectUpgradeDefinition(
      id: 'grid_sovereign',
      projectId: 'planet_compute',
      name: 'Sovereign Regions',
      description: 'Региональная изоляция данных.',
      cost: 21000000000,
      days: 68,
    ),
  ];

  static CompanyPerkDefinition perkById(String id) =>
      companyPerks.firstWhere((item) => item.id == id);
  static MarketLegendDefinition legendById(String id) =>
      legends.firstWhere((item) => item.id == id);
  static IndustryEventDefinition eventById(String id) =>
      industryEvents.firstWhere((item) => item.id == id);
  static WorldProjectDefinition worldProjectById(String id) =>
      worldProjects.firstWhere((item) => item.id == id);
  static WorldProjectUpgradeDefinition upgradeById(String id) =>
      worldProjectUpgrades.firstWhere((item) => item.id == id);
}
