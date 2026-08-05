import '../../../domain/entities/models.dart';

String money(double value) {
  final sign = value < 0 ? '−' : '';
  final absolute = value.abs();
  if (absolute >= 1000000000) {
    return '$sign${(absolute / 1000000000).toStringAsFixed(2)} млрд ₽';
  }
  if (absolute >= 1000000) {
    return '$sign${(absolute / 1000000).toStringAsFixed(2)} млн ₽';
  }
  if (absolute >= 1000) {
    return '$sign${(absolute / 1000).toStringAsFixed(1)} тыс. ₽';
  }
  return '$sign${absolute.round()} ₽';
}

String compactNumber(num value) {
  final absolute = value.abs();
  if (absolute >= 1000000) {
    return '${(value / 1000000).toStringAsFixed(1)} млн';
  }
  if (absolute >= 1000) {
    return '${(value / 1000).toStringAsFixed(1)} тыс.';
  }
  return value.round().toString();
}

String percent(double value, {int fractionDigits = 0}) =>
    '${(value * 100).toStringAsFixed(fractionDigits)}%';

String directPercent(double value, {int fractionDigits = 0}) =>
    '${value.toStringAsFixed(fractionDigits)}%';

String categoryName(ProductCategory category) => switch (category) {
  ProductCategory.aiAssistant => 'AI-ассистент',
  ProductCategory.cloud => 'Cloud',
  ProductCategory.saas => 'SaaS',
  ProductCategory.browser => 'Браузер',
  ProductCategory.cryptoWallet => 'Криптокошелёк',
  ProductCategory.developerTool => 'Developer tools',
};

String roleName(EmployeeRole role) => switch (role) {
  EmployeeRole.productManager => 'Product Manager',
  EmployeeRole.frontend => 'Frontend',
  EmployeeRole.backend => 'Backend',
  EmployeeRole.mobile => 'Mobile',
  EmployeeRole.aiMl => 'AI / ML',
  EmployeeRole.designer => 'Product Designer',
  EmployeeRole.qa => 'QA',
  EmployeeRole.devOps => 'DevOps / SRE',
  EmployeeRole.security => 'Security',
  EmployeeRole.growth => 'Growth',
  EmployeeRole.sales => 'Sales',
  EmployeeRole.support => 'Support',
};

String rolePurpose(EmployeeRole role) => switch (role) {
  EmployeeRole.productManager =>
    'Определяет приоритеты, удерживает scope и ускоряет согласование продуктовых решений.',
  EmployeeRole.frontend =>
    'Отвечает за клиентский интерфейс, скорость UI и качество веб-взаимодействий.',
  EmployeeRole.backend =>
    'Строит серверную логику, API, данные и масштабирование продукта.',
  EmployeeRole.mobile =>
    'Разрабатывает мобильный клиент, интеграции устройства и качество релизов.',
  EmployeeRole.aiMl =>
    'Обучает и внедряет модели, улучшает алгоритмы и качество AI-функций.',
  EmployeeRole.designer =>
    'Повышает удобство, визуальное качество, activation и восприятие продукта.',
  EmployeeRole.qa =>
    'Снижает количество дефектов, защищает релизы и повышает reliability.',
  EmployeeRole.devOps =>
    'Автоматизирует delivery, инфраструктуру, observability и устойчивость.',
  EmployeeRole.security =>
    'Снижает вероятность атак, утечек и репутационных потерь.',
  EmployeeRole.growth =>
    'Работает с воронками, acquisition, retention и экспериментами роста.',
  EmployeeRole.sales =>
    'Привлекает B2B-клиентов, помогает контрактам и коммерческим сделкам.',
  EmployeeRole.support =>
    'Снижает отток, обрабатывает проблемы пользователей и поддерживает рейтинг.',
};

String stageName(ProductStage stage) => switch (stage) {
  ProductStage.development => 'Разработка',
  ProductStage.beta => 'Beta',
  ProductStage.live => 'На рынке',
  ProductStage.failed => 'Провал',
};

String monetizationName(MonetizationModel model) => switch (model) {
  MonetizationModel.free => 'Бесплатно',
  MonetizationModel.subscription => 'Подписка',
  MonetizationModel.usageBased => 'Usage-based',
  MonetizationModel.advertising => 'Реклама',
  MonetizationModel.transactionFee => 'Комиссия',
};
