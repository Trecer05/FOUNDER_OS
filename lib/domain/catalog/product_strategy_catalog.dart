import '../entities/models.dart';
import '../entities/product_strategy_models.dart';

abstract final class ProductStrategyCatalog {
  static const List<ProductStrategyProfile> products = <ProductStrategyProfile>[
    ProductStrategyProfile(
      blueprintId: 'company_website',
      scope: ProductScope.starter,
      shortDescription:
          'Первый дешёвый релиз. Открывает клиентские контракты и учит базовой экономике.',
      baseHours: 120,
      setupCost: 18000,
      minimumTeamSize: 1,
      optimalTeamSize: 2,
      maximumEfficientTeamSize: 3,
      requiredInvestorCount: 0,
      maximumLanguageCount: 2,
      maximumTechnologyCount: 1,
      allowedFrameworkIds: <String>['static_web', 'laravel_web'],
      recommendedLanguageIds: <String>['html_css', 'javascript'],
      allowedMonetizationModels: <MonetizationModel>[
        MonetizationModel.advertising,
      ],
      contractsUnlock: true,
      initialTrust: 0.18,
    ),
    ProductStrategyProfile(
      blueprintId: 'team_saas',
      scope: ProductScope.standard,
      shortDescription:
          'Средний B2B-продукт: нужен сбалансированный web/mobile состав.',
      baseHours: 920,
      setupCost: 52000,
      minimumTeamSize: 3,
      optimalTeamSize: 5,
      maximumEfficientTeamSize: 7,
      requiredInvestorCount: 0,
      maximumLanguageCount: 3,
      maximumTechnologyCount: 3,
      allowedFrameworkIds: <String>[
        'flutter_firebase',
        'next_nest',
        'fastapi_react',
        'java_enterprise',
      ],
      recommendedLanguageIds: <String>['typescript', 'go', 'dart'],
      allowedMonetizationModels: <MonetizationModel>[
        MonetizationModel.subscription,
        MonetizationModel.usageBased,
      ],
      contractsUnlock: false,
      initialTrust: 0.10,
    ),
    ProductStrategyProfile(
      blueprintId: 'ai_assistant',
      scope: ProductScope.advanced,
      shortDescription:
          'Рискованный AI-релиз с дорогой инфраструктурой и сильной зависимостью от команды.',
      baseHours: 1450,
      setupCost: 90000,
      minimumTeamSize: 4,
      optimalTeamSize: 7,
      maximumEfficientTeamSize: 10,
      requiredInvestorCount: 0,
      maximumLanguageCount: 3,
      maximumTechnologyCount: 3,
      allowedFrameworkIds: <String>[
        'fastapi_react',
        'next_nest',
        'flutter_firebase',
      ],
      recommendedLanguageIds: <String>['python', 'typescript', 'go'],
      allowedMonetizationModels: <MonetizationModel>[
        MonetizationModel.subscription,
        MonetizationModel.usageBased,
      ],
      contractsUnlock: false,
      initialTrust: 0.08,
    ),
    ProductStrategyProfile(
      blueprintId: 'developer_platform',
      scope: ProductScope.advanced,
      shortDescription:
          'Инфраструктурный B2B-продукт: качество API и надёжность важнее дизайна.',
      baseHours: 1750,
      setupCost: 120000,
      minimumTeamSize: 5,
      optimalTeamSize: 8,
      maximumEfficientTeamSize: 11,
      requiredInvestorCount: 1,
      maximumLanguageCount: 3,
      maximumTechnologyCount: 3,
      allowedFrameworkIds: <String>[
        'go_microservices',
        'next_nest',
        'fastapi_react',
        'java_enterprise',
      ],
      recommendedLanguageIds: <String>['go', 'typescript', 'rust'],
      allowedMonetizationModels: <MonetizationModel>[
        MonetizationModel.subscription,
        MonetizationModel.usageBased,
      ],
      contractsUnlock: false,
      initialTrust: 0.07,
    ),
    ProductStrategyProfile(
      blueprintId: 'privacy_browser',
      scope: ProductScope.advanced,
      shortDescription:
          'Большой desktop-продукт. Нужны системные разработчики, security и QA.',
      baseHours: 3200,
      setupCost: 180000,
      minimumTeamSize: 7,
      optimalTeamSize: 11,
      maximumEfficientTeamSize: 15,
      requiredInvestorCount: 2,
      maximumLanguageCount: 3,
      maximumTechnologyCount: 3,
      allowedFrameworkIds: <String>['chromium_fork', 'rust_core'],
      recommendedLanguageIds: <String>['rust', 'cpp', 'typescript'],
      allowedMonetizationModels: <MonetizationModel>[
        MonetizationModel.advertising,
        MonetizationModel.subscription,
      ],
      contractsUnlock: false,
      initialTrust: 0.05,
    ),
    ProductStrategyProfile(
      blueprintId: 'cloud_platform',
      scope: ProductScope.moonshot,
      shortDescription:
          'Крупная инфраструктура. Без инвесторов, DevOps и security старт заблокирован.',
      baseHours: 4600,
      setupCost: 260000,
      minimumTeamSize: 9,
      optimalTeamSize: 14,
      maximumEfficientTeamSize: 20,
      requiredInvestorCount: 3,
      maximumLanguageCount: 4,
      maximumTechnologyCount: 4,
      allowedFrameworkIds: <String>[
        'go_microservices',
        'java_enterprise',
        'rust_core',
      ],
      recommendedLanguageIds: <String>['go', 'rust', 'java'],
      allowedMonetizationModels: <MonetizationModel>[
        MonetizationModel.usageBased,
        MonetizationModel.subscription,
      ],
      contractsUnlock: false,
      initialTrust: 0.04,
    ),
    ProductStrategyProfile(
      blueprintId: 'crypto_wallet',
      scope: ProductScope.advanced,
      shortDescription:
          'Высокорисковый финансовый продукт. Security и доверие критичны.',
      baseHours: 2500,
      setupCost: 210000,
      minimumTeamSize: 6,
      optimalTeamSize: 10,
      maximumEfficientTeamSize: 13,
      requiredInvestorCount: 2,
      maximumLanguageCount: 3,
      maximumTechnologyCount: 3,
      allowedFrameworkIds: <String>[
        'rust_core',
        'go_microservices',
        'flutter_firebase',
      ],
      recommendedLanguageIds: <String>['rust', 'kotlin', 'swift'],
      allowedMonetizationModels: <MonetizationModel>[
        MonetizationModel.transactionFee,
      ],
      contractsUnlock: false,
      initialTrust: 0.03,
    ),
    ProductStrategyProfile(
      blueprintId: 'city_system',
      scope: ProductScope.moonshot,
      shortDescription:
          'Цифровая система города. Требует пять инвесторов, большую команду и годы разработки.',
      baseHours: 12000,
      setupCost: 600000,
      minimumTeamSize: 18,
      optimalTeamSize: 28,
      maximumEfficientTeamSize: 40,
      requiredInvestorCount: 5,
      maximumLanguageCount: 5,
      maximumTechnologyCount: 5,
      allowedFrameworkIds: <String>['java_enterprise', 'go_microservices'],
      recommendedLanguageIds: <String>['java', 'go', 'typescript', 'kotlin'],
      allowedMonetizationModels: <MonetizationModel>[
        MonetizationModel.usageBased,
        MonetizationModel.subscription,
      ],
      contractsUnlock: false,
      initialTrust: 0.02,
    ),
  ];

  static const List<LanguageStrategyProfile>
  languages = <LanguageStrategyProfile>[
    LanguageStrategyProfile(
      languageId: 'html_css',
      summary: 'Разметка и стили для простых сайтов.',
      strengths: <String>['Очень быстрый старт', 'Много специалистов'],
      weaknesses: <String>['Не подходит для сложной серверной логики'],
      bestForBlueprintIds: <String>['company_website'],
      complexityMultiplier: 0.78,
    ),
    LanguageStrategyProfile(
      languageId: 'javascript',
      summary: 'Быстрый web без строгой типизации.',
      strengths: <String>['Дешёвый найм', 'Быстрые MVP'],
      weaknesses: <String>['Ошибки растут вместе с кодовой базой'],
      bestForBlueprintIds: <String>['company_website', 'team_saas'],
      complexityMultiplier: 0.94,
    ),
    LanguageStrategyProfile(
      languageId: 'typescript',
      summary: 'Основной язык современного web-продукта.',
      strengths: <String>['Большой рынок специалистов', 'Удобен для команд'],
      weaknesses: <String>['Не лучший выбор для тяжёлого backend'],
      bestForBlueprintIds: <String>[
        'company_website',
        'team_saas',
        'ai_assistant',
      ],
      complexityMultiplier: 1,
    ),
    LanguageStrategyProfile(
      languageId: 'python',
      summary: 'Быстрая разработка AI и backend-прототипов.',
      strengths: <String>['AI/ML экосистема', 'Высокая скорость разработки'],
      weaknesses: <String>['Ниже runtime-производительность'],
      bestForBlueprintIds: <String>['ai_assistant'],
      complexityMultiplier: 0.96,
    ),
    LanguageStrategyProfile(
      languageId: 'php',
      summary: 'Дешёвый web и корпоративные сайты.',
      strengths: <String>['Низкая стоимость найма', 'Много готовых решений'],
      weaknesses: <String>['Сложнее поддерживать большой realtime-продукт'],
      bestForBlueprintIds: <String>['company_website'],
      complexityMultiplier: 0.90,
    ),
    LanguageStrategyProfile(
      languageId: 'go',
      summary: 'Производительный backend и инфраструктура.',
      strengths: <String>['Простая эксплуатация', 'Высокая скорость'],
      weaknesses: <String>['Меньше специалистов, чем в JS/Python'],
      bestForBlueprintIds: <String>[
        'team_saas',
        'cloud_platform',
        'developer_platform',
        'city_system',
      ],
      complexityMultiplier: 1.08,
    ),
    LanguageStrategyProfile(
      languageId: 'rust',
      summary: 'Безопасный системный код.',
      strengths: <String>['Скорость', 'Безопасность памяти'],
      weaknesses: <String>['Редкие и дорогие специалисты'],
      bestForBlueprintIds: <String>[
        'privacy_browser',
        'crypto_wallet',
        'cloud_platform',
      ],
      complexityMultiplier: 1.28,
    ),
    LanguageStrategyProfile(
      languageId: 'cpp',
      summary: 'Максимальный контроль desktop и системного кода.',
      strengths: <String>['Высокая производительность'],
      weaknesses: <String>['Дорогая разработка', 'Риск ошибок памяти'],
      bestForBlueprintIds: <String>['privacy_browser'],
      complexityMultiplier: 1.34,
    ),
    LanguageStrategyProfile(
      languageId: 'java',
      summary: 'Корпоративные и высоконагруженные системы.',
      strengths: <String>['Большие команды', 'Зрелая экосистема'],
      weaknesses: <String>['Высокая инфраструктурная сложность'],
      bestForBlueprintIds: <String>['cloud_platform', 'city_system'],
      complexityMultiplier: 1.12,
    ),
    LanguageStrategyProfile(
      languageId: 'dart',
      summary: 'Кроссплатформенный mobile и desktop.',
      strengths: <String>['Одна команда на платформы'],
      weaknesses: <String>['Меньше специалистов'],
      bestForBlueprintIds: <String>['team_saas'],
      complexityMultiplier: 1.02,
    ),
    LanguageStrategyProfile(
      languageId: 'swift',
      summary: 'Нативный iOS-клиент.',
      strengths: <String>['Лучшее качество iOS'],
      weaknesses: <String>['Отдельная команда под платформу'],
      bestForBlueprintIds: <String>['crypto_wallet', 'team_saas'],
      complexityMultiplier: 1.12,
    ),
    LanguageStrategyProfile(
      languageId: 'kotlin',
      summary: 'Нативный Android и JVM backend.',
      strengths: <String>['Качественный Android', 'JVM-экосистема'],
      weaknesses: <String>['Отдельная mobile-команда'],
      bestForBlueprintIds: <String>['crypto_wallet', 'city_system'],
      complexityMultiplier: 1.10,
    ),
  ];

  static const List<FrameworkStrategyProfile> frameworks =
      <FrameworkStrategyProfile>[
        FrameworkStrategyProfile(
          frameworkId: 'static_web',
          summary: 'HTML/CSS/JS без сложного backend.',
          strengths: <String>['Минимальные часы', 'Дешёвый хостинг'],
          weaknesses: <String>['Только простой сайт и реклама'],
          requiredLanguageIds: <String>['html_css'],
          complexityMultiplier: 0.70,
        ),
        FrameworkStrategyProfile(
          frameworkId: 'laravel_web',
          summary: 'Быстрый корпоративный web на PHP.',
          strengths: <String>['Готовая админка', 'Дешёвый найм'],
          weaknesses: <String>['Не для тяжёлого realtime'],
          requiredLanguageIds: <String>['php'],
          complexityMultiplier: 0.88,
        ),
        FrameworkStrategyProfile(
          frameworkId: 'flutter_firebase',
          summary: 'Быстрый mobile-first MVP.',
          strengths: <String>['Один клиент для платформ', 'Быстрый запуск'],
          weaknesses: <String>['Vendor lock-in', 'Слабее контроль backend'],
          requiredLanguageIds: <String>['dart'],
          complexityMultiplier: 0.92,
        ),
        FrameworkStrategyProfile(
          frameworkId: 'next_nest',
          summary: 'Сбалансированный TypeScript web-stack.',
          strengths: <String>['Большой рынок кадров', 'Хороший B2B web'],
          weaknesses: <String>['Node требует контроля производительности'],
          requiredLanguageIds: <String>['typescript'],
          complexityMultiplier: 1,
        ),
        FrameworkStrategyProfile(
          frameworkId: 'fastapi_react',
          summary: 'AI/backend на Python и web-клиент.',
          strengths: <String>['Быстрый AI-релиз'],
          weaknesses: <String>['Две технологические специализации'],
          requiredLanguageIds: <String>['python', 'typescript'],
          complexityMultiplier: 1.06,
        ),
        FrameworkStrategyProfile(
          frameworkId: 'go_microservices',
          summary: 'Набор Go-сервисов для нагрузки.',
          strengths: <String>['Производительность', 'Надёжный backend'],
          weaknesses: <String>['DevOps и распределённая сложность'],
          requiredLanguageIds: <String>['go'],
          complexityMultiplier: 1.18,
        ),
        FrameworkStrategyProfile(
          frameworkId: 'java_enterprise',
          summary: 'Корпоративная JVM-платформа.',
          strengths: <String>['Масштаб больших команд', 'Зрелые инструменты'],
          weaknesses: <String>['Высокий burn и медленный старт'],
          requiredLanguageIds: <String>['java'],
          complexityMultiplier: 1.24,
        ),
        FrameworkStrategyProfile(
          frameworkId: 'rust_core',
          summary: 'Rust core с нативными клиентами.',
          strengths: <String>['Безопасность', 'Скорость'],
          weaknesses: <String>['Редкие кадры', 'Долгая разработка'],
          requiredLanguageIds: <String>['rust'],
          complexityMultiplier: 1.38,
        ),
        FrameworkStrategyProfile(
          frameworkId: 'chromium_fork',
          summary: 'Собственный браузер на базе Chromium.',
          strengths: <String>['Готовый движок'],
          weaknesses: <String>['Огромный технический долг', 'Security updates'],
          requiredLanguageIds: <String>['cpp', 'typescript'],
          complexityMultiplier: 1.30,
        ),
      ];

  static const List<DevelopmentPhaseDefinition> phases =
      <DevelopmentPhaseDefinition>[
        DevelopmentPhaseDefinition(
          phase: DevelopmentPhase.discovery,
          name: 'Исследование и требования',
          start: 0,
          end: 0.10,
          description: 'Команда уточняет пользователей, scope и риски.',
          criticalRoles: <EmployeeRole>[
            EmployeeRole.productManager,
            EmployeeRole.designer,
          ],
        ),
        DevelopmentPhaseDefinition(
          phase: DevelopmentPhase.architecture,
          name: 'Архитектура и прототип',
          start: 0.10,
          end: 0.25,
          description:
              'Выбираются границы систем, данные и технический прототип.',
          criticalRoles: <EmployeeRole>[
            EmployeeRole.backend,
            EmployeeRole.devOps,
            EmployeeRole.security,
          ],
        ),
        DevelopmentPhaseDefinition(
          phase: DevelopmentPhase.core,
          name: 'Основной функционал',
          start: 0.25,
          end: 0.58,
          description: 'Разрабатывается ядро продукта.',
          criticalRoles: <EmployeeRole>[
            EmployeeRole.frontend,
            EmployeeRole.backend,
            EmployeeRole.mobile,
            EmployeeRole.aiMl,
          ],
        ),
        DevelopmentPhaseDefinition(
          phase: DevelopmentPhase.features,
          name: 'Функции и интеграции',
          start: 0.58,
          end: 0.80,
          description: 'Команда реализует выбранный roadmap и интеграции.',
          criticalRoles: <EmployeeRole>[
            EmployeeRole.frontend,
            EmployeeRole.backend,
            EmployeeRole.mobile,
          ],
        ),
        DevelopmentPhaseDefinition(
          phase: DevelopmentPhase.stabilization,
          name: 'Тестирование и стабилизация',
          start: 0.80,
          end: 0.94,
          description: 'Исправляются дефекты, нагрузка и безопасность.',
          criticalRoles: <EmployeeRole>[
            EmployeeRole.qa,
            EmployeeRole.devOps,
            EmployeeRole.security,
          ],
        ),
        DevelopmentPhaseDefinition(
          phase: DevelopmentPhase.release,
          name: 'Подготовка релиза',
          start: 0.94,
          end: 1,
          description: 'Релизный кандидат, документация и запуск.',
          criticalRoles: <EmployeeRole>[
            EmployeeRole.productManager,
            EmployeeRole.qa,
            EmployeeRole.devOps,
          ],
        ),
      ];

  static const List<AdvertisingAgency> agencies = <AdvertisingAgency>[
    AdvertisingAgency(
      id: 'freelance_ads',
      name: 'Freelance Performance',
      description: 'Дёшево, но прогноз часто промахивается.',
      quality: 0.58,
      minimumBudget: 25000,
      feePercent: 0.08,
      forecastAccuracy: 0.58,
    ),
    AdvertisingAgency(
      id: 'north_media',
      name: 'North Media',
      description: 'Сбалансированная performance-команда.',
      quality: 0.82,
      minimumBudget: 80000,
      feePercent: 0.14,
      forecastAccuracy: 0.80,
    ),
    AdvertisingAgency(
      id: 'signal_labs',
      name: 'Signal Labs',
      description: 'Дорогая аналитика, бренд и точный таргетинг.',
      quality: 1.05,
      minimumBudget: 250000,
      feePercent: 0.22,
      forecastAccuracy: 0.92,
    ),
  ];

  static const List<AdvertisingChannel> channels = <AdvertisingChannel>[
    AdvertisingChannel(
      id: 'search_ads',
      name: 'Поисковая реклама',
      description:
          'Пользователи уже ищут решение. Дороже клик, выше намерение.',
      billingModel: AdvertisingBillingModel.cpc,
      baseCpm: 0,
      baseCpc: 150,
      trustWeight: 0.75,
      brandWeight: 0.45,
      bestForCategories: <ProductCategory>[
        ProductCategory.saas,
        ProductCategory.developerTool,
        ProductCategory.cloud,
      ],
    ),
    AdvertisingChannel(
      id: 'social_feed',
      name: 'Социальные сети',
      description: 'Большой охват, но много холодной аудитории.',
      billingModel: AdvertisingBillingModel.cpm,
      baseCpm: 520,
      baseCpc: 0,
      trustWeight: 0.48,
      brandWeight: 0.82,
      bestForCategories: <ProductCategory>[
        ProductCategory.aiAssistant,
        ProductCategory.saas,
        ProductCategory.browser,
      ],
    ),
    AdvertisingChannel(
      id: 'creator_reviews',
      name: 'Обзоры у авторов',
      description: 'Меньше охват, выше доверие и органический эффект.',
      billingModel: AdvertisingBillingModel.hybrid,
      baseCpm: 980,
      baseCpc: 220,
      trustWeight: 1.12,
      brandWeight: 0.90,
      bestForCategories: <ProductCategory>[
        ProductCategory.aiAssistant,
        ProductCategory.browser,
        ProductCategory.cryptoWallet,
      ],
    ),
    AdvertisingChannel(
      id: 'b2b_outreach',
      name: 'B2B outreach',
      description: 'Мало лидов, но высокая ценность корпоративного клиента.',
      billingModel: AdvertisingBillingModel.cpc,
      baseCpm: 0,
      baseCpc: 720,
      trustWeight: 0.95,
      brandWeight: 0.30,
      bestForCategories: <ProductCategory>[
        ProductCategory.cloud,
        ProductCategory.saas,
        ProductCategory.developerTool,
      ],
    ),
  ];

  static ProductStrategyProfile strategyFor(String blueprintId) =>
      products.firstWhere((item) => item.blueprintId == blueprintId);

  static LanguageStrategyProfile languageProfile(String id) =>
      languages.firstWhere((item) => item.languageId == id);

  static FrameworkStrategyProfile frameworkProfile(String id) =>
      frameworks.firstWhere((item) => item.frameworkId == id);

  static DevelopmentPhaseDefinition phaseFor(double progress) =>
      phases.firstWhere(
        (item) => progress >= item.start && progress < item.end,
        orElse: () => phases.last,
      );

  static AdvertisingAgency agencyById(String id) =>
      agencies.firstWhere((item) => item.id == id);

  static AdvertisingChannel channelById(String id) =>
      channels.firstWhere((item) => item.id == id);
}
