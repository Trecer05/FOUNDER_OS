import '../entities/models.dart';
import '../entities/v12_models.dart';

class LocalizedDevelopmentText {
  const LocalizedDevelopmentText(this.ru, this.en);
  final String ru;
  final String en;
}

class DevelopmentChallengeDefinition {
  const DevelopmentChallengeDefinition({
    required this.promptRu,
    required this.promptEn,
    required this.options,
    required this.correctIndex,
  });

  final String promptRu;
  final String promptEn;
  final List<String> options;
  final int correctIndex;
}

class DesignSceneDefinition {
  const DesignSceneDefinition({
    required this.layout,
    required this.focusRu,
    required this.focusEn,
    required this.seed,
  });

  final String layout;
  final String focusRu;
  final String focusEn;
  final int seed;
}

abstract final class DevelopmentContentCatalog {
  static const List<LocalizedDevelopmentText>
  _planningIntros = <LocalizedDevelopmentText>[
    LocalizedDevelopmentText(
      "Цель итерации — зафиксировать проблему пользователя и границы первой версии.",
      "The iteration goal is to lock the user problem and the boundaries of the first version.",
    ),
    LocalizedDevelopmentText(
      "Документ описывает минимальный сценарий, который должен работать без ручных обходов.",
      "The document describes the minimum flow that must work without manual workarounds.",
    ),
    LocalizedDevelopmentText(
      "Перед реализацией фиксируем основную ценность, ограничения и критерии готовности.",
      "Before implementation, we define the core value, constraints, and acceptance criteria.",
    ),
    LocalizedDevelopmentText(
      "Проектирование начинается с пользовательского пути и только потом переходит к технологиям.",
      "Planning starts with the user journey and only then moves to technology choices.",
    ),
    LocalizedDevelopmentText(
      "Первая версия должна доказать ценность продукта до масштабирования инфраструктуры.",
      "The first version must prove product value before infrastructure is scaled.",
    ),
    LocalizedDevelopmentText(
      "В этом документе отделяем обязательные функции от идей для следующих релизов.",
      "This document separates required features from ideas for later releases.",
    ),
    LocalizedDevelopmentText(
      "Команда формулирует наблюдаемую проблему, целевого пользователя и ожидаемый результат.",
      "The team defines the observable problem, target user, and expected outcome.",
    ),
    LocalizedDevelopmentText(
      "Спецификация задаёт понятную границу релиза и исключает скрытые обязательства.",
      "The specification sets a clear release boundary and removes hidden obligations.",
    ),
    LocalizedDevelopmentText(
      "Архитектурные решения принимаются от сценариев использования, а не от модных технологий.",
      "Architecture decisions follow usage scenarios rather than fashionable technology.",
    ),
    LocalizedDevelopmentText(
      "Основная задача этапа — убрать неоднозначность до начала дорогой разработки.",
      "The main purpose of this stage is to remove ambiguity before expensive development begins.",
    ),
    LocalizedDevelopmentText(
      "Фиксируем продуктовую гипотезу, критический путь и условия провала.",
      "We define the product hypothesis, critical path, and failure conditions.",
    ),
    LocalizedDevelopmentText(
      "План релиза строится вокруг одного законченного пользовательского результата.",
      "The release plan is centered around one complete user outcome.",
    ),
    LocalizedDevelopmentText(
      "Сначала определяем измеримый исход для пользователя, затем декомпозируем систему.",
      "We first define a measurable user outcome and then decompose the system.",
    ),
    LocalizedDevelopmentText(
      "Документ связывает бизнес-цель, пользовательский поток и технические ограничения.",
      "The document links the business goal, user flow, and technical constraints.",
    ),
    LocalizedDevelopmentText(
      "Проектирование проверяет, можно ли реализовать обещание продукта текущими ресурсами.",
      "Planning verifies whether the product promise can be delivered with current resources.",
    ),
    LocalizedDevelopmentText(
      "Требования записываются так, чтобы разработчик мог проверить результат без устных пояснений.",
      "Requirements are written so an engineer can verify the result without verbal clarification.",
    ),
  ];

  static const List<LocalizedDevelopmentText>
  _architectureNotes = <LocalizedDevelopmentText>[
    LocalizedDevelopmentText(
      "Клиентский слой отделён от бизнес-логики, состояние передаётся через явные действия.",
      "The client layer is separated from business logic, and state changes through explicit actions.",
    ),
    LocalizedDevelopmentText(
      "Основной поток данных односторонний: ввод → проверка → изменение состояния → отображение.",
      "The main data flow is one-way: input → validation → state change → rendering.",
    ),
    LocalizedDevelopmentText(
      "Критические операции должны быть идемпотентными и безопасными при повторном запуске.",
      "Critical operations must be idempotent and safe to repeat.",
    ),
    LocalizedDevelopmentText(
      "Сетевые и локальные источники данных скрываются за единым интерфейсом хранения.",
      "Network and local data sources are hidden behind one storage interface.",
    ),
    LocalizedDevelopmentText(
      "Долгие операции не блокируют интерфейс и возвращают контролируемое состояние ошибки.",
      "Long operations never block the UI and return controlled error states.",
    ),
    LocalizedDevelopmentText(
      "Система разделяется на небольшие модули с понятными контрактами между ними.",
      "The system is split into small modules with clear contracts.",
    ),
    LocalizedDevelopmentText(
      "Каждый внешний интеграционный риск получает fallback и наблюдаемую ошибку.",
      "Every external integration risk gets a fallback and an observable error.",
    ),
    LocalizedDevelopmentText(
      "Состояние продукта сериализуется версионированно и не зависит от порядка коллекций.",
      "Product state is versioned when serialized and never depends on collection order.",
    ),
    LocalizedDevelopmentText(
      "Вычислительно дорогие операции кэшируются только там, где это не ломает корректность.",
      "Expensive calculations are cached only where correctness is preserved.",
    ),
    LocalizedDevelopmentText(
      "Публичные API модулей минимальны; детали реализации остаются локальными.",
      "Module APIs stay small while implementation details remain local.",
    ),
    LocalizedDevelopmentText(
      "Ключевые зависимости направлены от UI к действиям, а не напрямую к данным.",
      "Key dependencies flow from UI to actions instead of directly mutating data.",
    ),
    LocalizedDevelopmentText(
      "Архитектура допускает рост нагрузки без переписывания пользовательского сценария.",
      "The architecture can scale load without rewriting the user journey.",
    ),
    LocalizedDevelopmentText(
      "Для фоновых задач определены границы времени, отмены и повторного выполнения.",
      "Background work defines time limits, cancellation, and retry behavior.",
    ),
    LocalizedDevelopmentText(
      "Ошибки доменной логики превращаются в понятные состояния, а не в необработанные исключения.",
      "Domain failures become understandable states instead of uncaught exceptions.",
    ),
    LocalizedDevelopmentText(
      "Конфигурация отделена от кода, чтобы варианты продукта не плодили условные ветки.",
      "Configuration is separated from code so product variants do not create branching chaos.",
    ),
    LocalizedDevelopmentText(
      "Каждый этап разработки имеет измеримый вход, выход и критерий завершения.",
      "Every development stage has a measurable input, output, and completion criterion.",
    ),
  ];

  static const List<LocalizedDevelopmentText>
  _dataNotes = <LocalizedDevelopmentText>[
    LocalizedDevelopmentText(
      "Модель данных хранит только источник истины; производные показатели пересчитываются.",
      "The data model stores only the source of truth; derived metrics are recalculated.",
    ),
    LocalizedDevelopmentText(
      "Идентификаторы стабильны и не зависят от отображаемых названий.",
      "Identifiers are stable and independent from display names.",
    ),
    LocalizedDevelopmentText(
      "Пустые значения имеют явную семантику и не маскируются магическими строками.",
      "Empty values have explicit meaning and are not hidden behind magic strings.",
    ),
    LocalizedDevelopmentText(
      "История ключевых метрик ограничена по размеру и пригодна для восстановления после перезапуска.",
      "Key metric history is bounded and can be restored after restart.",
    ),
    LocalizedDevelopmentText(
      "Изменения схемы сопровождаются миграцией старых сохранений.",
      "Schema changes include migrations for older saves.",
    ),
    LocalizedDevelopmentText(
      "Денежные операции записываются отдельно от текущего баланса.",
      "Financial transactions are recorded separately from the current balance.",
    ),
    LocalizedDevelopmentText(
      "Пользовательские настройки отделены от состояния симуляции.",
      "User preferences are separated from simulation state.",
    ),
    LocalizedDevelopmentText(
      "Каждая сущность сериализуется без временных UI-полей.",
      "Each entity serializes without temporary UI-only fields.",
    ),
    LocalizedDevelopmentText(
      "Связи между объектами проверяются до записи состояния.",
      "Relations between objects are validated before state is written.",
    ),
    LocalizedDevelopmentText(
      "Удаление сущности не оставляет висячих ссылок в активных процессах.",
      "Deleting an entity never leaves dangling references in active processes.",
    ),
    LocalizedDevelopmentText(
      "Случайные результаты используют seed и счётчик, чтобы повтор игры был детерминирован.",
      "Random outcomes use a seed and counter so replay remains deterministic.",
    ),
    LocalizedDevelopmentText(
      "Списки, влияющие на выбор результата, сортируются перед детерминированным отбором.",
      "Lists that affect selection are sorted before deterministic choice.",
    ),
    LocalizedDevelopmentText(
      "Кэш не попадает в snapshot и может быть восстановлен из состояния.",
      "Caches are excluded from snapshots and can be rebuilt from state.",
    ),
    LocalizedDevelopmentText(
      "Версия snapshot повышается только при изменении сохраняемой схемы.",
      "The snapshot version changes only when the persisted schema changes.",
    ),
    LocalizedDevelopmentText(
      "Ошибочная миграция завершает загрузку контролируемой ошибкой вместо частично повреждённого состояния.",
      "A failed migration returns a controlled error instead of partially corrupted state.",
    ),
    LocalizedDevelopmentText(
      "Состояние, влияющее на деньги и прогресс, нельзя хранить только внутри виджета.",
      "State that affects money or progress cannot live only inside a widget.",
    ),
  ];

  static const List<LocalizedDevelopmentText>
  _riskNotes = <LocalizedDevelopmentText>[
    LocalizedDevelopmentText(
      "Главный риск: слишком широкий scope. Митигируем жёстким критерием первой версии.",
      "Main risk: scope is too broad. Mitigation is a strict first-release criterion.",
    ),
    LocalizedDevelopmentText(
      "Главный риск: скрытая зависимость от одного специалиста. Нужен видимый дефицит ролей.",
      "Main risk: hidden dependency on one specialist. Role deficits must stay visible.",
    ),
    LocalizedDevelopmentText(
      "Главный риск: рост инфраструктурных расходов раньше пользовательской ценности.",
      "Main risk: infrastructure costs grow before user value is proven.",
    ),
    LocalizedDevelopmentText(
      "Главный риск: невозможность отката после изменения модели данных.",
      "Main risk: data-model changes cannot be rolled back safely.",
    ),
    LocalizedDevelopmentText(
      "Главный риск: интерфейс показывает действие раньше, чем движок способен его корректно выполнить.",
      "Main risk: the UI exposes an action before the engine can execute it safely.",
    ),
    LocalizedDevelopmentText(
      "Главный риск: длинные строки и технические термины ломают мобильный layout.",
      "Main risk: long strings and technical terms break mobile layout.",
    ),
    LocalizedDevelopmentText(
      "Главный риск: перевод меняет смысл технического идентификатора.",
      "Main risk: localization changes the meaning of a technical identifier.",
    ),
    LocalizedDevelopmentText(
      "Главный риск: одна ошибка в фоновой задаче останавливает весь игровой цикл.",
      "Main risk: one background-task failure stops the whole game loop.",
    ),
    LocalizedDevelopmentText(
      "Главный риск: случайный выбор становится недетерминированным после изменения порядка данных.",
      "Main risk: random selection becomes nondeterministic after data ordering changes.",
    ),
    LocalizedDevelopmentText(
      "Главный риск: игрок не понимает причину блокировки и воспринимает её как баг.",
      "Main risk: the player cannot understand a blocker and perceives it as a bug.",
    ),
    LocalizedDevelopmentText(
      "Главный риск: автоматизация нанимает лишних людей и незаметно увеличивает burn.",
      "Main risk: automation hires unnecessary people and silently increases burn.",
    ),
    LocalizedDevelopmentText(
      "Главный риск: этап разработки выглядит как пустой progress bar и не даёт ощущения работы.",
      "Main risk: development feels like an empty progress bar instead of visible work.",
    ),
    LocalizedDevelopmentText(
      "Главный риск: редкий контент быстро начинает повторяться и разрушает ощущение живой разработки.",
      "Main risk: a small content pool repeats quickly and kills the feeling of live development.",
    ),
    LocalizedDevelopmentText(
      "Главный риск: мини-игра даёт бесконечный фарм прогресса без ограничения.",
      "Main risk: a mini-game can be farmed for unlimited progress.",
    ),
    LocalizedDevelopmentText(
      "Главный риск: улучшение продукта содержит старый идентификатор и вызывает необработанное исключение.",
      "Main risk: a legacy improvement identifier throws an uncaught exception.",
    ),
    LocalizedDevelopmentText(
      "Главный риск: новая версия ломает старое сохранение вместо контролируемой миграции.",
      "Main risk: a new version breaks old saves instead of migrating them safely.",
    ),
  ];

  static const List<LocalizedDevelopmentText> _designLayouts =
      <LocalizedDevelopmentText>[
        LocalizedDevelopmentText("Hero + metrics", "Hero + metrics"),
        LocalizedDevelopmentText("Dashboard grid", "Dashboard grid"),
        LocalizedDevelopmentText("Sidebar workspace", "Sidebar workspace"),
        LocalizedDevelopmentText("Split editor", "Split editor"),
        LocalizedDevelopmentText("Card feed", "Card feed"),
        LocalizedDevelopmentText("Command palette", "Command palette"),
        LocalizedDevelopmentText(
          "Compact mobile stack",
          "Compact mobile stack",
        ),
        LocalizedDevelopmentText("Two-column admin", "Two-column admin"),
        LocalizedDevelopmentText("Timeline workspace", "Timeline workspace"),
        LocalizedDevelopmentText("Search-first shell", "Search-first shell"),
      ];
  static const List<LocalizedDevelopmentText> _designFocus =
      <LocalizedDevelopmentText>[
        LocalizedDevelopmentText(
          "скорость первого действия",
          "time to first action",
        ),
        LocalizedDevelopmentText("читаемость метрик", "metric readability"),
        LocalizedDevelopmentText("контраст CTA", "CTA contrast"),
        LocalizedDevelopmentText("плотность информации", "information density"),
        LocalizedDevelopmentText("мобильная навигация", "mobile navigation"),
        LocalizedDevelopmentText("состояния загрузки", "loading states"),
        LocalizedDevelopmentText("пустые состояния", "empty states"),
        LocalizedDevelopmentText(
          "ошибки и восстановление",
          "errors and recovery",
        ),
        LocalizedDevelopmentText("клавиатурный сценарий", "keyboard workflow"),
        LocalizedDevelopmentText("доступность", "accessibility"),
      ];

  static const Map<String, List<LocalizedDevelopmentText>>
  _productWorkContexts = <String, List<LocalizedDevelopmentText>>{
    'company_website': <LocalizedDevelopmentText>[
      LocalizedDevelopmentText(
        'hero-блок и главный CTA',
        'hero section and primary CTA',
      ),
      LocalizedDevelopmentText(
        'форма заявки и валидация контакта',
        'lead form and contact validation',
      ),
      LocalizedDevelopmentText(
        'базовая аналитика конверсии',
        'basic conversion analytics',
      ),
      LocalizedDevelopmentText(
        'SEO metadata и social preview',
        'SEO metadata and social preview',
      ),
      LocalizedDevelopmentText(
        'страница тарифов и доверительные сигналы',
        'pricing page and trust signals',
      ),
      LocalizedDevelopmentText('адаптивная навигация', 'responsive navigation'),
      LocalizedDevelopmentText(
        'страница кейсов и доказательства ценности',
        'case studies and proof of value',
      ),
      LocalizedDevelopmentText('быстрый first paint', 'fast first paint'),
      LocalizedDevelopmentText('форма обратной связи', 'feedback form'),
      LocalizedDevelopmentText(
        'cookie и privacy настройки',
        'cookie and privacy settings',
      ),
      LocalizedDevelopmentText(
        'ошибки 404/500 и восстановление',
        '404/500 error recovery',
      ),
      LocalizedDevelopmentText(
        'доступность клавиатурной навигации',
        'keyboard accessibility',
      ),
    ],
    'ai_assistant': <LocalizedDevelopmentText>[
      LocalizedDevelopmentText(
        'чат и потоковая выдача токенов',
        'chat and streamed token output',
      ),
      LocalizedDevelopmentText('история диалогов', 'conversation history'),
      LocalizedDevelopmentText('поиск по документам', 'document retrieval'),
      LocalizedDevelopmentText(
        'evaluation качества ответов',
        'response quality evaluation',
      ),
      LocalizedDevelopmentText('лимиты контекста', 'context limits'),
      LocalizedDevelopmentText(
        'безопасная обработка файлов',
        'safe file handling',
      ),
      LocalizedDevelopmentText(
        'очередь inference-запросов',
        'inference request queue',
      ),
      LocalizedDevelopmentText('кэш embeddings', 'embedding cache'),
      LocalizedDevelopmentText('tool calling', 'tool calling'),
      LocalizedDevelopmentText('rate limit и квоты', 'rate limits and quotas'),
      LocalizedDevelopmentText(
        'fallback провайдера модели',
        'model-provider fallback',
      ),
      LocalizedDevelopmentText(
        'метрики latency и качества',
        'latency and quality metrics',
      ),
    ],
    'cloud_platform': <LocalizedDevelopmentText>[
      LocalizedDevelopmentText('создание deployment', 'deployment creation'),
      LocalizedDevelopmentText('квоты CPU и памяти', 'CPU and memory quotas'),
      LocalizedDevelopmentText('региональное размещение', 'regional placement'),
      LocalizedDevelopmentText('health checks', 'health checks'),
      LocalizedDevelopmentText('autoscaling policy', 'autoscaling policy'),
      LocalizedDevelopmentText(
        'managed database lifecycle',
        'managed database lifecycle',
      ),
      LocalizedDevelopmentText('audit log', 'audit log'),
      LocalizedDevelopmentText('секреты окружения', 'environment secrets'),
      LocalizedDevelopmentText('network policy', 'network policy'),
      LocalizedDevelopmentText('usage metering', 'usage metering'),
      LocalizedDevelopmentText('backup и restore', 'backup and restore'),
      LocalizedDevelopmentText(
        'multi-region failover',
        'multi-region failover',
      ),
    ],
    'team_saas': <LocalizedDevelopmentText>[
      LocalizedDevelopmentText('workspace и роли', 'workspace and roles'),
      LocalizedDevelopmentText(
        'realtime collaboration',
        'realtime collaboration',
      ),
      LocalizedDevelopmentText('уведомления', 'notifications'),
      LocalizedDevelopmentText('поиск по документам', 'document search'),
      LocalizedDevelopmentText('kanban workflow', 'kanban workflow'),
      LocalizedDevelopmentText(
        'комментарии и mentions',
        'comments and mentions',
      ),
      LocalizedDevelopmentText('permissions', 'permissions'),
      LocalizedDevelopmentText('offline sync', 'offline sync'),
      LocalizedDevelopmentText('activity feed', 'activity feed'),
      LocalizedDevelopmentText('automation rules', 'automation rules'),
      LocalizedDevelopmentText('import/export', 'import/export'),
      LocalizedDevelopmentText('team analytics', 'team analytics'),
    ],
    'privacy_browser': <LocalizedDevelopmentText>[
      LocalizedDevelopmentText('tab lifecycle', 'tab lifecycle'),
      LocalizedDevelopmentText('tracker blocking', 'tracker blocking'),
      LocalizedDevelopmentText('history sync', 'history sync'),
      LocalizedDevelopmentText('extension sandbox', 'extension sandbox'),
      LocalizedDevelopmentText('private mode', 'private mode'),
      LocalizedDevelopmentText('password storage', 'password storage'),
      LocalizedDevelopmentText('download manager', 'download manager'),
      LocalizedDevelopmentText('cache eviction', 'cache eviction'),
      LocalizedDevelopmentText('DNS privacy', 'DNS privacy'),
      LocalizedDevelopmentText('site permissions', 'site permissions'),
      LocalizedDevelopmentText('crash recovery', 'crash recovery'),
      LocalizedDevelopmentText('AI sidebar isolation', 'AI sidebar isolation'),
    ],
    'crypto_wallet': <LocalizedDevelopmentText>[
      LocalizedDevelopmentText('key storage', 'key storage'),
      LocalizedDevelopmentText('transaction signing', 'transaction signing'),
      LocalizedDevelopmentText(
        'balance synchronization',
        'balance synchronization',
      ),
      LocalizedDevelopmentText(
        'network fee estimate',
        'network fee estimation',
      ),
      LocalizedDevelopmentText('fraud monitoring', 'fraud monitoring'),
      LocalizedDevelopmentText('address validation', 'address validation'),
      LocalizedDevelopmentText('recovery flow', 'recovery flow'),
      LocalizedDevelopmentText('multi-chain routing', 'multi-chain routing'),
      LocalizedDevelopmentText(
        'hardware wallet handshake',
        'hardware wallet handshake',
      ),
      LocalizedDevelopmentText('transaction history', 'transaction history'),
      LocalizedDevelopmentText('token metadata', 'token metadata'),
      LocalizedDevelopmentText('risk warning', 'risk warning'),
    ],
    'city_system': <LocalizedDevelopmentText>[
      LocalizedDevelopmentText(
        'единая идентификация жителя',
        'resident identity',
      ),
      LocalizedDevelopmentText(
        'портал городских услуг',
        'city services portal',
      ),
      LocalizedDevelopmentText('транспортные события', 'transport events'),
      LocalizedDevelopmentText('платёжный шлюз', 'payment gateway'),
      LocalizedDevelopmentText(
        'межведомственная интеграция',
        'agency integration',
      ),
      LocalizedDevelopmentText('очередь обращений', 'citizen request queue'),
      LocalizedDevelopmentText('геоданные', 'geospatial data'),
      LocalizedDevelopmentText(
        'аварийные уведомления',
        'emergency notifications',
      ),
      LocalizedDevelopmentText('аудит доступа', 'access audit'),
      LocalizedDevelopmentText('открытые данные', 'open data'),
      LocalizedDevelopmentText(
        'service-level мониторинг',
        'service-level monitoring',
      ),
      LocalizedDevelopmentText('региональный failover', 'regional failover'),
    ],
    'developer_platform': <LocalizedDevelopmentText>[
      LocalizedDevelopmentText('API keys', 'API keys'),
      LocalizedDevelopmentText('SDK generation', 'SDK generation'),
      LocalizedDevelopmentText('webhook delivery', 'webhook delivery'),
      LocalizedDevelopmentText('CI job queue', 'CI job queue'),
      LocalizedDevelopmentText('artifact storage', 'artifact storage'),
      LocalizedDevelopmentText('rate limiting', 'rate limiting'),
      LocalizedDevelopmentText('observability traces', 'observability traces'),
      LocalizedDevelopmentText(
        'developer documentation',
        'developer documentation',
      ),
      LocalizedDevelopmentText('sandbox environment', 'sandbox environment'),
      LocalizedDevelopmentText('API versioning', 'API versioning'),
      LocalizedDevelopmentText('usage billing', 'usage billing'),
      LocalizedDevelopmentText('release channels', 'release channels'),
    ],
  };

  static const Map<String, List<String>>
  _codeByLanguage = <String, List<String>>{
    "html_css": <String>[
      r'''<main class="dashboard">
  <section class="metric-card" data-state="ready">
    <h2>Active users</h2>
    <strong>12,480</strong>
  </section>
</main>''',
      r'''.product-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(16rem, 1fr));
  gap: 1rem;
}''',
      r'''<button class="primary-action" aria-busy="false">
  Deploy release
</button>''',
      r''':root {
  --space: clamp(.75rem, 2vw, 1.25rem);
  --radius: 1.1rem;
}''',
      r'''@media (max-width: 640px) {
  .toolbar { position: sticky; top: 0; }
}''',
      r'''<form id="signup" autocomplete="on">
  <input name="email" type="email" required />
</form>''',
      r'''.status[data-kind="warning"] {
  border-inline-start: .25rem solid currentColor;
}''',
      r'''<nav aria-label="Product">
  <a href="/overview">Overview</a>
  <a href="/metrics">Metrics</a>
</nav>''',
      r'''.skeleton {
  min-height: 3rem;
  border-radius: .75rem;
  opacity: .48;
}''',
      r'''<section class="empty-state">
  <h3>No deployments yet</h3>
  <p>Create the first release candidate.</p>
</section>''',
      r'''.stack { display:flex; flex-direction:column; gap:.625rem; }''',
      r'''<meta name="viewport" content="width=device-width, initial-scale=1" />''',
    ],
    "javascript": <String>[
      r'''const activeUsers = sessions
  .filter(session => session.lastSeen > cutoff)
  .map(session => session.userId);''',
      r'''async function deploy(release) {
  const response = await api.post('/deployments', release);
  return response.data;
}''',
      r'''const retry = async (task, attempts = 3) => {
  try { return await task(); }
  catch (error) {
    if (attempts <= 1) throw error;
    return retry(task, attempts - 1);
  }
};''',
      r'''const byId = new Map(products.map(product => [product.id, product]));''',
      r'''window.addEventListener('visibilitychange', () => {
  if (!document.hidden) refreshMetrics();
});''',
      r'''const total = invoices.reduce((sum, invoice) => sum + invoice.amount, 0);''',
      r'''export function clamp(value, min, max) {
  return Math.min(max, Math.max(min, value));
}''',
      r'''const controller = new AbortController();
fetch(url, { signal: controller.signal });''',
      r'''queueMicrotask(() => analytics.flush());''',
      r'''const route = new URL(request.url).pathname;''',
      r'''const unique = [...new Set(events.map(event => event.id))];''',
      r'''const healthy = latencyMs < 500 && errorRate < 0.01;''',
    ],
    "typescript": <String>[
      r'''type DeploymentState = 'queued' | 'running' | 'ready' | 'failed';

interface Deployment {
  id: string;
  state: DeploymentState;
  createdAt: number;
}''',
      r'''const index = new Map<string, Product>(
  products.map(product => [product.id, product]),
);''',
      r'''async function load<T>(url: string): Promise<T> {
  const response = await fetch(url);
  if (!response.ok) throw new Error(`HTTP ${response.status}`);
  return response.json() as Promise<T>;
}''',
      r'''function assertNever(value: never): never {
  throw new Error(`Unexpected state: ${String(value)}`);
}''',
      r'''const visible = candidates.filter(
  ({ remote, role }) => remote && role === requiredRole,
);''',
      r'''type Result<T> =
  | { ok: true; value: T }
  | { ok: false; error: string };''',
      r'''const next = structuredClone(snapshot);
next.version += 1;''',
      r'''function percent(value: number): string {
  return `${(value * 100).toFixed(1)}%`;
}''',
      r'''const selected = ids.flatMap(id => byId.get(id) ? [byId.get(id)!] : []);''',
      r'''export const isReady = (p: Product) =>
  p.progress >= 1 && p.capacity > 0;''',
      r'''const timeout = AbortSignal.timeout(5_000);''',
      r'''const sorted = [...offers].sort((a, b) => a.price - b.price);''',
    ],
    "python": <String>[
      r'''def active_users(sessions, cutoff):
    return {
        session.user_id
        for session in sessions
        if session.last_seen > cutoff
    }''',
      r'''async def deploy(client, release):
    response = await client.post("/deployments", json=release)
    response.raise_for_status()
    return response.json()''',
      r'''def clamp(value: float, low: float, high: float) -> float:
    return min(high, max(low, value))''',
      r'''from dataclasses import dataclass

@dataclass(frozen=True)
class Metric:
    name: str
    value: float''',
      r'''by_id = {product.id: product for product in products}''',
      r'''def chunks(items, size):
    for index in range(0, len(items), size):
        yield items[index:index + size]''',
      r'''with transaction():
    repository.save(snapshot)
    ledger.append(entry)''',
      r'''result = sorted(offers, key=lambda offer: (offer.price, -offer.quality))''',
      r'''if not product_id:
    raise ValueError("product_id is required")''',
      r'''retention = returning_users / max(1, cohort_size)''',
      r'''payload = {"version": VERSION, "state": state.to_dict()}''',
      r'''await asyncio.gather(*(worker(job) for job in jobs))''',
    ],
    "go": <String>[
      r'''type Deployment struct {
	ID        string    `json:"id"`
	State     string    `json:"state"`
	CreatedAt time.Time `json:"createdAt"`
}''',
      r'''func clamp(value, min, max float64) float64 {
	if value < min { return min }
	if value > max { return max }
	return value
}''',
      r'''ctx, cancel := context.WithTimeout(ctx, 5*time.Second)
defer cancel()''',
      r'''if err := repository.Save(ctx, snapshot); err != nil {
	return fmt.Errorf("save snapshot: %w", err)
}''',
      r'''users := make(map[string]struct{}, len(sessions))
for _, session := range sessions {
	users[session.UserID] = struct{}{}
}''',
      r'''sort.SliceStable(offers, func(i, j int) bool {
	return offers[i].Price < offers[j].Price
})''',
      r'''select {
case result := <-done:
	return result
case <-ctx.Done():
	return ctx.Err()
}''',
      r'''mux.HandleFunc("GET /health", healthHandler)''',
      r'''atomic.AddInt64(&metrics.requests, 1)''',
      r'''for _, product := range products {
	if product.Active { active = append(active, product) }
}''',
      r'''encoded, err := json.Marshal(snapshot)
if err != nil { return err }''',
      r'''defer rows.Close()
for rows.Next() { /* scan */ }''',
    ],
    "rust": <String>[
      r'''#[derive(Debug, Clone, Serialize, Deserialize)]
struct Deployment {
    id: String,
    state: DeploymentState,
}''',
      r'''fn clamp(value: f64, min: f64, max: f64) -> f64 {
    value.max(min).min(max)
}''',
      r'''let active: HashSet<_> = sessions
    .iter()
    .filter(|s| s.last_seen > cutoff)
    .map(|s| &s.user_id)
    .collect();''',
      r'''let snapshot = repository
    .load(id)
    .await
    .map_err(AppError::Storage)?;''',
      r'''match deployment.state {
    State::Ready => publish(deployment).await?,
    State::Failed => retry(deployment).await?,
    _ => {}
}''',
      r'''let mut offers = offers.to_vec();
offers.sort_by(|a, b| a.price.total_cmp(&b.price));''',
      r'''tokio::select! {
    value = worker() => value?,
    _ = shutdown.recv() => return Ok(()),
}''',
      r'''let payload = serde_json::to_vec(&snapshot)?;''',
      r'''if product_id.is_empty() {
    return Err(AppError::InvalidInput);
}''',
      r'''let ratio = returning as f64 / cohort.max(1) as f64;''',
      r'''Arc::clone(&state).metrics.increment();''',
      r'''#[tracing::instrument(skip(repository))]
async fn save(repository: &Repo) -> Result<()> { Ok(()) }''',
    ],
    "dart": <String>[
      r'''final activeUsers = sessions
    .where((session) => session.lastSeen > cutoff)
    .map((session) => session.userId)
    .toSet();''',
      r'''Future<Deployment> deploy(Release release) async {
  final response = await client.post('/deployments', data: release.toJson());
  return Deployment.fromJson(response.data);
}''',
      r'''double clamp(double value, double min, double max) =>
    value.clamp(min, max).toDouble();''',
      r'''final byId = <String, Product>{
  for (final product in products) product.id: product,
};''',
      r'''final sorted = List<Offer>.of(offers)
  ..sort((a, b) => a.price.compareTo(b.price));''',
      r'''switch (state) {
  case ReadyState():
    await publish();
  case FailedState(:final error):
    log(error);
}''',
      r'''final payload = jsonEncode(snapshot.toJson());''',
      r'''if (productId.trim().isEmpty) {
  throw ArgumentError.value(productId, 'productId');
}''',
      r'''await Future.wait(jobs.map(worker));''',
      r'''final ratio = returning / math.max(1, cohort);''',
      r'''unawaited(metrics.flush());''',
      r'''const Duration requestTimeout = Duration(seconds: 5);''',
    ],
    "swift": <String>[
      r'''struct Deployment: Codable, Sendable {
    let id: String
    let state: State
    let createdAt: Date
}''',
      r'''func clamp(_ value: Double, min: Double, max: Double) -> Double {
    Swift.min(max, Swift.max(min, value))
}''',
      r'''let activeUsers = Set(
    sessions.filter { $0.lastSeen > cutoff }.map(\.userID)
)''',
      r'''let data = try JSONEncoder().encode(snapshot)
try data.write(to: url, options: .atomic)''',
      r'''guard !productID.isEmpty else {
    throw AppError.invalidProduct
}''',
      r'''let sorted = offers.sorted {
    $0.price == $1.price ? $0.quality > $1.quality : $0.price < $1.price
}''',
      r'''async let metrics = loadMetrics()
async let releases = loadReleases()
return try await (metrics, releases)''',
      r'''switch deployment.state {
case .ready: try await publish(deployment)
case .failed: try await retry(deployment)
default: break
}''',
      r'''let ratio = Double(returning) / Double(max(1, cohort))''',
      r'''try await withThrowingTaskGroup(of: Void.self) { group in
    jobs.forEach { job in group.addTask { try await worker(job) } }
}''',
      r'''actor SnapshotStore {
    private var latest: Snapshot?
}''',
      r'''defer { transaction.finish() }''',
    ],
    "kotlin": <String>[
      r'''@Serializable
data class Deployment(
    val id: String,
    val state: DeploymentState,
    val createdAt: Long,
)''',
      r'''fun clamp(value: Double, min: Double, max: Double): Double =
    value.coerceIn(min, max)''',
      r'''val activeUsers = sessions
    .asSequence()
    .filter { it.lastSeen > cutoff }
    .map { it.userId }
    .toSet()''',
      r'''require(productId.isNotBlank()) { "productId is required" }''',
      r'''val sorted = offers.sortedWith(
    compareBy<Offer> { it.price }.thenByDescending { it.quality }
)''',
      r'''coroutineScope {
    jobs.map { job -> async { worker(job) } }.awaitAll()
}''',
      r'''when (deployment.state) {
    READY -> publish(deployment)
    FAILED -> retry(deployment)
    else -> Unit
}''',
      r'''val payload = json.encodeToString(snapshot)''',
      r'''val ratio = returning.toDouble() / maxOf(1, cohort)''',
      r'''withTimeout(5_000) { api.fetchMetrics() }''',
      r'''mutex.withLock { repository.save(snapshot) }''',
      r'''flow.distinctUntilChanged().collect(::render)''',
    ],
    "java": <String>[
      r'''public record Deployment(
    String id,
    DeploymentState state,
    Instant createdAt
) {}''',
      r'''static double clamp(double value, double min, double max) {
    return Math.min(max, Math.max(min, value));
}''',
      r'''Set<String> activeUsers = sessions.stream()
    .filter(s -> s.lastSeen().isAfter(cutoff))
    .map(Session::userId)
    .collect(Collectors.toSet());''',
      r'''if (productId == null || productId.isBlank()) {
    throw new IllegalArgumentException("productId is required");
}''',
      r'''offers.sort(
    Comparator.comparingDouble(Offer::price)
        .thenComparing(Offer::quality, Comparator.reverseOrder())
);''',
      r'''var payload = objectMapper.writeValueAsBytes(snapshot);''',
      r'''try (var transaction = database.begin()) {
    repository.save(snapshot);
    transaction.commit();
}''',
      r'''return CompletableFuture.allOf(tasks.toArray(CompletableFuture[]::new));''',
      r'''double ratio = (double) returning / Math.max(1, cohort);''',
      r'''switch (deployment.state()) {
    case READY -> publish(deployment);
    case FAILED -> retry(deployment);
    default -> {}
}''',
      r'''var timeout = Duration.ofSeconds(5);''',
      r'''metrics.incrementAndGet();''',
    ],
    "php": <String>[
      r'''final class Deployment {
    public function __construct(
        public readonly string $id,
        public readonly string $state,
    ) {}
}''',
      r'''function clamp(float $value, float $min, float $max): float {
    return min($max, max($min, $value));
}''',
      r'''$activeUsers = array_unique(array_map(
    fn ($session) => $session->userId,
    array_filter($sessions, fn ($s) => $s->lastSeen > $cutoff),
));''',
      r'''if ($productId === '') {
    throw new InvalidArgumentException('productId is required');
}''',
      r'''usort($offers, fn ($a, $b) => $a->price <=> $b->price);''',
      r'''$payload = json_encode($snapshot, JSON_THROW_ON_ERROR);''',
      r'''DB::transaction(function () use ($snapshot) {
    $this->repository->save($snapshot);
});''',
      r'''$ratio = $returning / max(1, $cohort);''',
      r'''return match ($deployment->state) {
    'ready' => $this->publish($deployment),
    'failed' => $this->retry($deployment),
    default => null,
};''',
      r'''$response = $client->get('/metrics', ['timeout' => 5]);''',
      r'''collect($jobs)->each(fn ($job) => dispatch($job));''',
      r'''cache()->remember($key, 60, fn () => $repository->load($id));''',
    ],
    "cpp": <String>[
      r'''struct Deployment {
    std::string id;
    DeploymentState state;
    std::chrono::system_clock::time_point created_at;
};''',
      r'''double clamp(double value, double min, double max) {
    return std::min(max, std::max(min, value));
}''',
      r'''std::unordered_set<std::string> active_users;
for (const auto& session : sessions) {
    if (session.last_seen > cutoff) active_users.insert(session.user_id);
}''',
      r'''if (product_id.empty()) {
    throw std::invalid_argument("product_id is required");
}''',
      r'''std::ranges::sort(offers, {}, &Offer::price);''',
      r'''auto payload = nlohmann::json(snapshot).dump();''',
      r'''std::scoped_lock lock(snapshot_mutex);
repository.save(snapshot);''',
      r'''const double ratio =
    static_cast<double>(returning) / std::max(1, cohort);''',
      r'''switch (deployment.state) {
case State::Ready: publish(deployment); break;
case State::Failed: retry(deployment); break;
default: break;
}''',
      r'''std::jthread worker([&](std::stop_token token) {
    run_queue(token);
});''',
      r'''auto deadline = std::chrono::steady_clock::now() + 5s;''',
      r'''metrics.requests.fetch_add(1, std::memory_order_relaxed);''',
    ],
  };

  static const Map<String, List<String>> _debugByLanguage =
      <String, List<String>>{
        "html_css": <String>[
          "Unexpected layout shift near .toolbar",
          "CSS grid produced a min-content overflow",
          "Missing aria-label on interactive control",
          "Viewport unit caused mobile jump",
          "Specificity conflict changed CTA state",
          "Focus ring clipped by overflow:hidden",
          "Invalid nested interactive element",
          "Image intrinsic size changed layout",
        ],
        "javascript": <String>[
          "TypeError: cannot read properties of undefined",
          "UnhandledPromiseRejection in deploy()",
          "AbortError while refreshing metrics",
          "Duplicate event listener after navigation",
          "Stale closure returned an old product state",
          "NaN propagated into revenue calculation",
          "Race between save() and refresh()",
          "Map lookup returned undefined for product id",
        ],
        "typescript": <String>[
          "Type 'undefined' is not assignable to type 'Product'",
          "Exhaustiveness check reached an unknown state",
          "Promise<Result> was used without awaiting",
          "Readonly snapshot mutated through shared reference",
          "Generic payload failed runtime validation",
          "Union narrowing missed the failed branch",
          "Index signature hid a missing identifier",
          "AbortSignal timeout escaped error mapping",
        ],
        "python": <String>[
          "KeyError: 'product_id'",
          "RuntimeError: coroutine was never awaited",
          "ValueError: invalid snapshot version",
          "ZeroDivisionError in cohort retention",
          "CancelledError escaped worker boundary",
          "TypeError: expected mapping, got None",
          "IntegrityError during duplicate insert",
          "TimeoutError while loading metrics",
        ],
        "go": <String>[
          "panic: runtime error: index out of range",
          "context deadline exceeded",
          "concurrent map writes",
          "json: cannot unmarshal string into Go struct field",
          "sql: transaction has already been committed",
          "send on closed channel",
          "nil pointer dereference in repository",
          "unexpected EOF while decoding snapshot",
        ],
        "rust": <String>[
          "called `Option::unwrap()` on a `None` value",
          "borrowed value does not live long enough",
          "serde_json: missing field `productId`",
          "task cancelled before transaction commit",
          "channel closed while worker was active",
          "integer conversion overflowed expected range",
          "state enum variant was not handled",
          "timeout elapsed before repository response",
        ],
        "dart": <String>[
          "Bad state: No element",
          "Null check operator used on a null value",
          "RangeError: index out of range",
          "A Future was not awaited before rebuild",
          "StateError: snapshot version is unsupported",
          "Concurrent modification during iteration",
          "LateInitializationError in screen state",
          "FormatException while decoding persisted state",
        ],
        "swift": <String>[
          "Fatal error: Unexpectedly found nil while unwrapping an Optional",
          "DecodingError.keyNotFound for productId",
          "CancellationError escaped task boundary",
          "Actor-isolated value accessed from nonisolated context",
          "File write failed before atomic replace",
          "Index out of range in release list",
          "Task group propagated child failure",
          "MainActor update attempted from background context",
        ],
        "kotlin": <String>[
          "NullPointerException in product lookup",
          "JsonDecodingException: missing productId",
          "JobCancellationException escaped boundary",
          "ConcurrentModificationException in assignment list",
          "IllegalStateException: snapshot version unsupported",
          "TimeoutCancellationException during API call",
          "Room transaction rolled back after constraint failure",
          "IndexOutOfBoundsException in offer selection",
        ],
        "java": <String>[
          "NullPointerException in product lookup",
          "CompletionException wrapped repository timeout",
          "IllegalArgumentException: productId is required",
          "ConcurrentModificationException in assignment loop",
          "JsonMappingException: missing productId",
          "Transaction rolled back after constraint failure",
          "IndexOutOfBoundsException in candidate selection",
          "TimeoutException while loading metrics",
        ],
        "php": <String>[
          "Undefined array key \"product_id\"",
          "JsonException: Syntax error",
          "PDOException: transaction rolled back",
          "TypeError: expected Product, null given",
          "RuntimeException: duplicate deployment id",
          "Timeout while loading metrics",
          "InvalidArgumentException: productId is required",
          "LogicException: unknown deployment state",
        ],
        "cpp": <String>[
          "std::out_of_range in product lookup",
          "std::bad_optional_access",
          "JSON parse error near snapshot payload",
          "data race detected in metrics collector",
          "use-after-move in deployment queue",
          "transaction aborted before commit",
          "timeout waiting for worker result",
          "invalid_argument: product_id is required",
        ],
      };

  static LocalizedDevelopmentText _productContext(
    Product product,
    String key,
    int salt,
  ) {
    final pool =
        _productWorkContexts[product.blueprintId] ??
        _productWorkContexts['team_saas']!;
    return pool[_pickIndex(key, pool.length, salt)];
  }

  static String _commentLine(String language, String value) =>
      switch (language) {
        'html_css' => '<!-- $value -->',
        'python' => '# $value',
        _ => '// $value',
      };

  static int stableHash(String value) {
    var hash = 0x811C9DC5;
    for (final unit in value.codeUnits) {
      hash ^= unit;
      hash = (hash * 0x01000193) & 0x7FFFFFFF;
    }
    return hash;
  }

  static int _pickIndex(String key, int length, int salt) {
    if (length <= 1) return 0;
    return stableHash('$key::$salt') % length;
  }

  static String primaryLanguageId(Product product) =>
      product.languageIds.isEmpty ? 'typescript' : product.languageIds.first;

  static LocalizedDevelopmentText planningDocument({
    required Product product,
    required int seed,
    required int day,
  }) {
    final key = '${product.id}:$seed:$day:${product.blueprintId}';
    final intro = _planningIntros[_pickIndex(key, _planningIntros.length, 11)];
    final architecture =
        _architectureNotes[_pickIndex(key, _architectureNotes.length, 23)];
    final data = _dataNotes[_pickIndex(key, _dataNotes.length, 37)];
    final risk = _riskNotes[_pickIndex(key, _riskNotes.length, 53)];
    final context = _productContext(product, key, 67);
    return LocalizedDevelopmentText(
      'PRODUCT SPEC — ${product.name}\n\n'
          'ФОКУС ИТЕРАЦИИ\n${context.ru}\n\n'
          'ЦЕЛЬ\n${intro.ru}\n\n'
          'АРХИТЕКТУРА\n${architecture.ru}\n\n'
          'ДАННЫЕ\n${data.ru}\n\n'
          'РИСК\n${risk.ru}',
      'PRODUCT SPEC — ${product.name}\n\n'
          'ITERATION FOCUS\n${context.en}\n\n'
          'GOAL\n${intro.en}\n\n'
          'ARCHITECTURE\n${architecture.en}\n\n'
          'DATA\n${data.en}\n\n'
          'RISK\n${risk.en}',
    );
  }

  static DesignSceneDefinition designScene({
    required Product product,
    required int seed,
    required int day,
  }) {
    final key = '${product.id}:$seed:$day:design';
    final layout = _designLayouts[_pickIndex(key, _designLayouts.length, 7)];
    final focus = _designFocus[_pickIndex(key, _designFocus.length, 19)];
    final context = _productContext(product, key, 31);
    return DesignSceneDefinition(
      layout: layout.en,
      focusRu: '${layout.ru} · ${focus.ru} · ${context.ru}',
      focusEn: '${layout.en} · ${focus.en} · ${context.en}',
      seed: stableHash('$key:${layout.en}:${focus.en}:${context.en}'),
    );
  }

  static String codeSample({
    required Product product,
    required int seed,
    required int day,
  }) {
    final language = primaryLanguageId(product);
    final pool = _codeByLanguage[language] ?? _codeByLanguage['typescript']!;
    final key = '${product.id}:$seed:$day:$language:code';
    final context = _productContext(product, key, 47);
    final firstIndex = _pickIndex(key, pool.length, 29);
    var secondIndex = _pickIndex(key, pool.length, 83);
    if (pool.length > 1 && secondIndex == firstIndex) {
      secondIndex = (secondIndex + 1) % pool.length;
    }
    final first = pool[firstIndex];
    final second = pool[secondIndex];
    return '${_commentLine(language, '${product.name} · ${context.en}')}\n'
        '$first\n\n$second';
  }

  static String debugSample({
    required Product product,
    required int seed,
    required int day,
  }) {
    final language = primaryLanguageId(product);
    final pool = _debugByLanguage[language] ?? _debugByLanguage['typescript']!;
    final key = '${product.id}:$seed:$day:$language:debug';
    final context = _productContext(product, key, 59);
    final firstIndex = _pickIndex(key, pool.length, 41);
    var secondIndex = _pickIndex(key, pool.length, 97);
    if (pool.length > 1 && secondIndex == firstIndex) {
      secondIndex = (secondIndex + 1) % pool.length;
    }
    return '${pool[firstIndex]} · ${context.en}\n'
        'trace: ${pool[secondIndex]}';
  }

  static DevelopmentChallengeDefinition challenge({
    required Product product,
    required FounderDevelopmentStage stage,
    required int seed,
    required int day,
  }) {
    final language = primaryLanguageId(product);
    final key = '${product.id}:$seed:$day:${stage.name}:challenge';
    final safePool =
        _codeByLanguage[language] ?? _codeByLanguage['typescript']!;
    final correct = safePool[_pickIndex(key, safePool.length, 61)];
    final wrongA = _wrongOptionA(language);
    final wrongB = _wrongOptionB(language);
    final correctIndex = _pickIndex(key, 3, 73);
    final options = <String>['', '', ''];
    options[correctIndex] = correct;
    options[(correctIndex + 1) % 3] = wrongA;
    options[(correctIndex + 2) % 3] = wrongB;
    return DevelopmentChallengeDefinition(
      promptRu: switch (stage) {
        FounderDevelopmentStage.planning =>
          'Какой фрагмент выглядит безопасной частью реализации текущего продукта?',
        FounderDevelopmentStage.design =>
          'Какой фрагмент выглядит безопасной частью реализации без явного crash/overflow?',
        FounderDevelopmentStage.implementation =>
          'Выберите безопасный фрагмент кода на выбранном языке. Два других варианта содержат очевидно плохую практику.',
        FounderDevelopmentStage.debugging =>
          'Какой фрагмент безопаснее оставить после отладки? Два других способны вызвать crash или сломать layout.',
      },
      promptEn: switch (stage) {
        FounderDevelopmentStage.planning =>
          'Which fragment looks like a safe part of the current product implementation?',
        FounderDevelopmentStage.design =>
          'Which fragment looks production-safe without an obvious crash or overflow?',
        FounderDevelopmentStage.implementation =>
          'Choose the safe fragment in the selected language. The other two contain an obvious bad practice.',
        FounderDevelopmentStage.debugging =>
          'Which fragment is safer to keep after debugging? The other two can crash or break layout.',
      },
      options: List<String>.unmodifiable(options),
      correctIndex: correctIndex,
    );
  }

  static String _wrongOptionA(String language) => switch (language) {
    "html_css" => r'''position: fixed; width: 9999px;''',
    "javascript" => r'''const product = products[999];''',
    "typescript" => r'''const product = products[999] as Product;''',
    "python" => r'''product = products[999]''',
    "go" => r'''product := products[999]''',
    "rust" => r'''let product = &products[999];''',
    "dart" => r'''final product = state.products.single;''',
    "swift" => r'''let product = products[999]''',
    "kotlin" => r'''val product = products[999]''',
    "java" => r'''var product = products.get(999);''',
    "php" => r'''$product = $products[999];''',
    "cpp" => r'''auto product = products.at(999);''',
    _ => r'''products[999]''',
  };

  static String _wrongOptionB(String language) => switch (language) {
    "html_css" => r'''overflow: visible; min-width: 1800px;''',
    "javascript" => r'''const product = null.product;''',
    "typescript" => r'''const product = undefined!;''',
    "python" => r'''product = None.id''',
    "go" => r'''panic("just pick first product")''',
    "rust" => r'''let product = None::<Product>.unwrap();''',
    "dart" => r'''final product = state.products.firstWhere((_) => false);''',
    "swift" => r'''let product = Optional<Product>.none!''',
    "kotlin" => r'''val product = null!!''',
    "java" => r'''Product product = null; product.id();''',
    "php" => r'''$product = null->id;''',
    "cpp" => r'''Product* product = nullptr; product->id();''',
    _ => r'''null!''',
  };
}
