import '../entities/models.dart';

/// Optional product depth beyond the launch-critical feature set.
abstract final class ExtendedFeatureCatalog {
  static final List<FeatureOption> features = List<FeatureOption>.unmodifiable(
    <FeatureOption>[
      _f('multimodal_input', 'Мультимодальный ввод', _ai, 'Текст, изображения и документы в одном диалоге.', _FeatureSize.medium, _FeatureFocus.experience),
      _f('voice_mode', 'Голосовой режим', _ai, 'Низколатентный разговор с перебиваниями.', _FeatureSize.major, _FeatureFocus.performance),
      _f('image_generation', 'Генерация изображений', _ai, 'Создание и редактирование визуалов по запросу.', _FeatureSize.major, _FeatureFocus.platform),
      _f('code_interpreter', 'Среда вычислений', _ai, 'Безопасное выполнение кода и анализ данных.', _FeatureSize.major, _FeatureFocus.security),
      _f('memory_profiles', 'Память предпочтений', _ai, 'Персональные настройки и долгосрочный контекст.', _FeatureSize.medium, _FeatureFocus.retention),
      _f('agent_actions', 'Действия агента', _ai, 'Многошаговые задачи и подтверждаемые действия.', _FeatureSize.major, _FeatureFocus.platform),
      _f('connectors', 'Коннекторы данных', _ai, 'Подключение рабочих источников и сервисов.', _FeatureSize.medium, _FeatureFocus.retention),
      _f('deep_research', 'Глубокое исследование', _ai, 'Длинные исследовательские задачи с планом и проверкой.', _FeatureSize.major, _FeatureFocus.platform),
      _f('citations', 'Проверяемые источники', _ai, 'Ссылки на источники рядом с утверждениями.', _FeatureSize.small, _FeatureFocus.security),
      _f('custom_agents', 'Пользовательские агенты', _ai, 'Настраиваемые инструкции, знания и инструменты.', _FeatureSize.medium, _FeatureFocus.retention),
      _f('model_router', 'Маршрутизация моделей', _ai, 'Выбор модели под скорость, цену и сложность.', _FeatureSize.medium, _FeatureFocus.performance),
      _f('private_sessions', 'Приватные сессии', _ai, 'Режим без сохранения контента и истории.', _FeatureSize.small, _FeatureFocus.security),
      _f('source_graph', 'Карта источников', _ai, 'Связывает ответы, документы и первоисточники.', _FeatureSize.medium, _FeatureFocus.experience),

      _f('object_storage', 'Объектное хранилище', _cloud, 'Надёжное хранение больших объёмов файлов.', _FeatureSize.major, _FeatureFocus.platform),
      _f('file_sync', 'Синхронизация файлов', _cloud, 'Фоновая синхронизация между устройствами.', _FeatureSize.medium, _FeatureFocus.retention),
      _f('version_history', 'История версий', _cloud, 'Восстановление предыдущих версий и удалённых данных.', _FeatureSize.medium, _FeatureFocus.security),
      _f('share_links', 'Безопасные ссылки', _cloud, 'Публичные и ограниченные по сроку ссылки.', _FeatureSize.small, _FeatureFocus.experience),
      _f('zero_knowledge', 'Zero-knowledge vault', _cloud, 'Клиентское шифрование чувствительных файлов.', _FeatureSize.major, _FeatureFocus.security),
      _f('managed_backups', 'Управляемые бэкапы', _cloud, 'Политики резервирования и восстановление в точку времени.', _FeatureSize.medium, _FeatureFocus.security),
      _f('serverless_functions', 'Serverless functions', _cloud, 'Событийные функции без управления серверами.', _FeatureSize.major, _FeatureFocus.platform),
      _f('message_queues', 'Очереди сообщений', _cloud, 'Надёжная доставка событий между сервисами.', _FeatureSize.medium, _FeatureFocus.performance),
      _f('secrets_manager', 'Secrets manager', _cloudDev, 'Ротация ключей, токенов и сертификатов.', _FeatureSize.medium, _FeatureFocus.security),
      _f('audit_logs', 'Аудит действий', _cloudSaasDev, 'Неизменяемый журнал административных операций.', _FeatureSize.medium, _FeatureFocus.security),

      _f('docs_editor', 'Редактор документов', _saas, 'Структурированные документы и комментарии.', _FeatureSize.medium, _FeatureFocus.retention),
      _f('kanban_boards', 'Kanban-доски', _saas, 'Задачи, статусы и быстрые рабочие процессы.', _FeatureSize.small, _FeatureFocus.experience),
      _f('team_calendar', 'Командный календарь', _saas, 'События, дедлайны и планирование загрузки.', _FeatureSize.medium, _FeatureFocus.retention),
      _f('video_calls', 'Видеозвонки', _saas, 'Встречи внутри рабочих пространств.', _FeatureSize.major, _FeatureFocus.performance),
      _f('whiteboard', 'Интерактивная доска', _saas, 'Свободный холст для совместных сессий.', _FeatureSize.medium, _FeatureFocus.experience),
      _f('templates', 'Шаблоны', _saas, 'Быстрый старт из готовых рабочих сценариев.', _FeatureSize.small, _FeatureFocus.retention),
      _f('sso_saml', 'SSO и SAML', _saas, 'Корпоративный вход и централизованный доступ.', _FeatureSize.medium, _FeatureFocus.security),
      _f('guest_access', 'Гостевой доступ', _saas, 'Точный доступ внешних участников.', _FeatureSize.small, _FeatureFocus.security),
      _f('offline_mode', 'Офлайн-режим', _saas, 'Работа без сети с последующей синхронизацией.', _FeatureSize.major, _FeatureFocus.retention),
      _f('unified_search', 'Единый поиск', _saas, 'Поиск по проектам, людям и вложениям.', _FeatureSize.medium, _FeatureFocus.experience),
      _f('creative_canvas', 'Креативный холст', _saas, 'Визуальный редактор макетов и композиций.', _FeatureSize.major, _FeatureFocus.experience),
      _f('brand_kit', 'Бренд-кит', _saas, 'Шрифты, цвета и брендовые шаблоны команды.', _FeatureSize.small, _FeatureFocus.retention),
      _f('asset_library', 'Медиатека', _saas, 'Общие фото, видео и графические элементы.', _FeatureSize.medium, _FeatureFocus.platform),
      _f('realtime_voice', 'Голосовые комнаты', _saas, 'Постоянные голосовые пространства для сообществ.', _FeatureSize.major, _FeatureFocus.performance),
      _f('communities', 'Сообщества и роли', _saas, 'Каналы, роли, приглашения и уровни доступа.', _FeatureSize.medium, _FeatureFocus.retention),
      _f('moderation_tools', 'Модерация', _saas, 'Фильтры, репорты и инструменты доверия.', _FeatureSize.medium, _FeatureFocus.security),
      _f('smart_notifications', 'Умные уведомления', _saas, 'Приоритетные уведомления без лишнего шума.', _FeatureSize.small, _FeatureFocus.retention),
      _f('payments', 'Встроенные платежи', _saasWallet, 'Оплата внутри продукта и расчёты с продавцами.', _FeatureSize.major, _FeatureFocus.security),
      _f('recommendation_feed', 'Персональные рекомендации', _saas, 'Ранжирование контента и предложений.', _FeatureSize.major, _FeatureFocus.retention),

      _f('password_manager', 'Менеджер паролей', _browser, 'Пароли, автозаполнение и проверка утечек.', _FeatureSize.medium, _FeatureFocus.security),
      _f('built_in_vpn', 'Встроенный VPN', _browser, 'Защищённый сетевой туннель из браузера.', _FeatureSize.major, _FeatureFocus.security),
      _f('vertical_tabs', 'Вертикальные вкладки', _browser, 'Навигация по большим рабочим сессиям.', _FeatureSize.small, _FeatureFocus.experience),
      _f('reader_mode', 'Режим чтения', _browser, 'Чистое представление длинных материалов.', _FeatureSize.small, _FeatureFocus.experience),
      _f('page_translation', 'Перевод страниц', _browser, 'Автоматический перевод сайтов.', _FeatureSize.medium, _FeatureFocus.retention),
      _f('workspace_tabs', 'Пространства вкладок', _browser, 'Разделение работы, учёбы и личных сессий.', _FeatureSize.medium, _FeatureFocus.retention),
      _f('private_search', 'Приватный поиск', _browser, 'Поиск без персонального рекламного профиля.', _FeatureSize.major, _FeatureFocus.security),
      _f('passkeys', 'Passkeys', _browserWallet, 'Вход без паролей с аппаратной защитой ключей.', _FeatureSize.medium, _FeatureFocus.security),

      _f('fiat_onramp', 'Покупка за фиат', _wallet, 'Покупка активов банковской картой или переводом.', _FeatureSize.major, _FeatureFocus.platform),
      _f('swap_router', 'Smart swap', _wallet, 'Поиск лучшего маршрута обмена между площадками.', _FeatureSize.medium, _FeatureFocus.performance),
      _f('staking', 'Стейкинг', _wallet, 'Делегирование активов и отображение доходности.', _FeatureSize.medium, _FeatureFocus.retention),
      _f('transaction_simulation', 'Симуляция транзакций', _wallet, 'Показывает последствия подписи до отправки.', _FeatureSize.medium, _FeatureFocus.security),
      _f('address_book', 'Адресная книга', _wallet, 'Проверенные получатели и понятные имена.', _FeatureSize.small, _FeatureFocus.experience),
      _f('biometric_lock', 'Биометрическая защита', _wallet, 'Локальная разблокировка чувствительных действий.', _FeatureSize.small, _FeatureFocus.security),
      _f('portfolio_tracker', 'Портфель', _wallet, 'Активы, P&L и история в одном представлении.', _FeatureSize.medium, _FeatureFocus.retention),
      _f('hardware_signing', 'Аппаратная подпись', _wallet, 'Подписание критичных операций внешним ключом.', _FeatureSize.major, _FeatureFocus.security),

      _f('git_hosting', 'Git-репозитории', _dev, 'Хостинг исходного кода, веток и истории.', _FeatureSize.major, _FeatureFocus.platform),
      _f('pull_requests', 'Code review', _dev, 'Pull requests, ревью и правила merge.', _FeatureSize.medium, _FeatureFocus.retention),
      _f('issue_tracking', 'Issues и планирование', _dev, 'Баги, задачи, milestones и связи с кодом.', _FeatureSize.medium, _FeatureFocus.experience),
      _f('package_registry', 'Package registry', _dev, 'Приватные и публичные пакеты рядом с кодом.', _FeatureSize.medium, _FeatureFocus.platform),
      _f('code_search', 'Поиск по коду', _dev, 'Быстрый поиск символов и зависимостей по организации.', _FeatureSize.major, _FeatureFocus.performance),
      _f('cloud_dev_envs', 'Облачные dev-среды', _dev, 'Воспроизводимые среды разработки по кнопке.', _FeatureSize.major, _FeatureFocus.platform),
      _f('ai_code_review', 'AI code review', _dev, 'Автоматический разбор диффов и рискованных мест.', _FeatureSize.medium, _FeatureFocus.security),
      _f('secrets_scanning', 'Поиск секретов', _dev, 'Блокирует случайную публикацию токенов и ключей.', _FeatureSize.medium, _FeatureFocus.security),
      _f('dependency_graph', 'Граф зависимостей', _dev, 'Уязвимости и влияние обновлений библиотек.', _FeatureSize.medium, _FeatureFocus.security),
      _f('artifact_store', 'Хранилище артефактов', _dev, 'Сборки, контейнеры и release assets.', _FeatureSize.medium, _FeatureFocus.platform),
      _f('feature_flags', 'Feature flags', _devSaas, 'Постепенные релизы и безопасные эксперименты.', _FeatureSize.medium, _FeatureFocus.retention),
      _f('webhooks', 'Webhooks', _devSaas, 'Событийные интеграции с внешними системами.', _FeatureSize.small, _FeatureFocus.platform),
    ],
  );

  static const _ai = <ProductCategory>[ProductCategory.aiAssistant];
  static const _cloud = <ProductCategory>[ProductCategory.cloud];
  static const _saas = <ProductCategory>[ProductCategory.saas];
  static const _browser = <ProductCategory>[ProductCategory.browser];
  static const _wallet = <ProductCategory>[ProductCategory.cryptoWallet];
  static const _dev = <ProductCategory>[ProductCategory.developerTool];
  static const _cloudDev = <ProductCategory>[ProductCategory.cloud, ProductCategory.developerTool];
  static const _cloudSaasDev = <ProductCategory>[ProductCategory.cloud, ProductCategory.saas, ProductCategory.developerTool];
  static const _saasWallet = <ProductCategory>[ProductCategory.saas, ProductCategory.cryptoWallet];
  static const _browserWallet = <ProductCategory>[ProductCategory.browser, ProductCategory.cryptoWallet];
  static const _devSaas = <ProductCategory>[ProductCategory.developerTool, ProductCategory.saas];

  static FeatureOption _f(String id, String name, List<ProductCategory> categories,
      String description, _FeatureSize size, _FeatureFocus focus) {
    final scale = switch (size) {
      _FeatureSize.small => 0.72,
      _FeatureSize.medium => 1.0,
      _FeatureSize.major => 1.55,
    };
    final baseCost = switch (size) {
      _FeatureSize.small => 32000.0,
      _FeatureSize.medium => 82000.0,
      _FeatureSize.major => 178000.0,
    };
    final deltas = switch (focus) {
      _FeatureFocus.experience => (9.0, -1.0, 1.0, 0.038, 1.06),
      _FeatureFocus.performance => (3.0, 11.0, 1.0, 0.026, 1.13),
      _FeatureFocus.security => (2.0, -2.0, 14.0, 0.030, 1.08),
      _FeatureFocus.retention => (7.0, -2.0, 2.0, 0.058, 1.09),
      _FeatureFocus.platform => (4.0, 3.0, 4.0, 0.043, 1.16),
    };
    return FeatureOption(
      id: id,
      name: name,
      supportedCategories: categories,
      description: description,
      designDelta: deltas.$1 * scale,
      performanceDelta: deltas.$2 * scale,
      securityDelta: deltas.$3 * scale,
      retentionDelta: deltas.$4 * scale,
      computeMultiplier: 1.0 + (deltas.$5 - 1.0) * scale,
      developmentCost: baseCost,
    );
  }
}

enum _FeatureSize { small, medium, major }
enum _FeatureFocus { experience, performance, security, retention, platform }
