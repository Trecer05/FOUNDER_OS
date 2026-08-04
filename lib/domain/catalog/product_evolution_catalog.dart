import '../entities/models.dart';
import '../entities/product_evolution_models.dart';

abstract final class ProductEvolutionCatalog {
  static const double corporateAiMonthlyCostPerIntegration = 45000;
  static const double corporateAiDevelopmentBoost = 0.18;
  static const double corporateAiQualityBoost = 4;
  static const double corporateAiBaseComputeDemand = 14;

  static const List<ProductImprovementOption> improvements = [
    ProductImprovementOption(
      type: ProductImprovementType.performance,
      name: 'Оптимизация скорости',
      description:
          'Профилирование, кэширование и оптимизация горячих путей. Можно повторять без жёсткого потолка.',
      baseCost: 180000,
      monthlyCostDelta: 8000,
      speedMultiplier: 0.94,
      designDelta: 0,
      securityDelta: 0,
      reliabilityDelta: 0.0005,
      qualityDelta: 0.8,
      retentionDelta: 0.001,
      computeMultiplier: 0.985,
    ),
    ProductImprovementOption(
      type: ProductImprovementType.algorithms,
      name: 'Улучшение алгоритмов',
      description:
          'Лучшее ранжирование, рекомендации и внутренняя логика. Повышает качество и удержание.',
      baseCost: 240000,
      monthlyCostDelta: 12000,
      speedMultiplier: 0.99,
      designDelta: 0,
      securityDelta: 0,
      reliabilityDelta: 0.0005,
      qualityDelta: 2.2,
      retentionDelta: 0.006,
      computeMultiplier: 1.025,
    ),
    ProductImprovementOption(
      type: ProductImprovementType.design,
      name: 'Обновление интерфейса',
      description:
          'Пересборка ключевых сценариев, визуальная свежесть и улучшение активации.',
      baseCost: 155000,
      monthlyCostDelta: 4000,
      speedMultiplier: 1,
      designDelta: 3.5,
      securityDelta: 0,
      reliabilityDelta: 0,
      qualityDelta: 1.1,
      retentionDelta: 0.003,
      computeMultiplier: 1,
    ),
    ProductImprovementOption(
      type: ProductImprovementType.security,
      name: 'Усиление архитектуры',
      description:
          'Ротация ключей, hardening и обновление зависимостей. Снижает устаревание security-контура.',
      baseCost: 210000,
      monthlyCostDelta: 14000,
      speedMultiplier: 1,
      designDelta: 0,
      securityDelta: 3,
      reliabilityDelta: 0.001,
      qualityDelta: 1,
      retentionDelta: 0.001,
      computeMultiplier: 1.01,
    ),
    ProductImprovementOption(
      type: ProductImprovementType.reliability,
      name: 'Рефакторинг надёжности',
      description:
          'Тесты, observability и устранение технического долга. Снижает churn и аварийность.',
      baseCost: 195000,
      monthlyCostDelta: 10000,
      speedMultiplier: 0.995,
      designDelta: 0,
      securityDelta: 0.5,
      reliabilityDelta: 0.003,
      qualityDelta: 1.3,
      retentionDelta: 0.004,
      computeMultiplier: 1.005,
    ),
  ];

  static ProductImprovementOption improvementByType(
    ProductImprovementType type,
  ) => improvements.firstWhere((item) => item.type == type);

  static List<ProductRoleRequirement> roleRequirements(
    ProductCategory category,
  ) => switch (category) {
    ProductCategory.aiAssistant => const [
      ProductRoleRequirement(
        role: EmployeeRole.productManager,
        minimumCount: 1,
        reason: 'Формирует сценарии и приоритеты AI-продукта.',
      ),
      ProductRoleRequirement(
        role: EmployeeRole.aiMl,
        minimumCount: 2,
        reason: 'Модель, evaluation, prompts и качество ответов.',
      ),
      ProductRoleRequirement(
        role: EmployeeRole.backend,
        minimumCount: 1,
        reason: 'API, очереди, биллинг и работа с моделями.',
      ),
      ProductRoleRequirement(
        role: EmployeeRole.devOps,
        minimumCount: 1,
        reason: 'GPU/CPU-инфраструктура и стабильность inference.',
      ),
      ProductRoleRequirement(
        role: EmployeeRole.qa,
        minimumCount: 1,
        reason: 'Regression и проверка качества ответов.',
      ),
    ],
    ProductCategory.cloud => const [
      ProductRoleRequirement(
        role: EmployeeRole.productManager,
        minimumCount: 1,
        reason: 'Управляет тарифами и приоритетами платформы.',
      ),
      ProductRoleRequirement(
        role: EmployeeRole.backend,
        minimumCount: 2,
        reason: 'Хранилище, API и распределённые сервисы.',
      ),
      ProductRoleRequirement(
        role: EmployeeRole.devOps,
        minimumCount: 2,
        reason: 'Доступность, сеть и эксплуатация.',
      ),
      ProductRoleRequirement(
        role: EmployeeRole.security,
        minimumCount: 1,
        reason: 'Доступы, шифрование и аудит.',
      ),
      ProductRoleRequirement(
        role: EmployeeRole.qa,
        minimumCount: 1,
        reason: 'Проверка отказоустойчивости и релизов.',
      ),
    ],
    ProductCategory.saas => const [
      ProductRoleRequirement(
        role: EmployeeRole.productManager,
        minimumCount: 1,
        reason: 'Приоритизация B2B/B2C-сценариев.',
      ),
      ProductRoleRequirement(
        role: EmployeeRole.frontend,
        minimumCount: 1,
        reason: 'Основные пользовательские сценарии.',
      ),
      ProductRoleRequirement(
        role: EmployeeRole.backend,
        minimumCount: 1,
        reason: 'Бизнес-логика и данные.',
      ),
      ProductRoleRequirement(
        role: EmployeeRole.designer,
        minimumCount: 1,
        reason: 'Активация и понятность продукта.',
      ),
      ProductRoleRequirement(
        role: EmployeeRole.qa,
        minimumCount: 1,
        reason: 'Качество релизов.',
      ),
    ],
    ProductCategory.browser => const [
      ProductRoleRequirement(
        role: EmployeeRole.frontend,
        minimumCount: 2,
        reason: 'Интерфейс и browser shell.',
      ),
      ProductRoleRequirement(
        role: EmployeeRole.backend,
        minimumCount: 1,
        reason: 'Синхронизация, аккаунты и сервисы.',
      ),
      ProductRoleRequirement(
        role: EmployeeRole.security,
        minimumCount: 1,
        reason: 'Sandbox, privacy и защита данных.',
      ),
      ProductRoleRequirement(
        role: EmployeeRole.designer,
        minimumCount: 1,
        reason: 'Повседневная удобная навигация.',
      ),
      ProductRoleRequirement(
        role: EmployeeRole.qa,
        minimumCount: 1,
        reason: 'Совместимость и стабильность.',
      ),
    ],
    ProductCategory.cryptoWallet => const [
      ProductRoleRequirement(
        role: EmployeeRole.productManager,
        minimumCount: 1,
        reason: 'Управляет рисками и пользовательскими потоками.',
      ),
      ProductRoleRequirement(
        role: EmployeeRole.backend,
        minimumCount: 2,
        reason: 'Транзакции и интеграция сетей.',
      ),
      ProductRoleRequirement(
        role: EmployeeRole.security,
        minimumCount: 2,
        reason: 'Ключи, угрозы и защита средств.',
      ),
      ProductRoleRequirement(
        role: EmployeeRole.mobile,
        minimumCount: 1,
        reason: 'Клиентское приложение и secure storage.',
      ),
      ProductRoleRequirement(
        role: EmployeeRole.qa,
        minimumCount: 1,
        reason: 'Критические проверки транзакций.',
      ),
    ],
    ProductCategory.developerTool => const [
      ProductRoleRequirement(
        role: EmployeeRole.productManager,
        minimumCount: 1,
        reason: 'Понимает workflow разработчиков.',
      ),
      ProductRoleRequirement(
        role: EmployeeRole.backend,
        minimumCount: 1,
        reason: 'Core, API и интеграции.',
      ),
      ProductRoleRequirement(
        role: EmployeeRole.frontend,
        minimumCount: 1,
        reason: 'IDE/web-интерфейс.',
      ),
      ProductRoleRequirement(
        role: EmployeeRole.devOps,
        minimumCount: 1,
        reason: 'CI/CD и окружения.',
      ),
      ProductRoleRequirement(
        role: EmployeeRole.qa,
        minimumCount: 1,
        reason: 'Совместимость и regression.',
      ),
    ],
  };
}
