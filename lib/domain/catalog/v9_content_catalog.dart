import '../entities/v9_models.dart';

abstract final class V9ContentCatalog {
  static const List<HostingPlan> hostingPlans = <HostingPlan>[
    HostingPlan(
      id: 'shared_launch',
      provider: 'NorthHost',
      name: 'Shared Launch',
      kind: HostingKind.shared,
      description: 'Самый дешёвый старт для сайта компании и первых тестов.',
      computeUnits: 45,
      storageGb: 30,
      bandwidthTb: 1,
      sla: 0.985,
      approximateUsers: 12000,
      monthlyCost: 3900,
      setupCost: 1500,
      reliability: 0.985,
      scalability: 0.25,
      strengths: <String>['Дешёвый старт', 'Не нужен DevOps'],
      weaknesses: <String>['Соседи делят ресурсы', 'Нет тонкой настройки'],
      risks: <String>['Просадки под пиковым трафиком'],
      requiredRoles: <String>[],
    ),
    HostingPlan(
      id: 'vps_core',
      provider: 'NorthHost',
      name: 'VPS Core 4',
      kind: HostingKind.vps,
      description: 'Предсказуемый VPS для раннего SaaS и API.',
      computeUnits: 120,
      storageGb: 160,
      bandwidthTb: 4,
      sla: 0.995,
      approximateUsers: 55000,
      monthlyCost: 14900,
      setupCost: 6000,
      reliability: 0.994,
      scalability: 0.52,
      strengths: <String>['Выделенные ресурсы', 'Root-доступ'],
      weaknesses: <String>['Нужны обновления и резервные копии'],
      risks: <String>['Один узел — единая точка отказа'],
      requiredRoles: <String>['devOps'],
    ),
    HostingPlan(
      id: 'managed_scale',
      provider: 'BlueRack',
      name: 'Managed Scale',
      kind: HostingKind.managed,
      description: 'Управляемый hosting с мониторингом и резервированием.',
      computeUnits: 260,
      storageGb: 500,
      bandwidthTb: 9,
      sla: 0.998,
      approximateUsers: 180000,
      monthlyCost: 52000,
      setupCost: 18000,
      reliability: 0.998,
      scalability: 0.72,
      strengths: <String>['Поддержка 24/7', 'Резервные копии'],
      weaknesses: <String>['Дороже VPS', 'Ограниченная кастомизация'],
      risks: <String>['Зависимость от поддержки провайдера'],
      requiredRoles: <String>[],
    ),
    HostingPlan(
      id: 'cloud_flex',
      provider: 'Astra Cloud',
      name: 'Cloud Flex',
      kind: HostingKind.cloudCompute,
      description: 'Эластичные виртуальные машины и балансировщик нагрузки.',
      computeUnits: 520,
      storageGb: 1200,
      bandwidthTb: 18,
      sla: 0.999,
      approximateUsers: 520000,
      monthlyCost: 126000,
      setupCost: 32000,
      reliability: 0.999,
      scalability: 0.90,
      strengths: <String>['Быстрое масштабирование', 'Несколько зон'],
      weaknesses: <String>['Сложный счёт', 'Нужен FinOps-контроль'],
      risks: <String>['Неожиданный рост расходов'],
      requiredRoles: <String>['devOps'],
    ),
    HostingPlan(
      id: 'cloud_pro',
      provider: 'Astra Cloud',
      name: 'Cloud Pro',
      kind: HostingKind.cloudCompute,
      description: 'Высоконагруженный кластер для нескольких зрелых продуктов.',
      computeUnits: 1100,
      storageGb: 4000,
      bandwidthTb: 50,
      sla: 0.9995,
      approximateUsers: 1800000,
      monthlyCost: 315000,
      setupCost: 75000,
      reliability: 0.9995,
      scalability: 0.97,
      strengths: <String>['Автомасштабирование', 'Multi-zone'],
      weaknesses: <String>['Высокий burn', 'Сложная архитектура'],
      risks: <String>['Vendor lock-in'],
      requiredRoles: <String>['devOps', 'security'],
    ),
    HostingPlan(
      id: 'serverless_burst',
      provider: 'LambdaWorks',
      name: 'Serverless Burst',
      kind: HostingKind.serverless,
      description: 'Оплата за вызовы, хорошо выдерживает нерегулярные пики.',
      computeUnits: 360,
      storageGb: 200,
      bandwidthTb: 12,
      sla: 0.997,
      approximateUsers: 300000,
      monthlyCost: 68000,
      setupCost: 25000,
      reliability: 0.997,
      scalability: 0.95,
      strengths: <String>[
        'Нет простаивающих серверов',
        'Пики без ручного scale',
      ],
      weaknesses: <String>['Cold start', 'Ограничения runtime'],
      risks: <String>['Цена резко растёт при постоянной нагрузке'],
      requiredRoles: <String>['backend'],
    ),
    HostingPlan(
      id: 'managed_db',
      provider: 'DataHarbor',
      name: 'Managed PostgreSQL',
      kind: HostingKind.managedDatabase,
      description: 'Управляемая база данных с резервными копиями и failover.',
      computeUnits: 180,
      storageGb: 1000,
      bandwidthTb: 6,
      sla: 0.999,
      approximateUsers: 220000,
      monthlyCost: 76000,
      setupCost: 12000,
      reliability: 0.999,
      scalability: 0.82,
      strengths: <String>['Автоматические backup', 'Failover без ручного DBA'],
      weaknesses: <String>['Это не полный application hosting'],
      risks: <String>['Нужен отдельный compute plan'],
      requiredRoles: <String>['backend'],
    ),
    HostingPlan(
      id: 'object_storage',
      provider: 'DataHarbor',
      name: 'Object Storage Plus',
      kind: HostingKind.objectStorage,
      description: 'Файлы, логи и резервные копии с оплатой за объём.',
      computeUnits: 80,
      storageGb: 12000,
      bandwidthTb: 20,
      sla: 0.997,
      approximateUsers: 450000,
      monthlyCost: 44000,
      setupCost: 5000,
      reliability: 0.997,
      scalability: 0.96,
      strengths: <String>['Очень много storage', 'Дешёвое расширение'],
      weaknesses: <String>['Мало application compute'],
      risks: <String>['Egress может стать дорогим'],
      requiredRoles: <String>[],
    ),
    HostingPlan(
      id: 'cdn_edge',
      provider: 'EdgeNova',
      name: 'CDN Edge Network',
      kind: HostingKind.cdn,
      description: 'Глобальная доставка статики и защита от всплесков трафика.',
      computeUnits: 140,
      storageGb: 240,
      bandwidthTb: 60,
      sla: 0.999,
      approximateUsers: 900000,
      monthlyCost: 98000,
      setupCost: 18000,
      reliability: 0.999,
      scalability: 0.98,
      strengths: <String>['Низкая latency', 'Большой bandwidth'],
      weaknesses: <String>['Backend всё равно нужен отдельно'],
      risks: <String>['Ошибки cache invalidation'],
      requiredRoles: <String>['devOps'],
    ),
    HostingPlan(
      id: 'owned',
      provider: 'Собственная инфраструктура',
      name: 'Собственные серверы',
      kind: HostingKind.owned,
      description:
          'Мощность определяется серверной, стойками и установленным оборудованием.',
      computeUnits: 0,
      storageGb: 0,
      bandwidthTb: 0,
      sla: 0,
      approximateUsers: 0,
      monthlyCost: 0,
      setupCost: 240000,
      reliability: 0,
      scalability: 0.80,
      strengths: <String>['Полный контроль', 'Нет provider lock-in'],
      weaknesses: <String>['CAPEX', 'Питание, охлаждение и обслуживание'],
      risks: <String>['Downtime при ошибке миграции'],
      requiredRoles: <String>['devOps', 'security'],
    ),
  ];

  static HostingPlan hostingById(String id) =>
      hostingPlans.firstWhere((item) => item.id == id);

  static const List<GlossaryEntry> glossary = <GlossaryEntry>[
    GlossaryEntry(
      id: 'mrr',
      term: 'MRR',
      shortExplanation: 'Повторяющаяся месячная выручка.',
      detailedExplanation:
          'Сумма ожидаемых регулярных платежей клиентов за один месяц. Разовые сделки сюда не входят.',
      gameExample:
          '1 000 подписчиков по 500 ₽ дают около 500 000 ₽ MRR до скидок и churn.',
      usedIn: <String>['Обзор', 'Финансы', 'Продукт'],
      whyImportant: 'Показывает устойчивость выручки.',
    ),
    GlossaryEntry(
      id: 'arr',
      term: 'ARR',
      shortExplanation: 'Повторяющаяся годовая выручка.',
      detailedExplanation:
          'MRR, умноженный примерно на 12. Это ориентир масштаба подписочного бизнеса, а не деньги на счёте.',
      gameExample: 'MRR 500 000 ₽ соответствует ARR около 6 млн ₽.',
      usedIn: <String>['Финансы', 'Инвесторы'],
      whyImportant: 'Инвесторы сравнивают компании по годовому масштабу.',
    ),
    GlossaryEntry(
      id: 'revenue',
      term: 'Revenue',
      shortExplanation: 'Вся выручка компании.',
      detailedExplanation:
          'Деньги от продуктов, контрактов и других источников до вычета расходов.',
      gameExample:
          'Подписки и финальная выплата по контракту увеличивают revenue.',
      usedIn: <String>['Финансы'],
      whyImportant: 'Без выручки компания не может долго финансировать рост.',
    ),
    GlossaryEntry(
      id: 'profit',
      term: 'Profit',
      shortExplanation: 'Выручка минус расходы.',
      detailedExplanation:
          'Положительный profit означает, что компания зарабатывает больше, чем тратит.',
      gameExample:
          'Revenue 900 000 ₽ и расходы 700 000 ₽ дают profit 200 000 ₽.',
      usedIn: <String>['Обзор', 'Финансы'],
      whyImportant: 'Определяет самоокупаемость.',
    ),
    GlossaryEntry(
      id: 'burn_rate',
      term: 'Burn rate',
      shortExplanation: 'Скорость сжигания денег.',
      detailedExplanation:
          'Сколько денег компания теряет за месяц при отрицательном profit.',
      gameExample: 'Profit −300 000 ₽ означает burn rate 300 000 ₽/мес.',
      usedIn: <String>['Финансы', 'Инвесторы'],
      whyImportant: 'От burn зависит срок жизни компании.',
    ),
    GlossaryEntry(
      id: 'runway',
      term: 'Runway',
      shortExplanation: 'Сколько месяцев осталось до нуля.',
      detailedExplanation:
          'Cash, разделённый на текущий burn rate. Это прогноз при неизменной экономике.',
      gameExample: '1,2 млн ₽ при burn 300 000 ₽ дают runway 4 месяца.',
      usedIn: <String>['Обзор', 'Финансы'],
      whyImportant:
          'Помогает понять срочность сокращений или привлечения денег.',
    ),
    GlossaryEntry(
      id: 'payroll',
      term: 'Payroll',
      shortExplanation: 'Начисленная зарплата команды.',
      detailedExplanation:
          'Зарплата начисляется пропорционально прошедшему игровому времени. Signing bonus и onboarding cost — отдельные расходы.',
      gameExample:
          'Сотрудник с зарплатой 120 000 ₽ за половину месяца создаёт около 60 000 ₽ payroll.',
      usedIn: <String>['Команда', 'Финансы'],
      whyImportant: 'Обычно это крупнейшая часть burn.',
    ),
    GlossaryEntry(
      id: 'cac',
      term: 'CAC',
      shortExplanation: 'Стоимость привлечения клиента.',
      detailedExplanation:
          'Расходы на маркетинг и продажи, поделённые на число новых платящих клиентов.',
      gameExample: '100 000 ₽ рекламы и 200 клиентов дают CAC 500 ₽.',
      usedIn: <String>['Маркетинг', 'Реклама'],
      whyImportant: 'CAC должен окупаться ценностью клиента.',
    ),
    GlossaryEntry(
      id: 'ltv',
      term: 'LTV',
      shortExplanation: 'Доход от клиента за всё время.',
      detailedExplanation: 'Ожидаемая маржа от клиента до его ухода.',
      gameExample: 'Клиент платит 500 ₽ 12 месяцев — грубый LTV 6 000 ₽.',
      usedIn: <String>['Монетизация', 'Маркетинг'],
      whyImportant: 'LTV выше CAC делает рост экономически разумным.',
    ),
    GlossaryEntry(
      id: 'churn',
      term: 'Churn',
      shortExplanation: 'Доля ушедших пользователей.',
      detailedExplanation:
          'Процент клиентов, переставших пользоваться или платить за период.',
      gameExample: 'Из 1 000 клиентов ушло 80 — churn 8%.',
      usedIn: <String>['Продукт', 'Монетизация'],
      whyImportant: 'Высокий churn уничтожает MRR.',
    ),
    GlossaryEntry(
      id: 'retention',
      term: 'Retention',
      shortExplanation: 'Доля вернувшихся пользователей.',
      detailedExplanation:
          'Показывает, сколько пользователей остаются активными после определённого времени.',
      gameExample:
          'Retention 30d 40% означает, что через месяц остаются 4 из 10.',
      usedIn: <String>['Продукт'],
      whyImportant: 'Без retention реклама только временно надувает аудиторию.',
    ),
    GlossaryEntry(
      id: 'activation',
      term: 'Activation',
      shortExplanation: 'Доля пользователей, получивших первую ценность.',
      detailedExplanation:
          'Процент новых пользователей, совершивших ключевое действие.',
      gameExample: 'Создание первого проекта может быть activation для SaaS.',
      usedIn: <String>['Продукт'],
      whyImportant: 'Плохая activation ломает воронку сразу после регистрации.',
    ),
    GlossaryEntry(
      id: 'dau',
      term: 'DAU',
      shortExplanation: 'Активные пользователи за день.',
      detailedExplanation:
          'Уникальные пользователи, использовавшие продукт в течение суток.',
      gameExample: 'DAU 12 000 означает 12 000 активных за игровой день.',
      usedIn: <String>['Продукт'],
      whyImportant: 'Показывает ежедневную вовлечённость.',
    ),
    GlossaryEntry(
      id: 'mau',
      term: 'MAU',
      shortExplanation: 'Активные пользователи за месяц.',
      detailedExplanation: 'Уникальные пользователи за последние 30 дней.',
      gameExample: 'DAU 10 000 и MAU 50 000 дают DAU/MAU 20%.',
      usedIn: <String>['Продукт'],
      whyImportant: 'Основа расчёта масштаба аудитории и части монетизации.',
    ),
    GlossaryEntry(
      id: 'arpu',
      term: 'ARPU',
      shortExplanation: 'Средняя выручка на пользователя.',
      detailedExplanation:
          'Revenue продукта, поделённый на число активных пользователей.',
      gameExample: 'MRR 500 000 ₽ при 10 000 MAU даёт ARPU 50 ₽.',
      usedIn: <String>['Монетизация', 'Финансы'],
      whyImportant: 'Показывает качество монетизации.',
    ),
    GlossaryEntry(
      id: 'cpm',
      term: 'CPM',
      shortExplanation: 'Цена тысячи показов.',
      detailedExplanation: 'Модель рекламы, где оплачивается охват, а не клик.',
      gameExample: 'CPM 500 ₽ и бюджет 50 000 ₽ дают примерно 100 000 показов.',
      usedIn: <String>['Реклама'],
      whyImportant: 'Нужен для оценки brand awareness.',
    ),
    GlossaryEntry(
      id: 'cpc',
      term: 'CPC',
      shortExplanation: 'Цена одного клика.',
      detailedExplanation:
          'Модель рекламы, где списание привязано к переходу пользователя.',
      gameExample: 'CPC 100 ₽ и 50 000 ₽ бюджета дают около 500 кликов.',
      usedIn: <String>['Реклама'],
      whyImportant: 'Связывает бюджет с трафиком.',
    ),
    GlossaryEntry(
      id: 'ctr',
      term: 'CTR',
      shortExplanation: 'Доля показов, ставших кликами.',
      detailedExplanation: 'Клики, поделённые на показы.',
      gameExample: '1 000 кликов из 100 000 показов — CTR 1%.',
      usedIn: <String>['Реклама'],
      whyImportant: 'Показывает привлекательность объявления.',
    ),
    GlossaryEntry(
      id: 'conversion',
      term: 'Conversion',
      shortExplanation: 'Доля пользователей, совершивших цель.',
      detailedExplanation:
          'Например, доля кликов, завершившихся регистрацией или оплатой.',
      gameExample: '50 регистраций из 500 кликов — conversion 10%.',
      usedIn: <String>['Маркетинг', 'Реклама'],
      whyImportant: 'Определяет результат одного и того же трафика.',
    ),
    GlossaryEntry(
      id: 'brand_awareness',
      term: 'Brand awareness',
      shortExplanation: 'Насколько рынок знает бренд.',
      detailedExplanation:
          'Узнаваемость повышает органический спрос и эффективность массовой рекламы.',
      gameExample: 'Обзоры и широкий охват повышают awareness.',
      usedIn: <String>['Маркетинг', 'Продукт'],
      whyImportant: 'Неизвестный продукт хуже конвертирует большой бюджет.',
    ),
    GlossaryEntry(
      id: 'trust',
      term: 'Trust',
      shortExplanation: 'Доверие пользователей к бренду.',
      detailedExplanation:
          'Зависит от качества, безопасности, uptime, отзывов и истории компании.',
      gameExample: 'Security breach снижает trust и повышает churn.',
      usedIn: <String>['Продукт', 'Безопасность'],
      whyImportant: 'Доверие защищает выручку и цену.',
    ),
    GlossaryEntry(
      id: 'uptime',
      term: 'Uptime',
      shortExplanation: 'Доля времени без сбоев.',
      detailedExplanation:
          '99,9% uptime означает небольшое, но не нулевое время недоступности.',
      gameExample: 'Перегрузка hosting plan снижает uptime.',
      usedIn: <String>['Инфраструктура', 'Продукт'],
      whyImportant: 'Сбои ухудшают retention и trust.',
    ),
    GlossaryEntry(
      id: 'latency',
      term: 'Latency',
      shortExplanation: 'Задержка ответа системы.',
      detailedExplanation:
          'Время между действием пользователя и ответом продукта.',
      gameExample: 'CDN и cache уменьшают latency, перегрузка увеличивает.',
      usedIn: <String>['Инфраструктура', 'Продукт'],
      whyImportant: 'Медленный продукт проигрывает конкурентам.',
    ),
    GlossaryEntry(
      id: 'compute',
      term: 'Compute',
      shortExplanation: 'Вычислительная мощность.',
      detailedExplanation: 'Условные единицы CPU/GPU, доступные продуктам.',
      gameExample: 'Нужно compute 120, а plan даёт 80 — запуск блокируется.',
      usedIn: <String>['Инфраструктура'],
      whyImportant: 'Недостаток compute вызывает перегрузку.',
    ),
    GlossaryEntry(
      id: 'storage',
      term: 'Storage',
      shortExplanation: 'Место для данных.',
      detailedExplanation:
          'Базы, файлы, логи и резервные копии занимают storage.',
      gameExample: 'Анализ файлов требует больше storage.',
      usedIn: <String>['Инфраструктура'],
      whyImportant: 'Переполненное хранилище останавливает операции.',
    ),
    GlossaryEntry(
      id: 'bandwidth',
      term: 'Bandwidth',
      shortExplanation: 'Объём передаваемых данных.',
      detailedExplanation:
          'Сколько трафика инфраструктура может обслужить за период.',
      gameExample: 'Видео и файлы быстрее расходуют bandwidth.',
      usedIn: <String>['Инфраструктура'],
      whyImportant: 'Лимит влияет на скорость и стоимость.',
    ),
    GlossaryEntry(
      id: 'sla',
      term: 'SLA',
      shortExplanation: 'Обещанный уровень сервиса.',
      detailedExplanation:
          'Обязательство провайдера по доступности и реакции на сбои.',
      gameExample: 'SLA 99,95% надёжнее 98,5%, но дороже.',
      usedIn: <String>['Инфраструктура', 'Контракты'],
      whyImportant: 'SLA ограничивает риск downtime.',
    ),
    GlossaryEntry(
      id: 'overstaffing',
      term: 'Overstaffing',
      shortExplanation: 'Людей больше эффективного максимума.',
      detailedExplanation:
          'Лишние сотрудники увеличивают коммуникации и payroll быстрее, чем скорость.',
      gameExample:
          '15 человек там, где максимум 10, получают штраф эффективности.',
      usedIn: <String>['Команда', 'Проект'],
      whyImportant: 'Больше людей не всегда быстрее.',
    ),
    GlossaryEntry(
      id: 'bottleneck',
      term: 'Bottleneck',
      shortExplanation: 'Главное узкое место.',
      detailedExplanation: 'Ресурс или роль, которая ограничивает весь проект.',
      gameExample:
          'Нет DevOps для Kubernetes — bottleneck на стадии архитектуры.',
      usedIn: <String>['Проект', 'Команда'],
      whyImportant: 'Устранение bottleneck даёт максимальный эффект.',
    ),
    GlossaryEntry(
      id: 'roadmap',
      term: 'Roadmap',
      shortExplanation: 'План развития продукта.',
      detailedExplanation:
          'Последовательность функций, обновлений и технических работ.',
      gameExample: 'Функции первого релиза образуют стартовый roadmap.',
      usedIn: <String>['Продукт'],
      whyImportant: 'Помогает контролировать scope.',
    ),
    GlossaryEntry(
      id: 'technical_debt',
      term: 'Technical debt',
      shortExplanation: 'Будущая цена быстрых решений.',
      detailedExplanation:
          'Компромиссы ускоряют релиз, но увеличивают поддержку и риск ошибок.',
      gameExample: 'Большой стек и Chromium fork повышают technical debt.',
      usedIn: <String>['Продукт', 'Технологии'],
      whyImportant: 'Долг замедляет будущие обновления.',
    ),
    GlossaryEntry(
      id: 'equity',
      term: 'Equity',
      shortExplanation: 'Доля владения компанией.',
      detailedExplanation:
          'Процент компании, принадлежащий основателю и инвесторам.',
      gameExample: 'Инвестор получает 10% equity за капитал.',
      usedIn: <String>['Инвесторы'],
      whyImportant: 'Ниже 50% основатель теряет контроль.',
    ),
    GlossaryEntry(
      id: 'valuation',
      term: 'Valuation',
      shortExplanation: 'Оценка стоимости компании.',
      detailedExplanation:
          'Расчётная цена бизнеса с учётом выручки, пользователей, технологий и прибыли.',
      gameExample: 'Рост MRR и качества увеличивает valuation.',
      usedIn: <String>['Инвесторы', 'M&A'],
      whyImportant: 'От оценки зависит цена доли.',
    ),
    GlossaryEntry(
      id: 'dilution',
      term: 'Dilution',
      shortExplanation: 'Уменьшение доли основателя.',
      detailedExplanation:
          'После новых инвестиций доля основателя становится меньше.',
      gameExample: 'Продажа ещё 15% снижает founder equity.',
      usedIn: <String>['Инвесторы'],
      whyImportant: 'Слишком сильное dilution приводит к потере контроля.',
    ),
  ];

  static GlossaryEntry glossaryById(String id) =>
      glossary.firstWhere((item) => item.id == id);

  static EcosystemIntegrationProfile integrationFor(
    String leftCategory,
    String rightCategory,
  ) {
    final categories = <String>[leftCategory, rightCategory]..sort();
    final key = categories.join('_');
    final ai = key.contains('aiAssistant');
    final cloud = key.contains('cloud');
    final securityRisk = key.contains('cryptoWallet') ? 0.18 : 0.08;
    return EcosystemIntegrationProfile(
      id: key,
      title: ai
          ? 'AI-автоматизация'
          : cloud
          ? 'Общая инфраструктура'
          : 'Единый аккаунт',
      description: ai
          ? 'Один продукт использует AI-возможности второго.'
          : cloud
          ? 'Продукты делят API, observability и инфраструктурные сервисы.'
          : 'Общий вход, профиль и переходы между продуктами.',
      cost: ai
          ? 140000
          : cloud
          ? 115000
          : 85000,
      integrationDays: ai
          ? 12
          : cloud
          ? 9
          : 6,
      growthBoost: ai ? 0.035 : 0.025,
      retentionBoost: cloud ? 0.018 : 0.012,
      computeMultiplier: ai
          ? 1.16
          : cloud
          ? 1.10
          : 1.04,
      risk: securityRisk,
      requirements: <String>[
        'Оба продукта существуют',
        'Нет дублирующей связи',
        'Есть свободный Backend или DevOps',
      ],
    );
  }
}
