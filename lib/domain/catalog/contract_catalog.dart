import '../entities/business_models.dart';
import '../entities/models.dart';

abstract final class ContractCatalog {
  static const List<ContractTemplate> templates = <ContractTemplate>[
    ContractTemplate(
      id: 'landing_launch',
      name: 'Промо-сайт запуска',
      client: 'Bright Foods',
      description:
          'Собрать адаптивный лендинг, форму заявок и простую аналитику.',
      reward: 180000,
      developmentHours: 72,
      deadlineDays: 8,
      upfrontPercent: 0.20,
      requiredRoles: <EmployeeRole>[
        EmployeeRole.frontend,
        EmployeeRole.designer,
      ],
    ),
    ContractTemplate(
      id: 'internal_dashboard',
      name: 'Внутренний dashboard',
      client: 'Vector Logistics',
      description: 'Панель показателей, роли доступа и выгрузка отчётов.',
      reward: 360000,
      developmentHours: 150,
      deadlineDays: 14,
      upfrontPercent: 0.20,
      requiredRoles: <EmployeeRole>[
        EmployeeRole.frontend,
        EmployeeRole.backend,
        EmployeeRole.qa,
      ],
    ),
    ContractTemplate(
      id: 'mobile_prototype',
      name: 'Мобильный прототип',
      client: 'Pulse Fitness',
      description:
          'Рабочий прототип приложения с аккаунтом и трекингом активности.',
      reward: 420000,
      developmentHours: 180,
      deadlineDays: 16,
      upfrontPercent: 0.18,
      requiredRoles: <EmployeeRole>[
        EmployeeRole.mobile,
        EmployeeRole.designer,
        EmployeeRole.qa,
      ],
    ),
    ContractTemplate(
      id: 'api_integration',
      name: 'Интеграция API',
      client: 'North Retail',
      description: 'Связать CRM, платёжный шлюз и склад с журналом ошибок.',
      reward: 510000,
      developmentHours: 210,
      deadlineDays: 18,
      upfrontPercent: 0.15,
      requiredRoles: <EmployeeRole>[
        EmployeeRole.backend,
        EmployeeRole.devOps,
        EmployeeRole.qa,
      ],
    ),
    ContractTemplate(
      id: 'ai_support_pilot',
      name: 'AI-пилот поддержки',
      client: 'Metro Services',
      description: 'Подготовить базу знаний и пилот помощника для операторов.',
      reward: 690000,
      developmentHours: 260,
      deadlineDays: 22,
      upfrontPercent: 0.15,
      requiredRoles: <EmployeeRole>[
        EmployeeRole.aiMl,
        EmployeeRole.backend,
        EmployeeRole.productManager,
      ],
    ),
  ];

  static ContractTemplate byId(String id) =>
      templates.firstWhere((item) => item.id == id);
}
