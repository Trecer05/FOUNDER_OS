# DECISIONS

## 2026-08-04 — предыдущий vertical slice отменён

Решение Сергея: единый экран с набором действий не соответствует продукту. Основная структура теперь list-first и ориентирована на управление каталогами сущностей.

## 2026-08-04 — продуктовые метрики изолированы

DAU, MAU, activation, retention, churn, rating, MRR, costs и технические показатели не показываются на главном экране. Они принадлежат карточке продукта.

## 2026-08-04 — инфраструктура физическая, а не уровни

Офис определяется числовыми capacity/comfort/rent. Серверная — rack/cooling/power/network/security. Серверы — конкретными hardware metrics. Продукты получают процент общей compute-мощности.

## 2026-08-04 — экосистема many-to-many

Интеграция не объединяет продукты. Любое число уникальных пар разрешено; продукты сохраняют отдельные users, revenue и infrastructure allocation.

## 2026-08-04 — рынок основан на сравнении

Маркетинг не заменяет продукт. Сегменты выбирают между продуктом и конкурентом по weighted metrics. Сильное преимущество может привлечь узкий сегмент.

## 2026-08-04 — equity означает контроль

Инвестиции дают долю компании и revenue share продукта. Founder ownership ниже 50% завершает сессию потерей контроля. Buyback возвращает долю.


## 2026-08-04 — roadmap продукта продолжается после релиза

Продукт не фиксируется навсегда при создании. Новые функции добавляются из карточки продукта и пересчитывают реальные технические и рыночные показатели. Live-обновления стоят на 25% дороже.

## 2026-08-04 — инвестор может прийти сам

Интерес инвесторов зависит от результатов продукта и репутации компании. Входящие предложения генерируются детерминированно и проходят те же thesis/readiness/risk-проверки, что запрос игрока.

## 2026-08-04 — сотрудники назначаются на конкретные продукты

Скрытый глобальный бонус всей команды отменён. Один сотрудник может быть назначен максимум на один продукт. Неназначенные сотрудники находятся в резерве и продолжают стоить компании зарплату.

## 2026-08-04 — security является отдельным управляемым бюджетом

Безопасность больше не сводится к одной абстрактной метрике. Контроли имеют setup cost, monthly OPEX, security/reliability effect и коэффициент снижения вероятности инцидента. Аудит фиксирует фактический risk percent и findings.

## 2026-08-04 — объяснимость рынка выделена в отдельный экран

Игрок должен видеть не только результат роста, но и данные, на которых он основан: метрики лидера, размер сегмента и веса скорости, дизайна, безопасности, функций и цены.

## 2026-08-04 — подсказки являются частью основного UI

Круглая кнопка `i` показывается только там, где есть конкретное объяснение механики, стоимости, требований, нагрузки или эффекта. Универсальная placeholder-подсказка запрещена. Обучение показывается один раз и доступно повторно из меню.

## 2026-08-04 — специальности продукта влияют на производительность

Категория продукта задаёт набор обязательных ролей и минимальное количество сотрудников. Покрытие ролей видно до и после создания и входит в `productDevelopmentCapacity`. Разработка основателем без команды не блокируется жёстко, но работает медленнее.

## 2026-08-04 — собственная AI имеет два взаимоисключающих режима

Публичная AI получает пользователей и выручку. Корпоративная AI не участвует в публичном рынке и подключается к другим продуктам. Интеграция ускоряет разработку и повышает качество, но создаёт отдельные OPEX и compute demand на AI-провайдере.

## 2026-08-04 — продукт обязан поддерживаться после релиза

Продукт постепенно устаревает без обновлений. После завершения крупных функций остаются повторяемые улучшения performance, algorithms, design, security и reliability. Каждое улучшение имеет растущую стоимость, постоянный OPEX и измеримый эффект.

## 2026-08-04 — миграция не наказывает старое сохранение

При чтении snapshot v3/v4 существующие продукты получают update marker на момент миграции. Это сохраняет состояние и не делает весь портфель мгновенно устаревшим после обновления приложения.

## 2026-08-04 — создание продукта начинается с нулевого прогресса

Прогресс `68%` не является стартовым бонусом и вводит игрока в заблуждение. Новый продукт создаётся с `developmentProgress = 0`; дальнейший рост зависит от времени, команды, role coverage, AI и инфраструктуры.

## 2026-08-04 — remote не использует физическое место офиса

Office capacity ограничивает только onsite-сотрудников. Remote-кандидат может быть нанят при заполненном офисе, но по-прежнему влияет на payroll и показатели команды.

## 2026-08-04 — назначение команды подтверждается пакетно

Checkbox в assignment sheet меняет только локальный выбор. Переводы между продуктами и резервом выполняются после отдельной кнопки «Сохранить команду».

## 2026-08-04 — continuous improvements являются post-launch системой

Повторяемые улучшения скорости, алгоритмов, дизайна, безопасности и надёжности разрешены только после выхода продукта на рынок. Правило дублируется в UI и `GameEngine`.

## 2026-08-04 — контракты используют свободную команду

Клиентские заказы выполняют основатель и сотрудники в резерве. Сотрудник, назначенный на продукт, не даёт одновременно полный бонус контракту. Параллельные заказы делят общую контрактную мощность.

## 2026-08-04 — цена подписки является управляемой рыночной переменной

Цена меняется только у live-продукта с subscription monetization. Она одновременно повышает доход с платящего пользователя и ухудшает ценовую привлекательность относительно конкурентов.

## 2026-08-04 — активная работа объединена

Продукты и клиентские контракты считаются отдельными work items с эксклюзивными командами. Контракт больше не использует весь резерв автоматически.

## 2026-08-04 — прогнозы не выдаются за факт

Доход показывается диапазоном low/base/high с явными допущениями. Фактический MRR отображается отдельно.

## 2026-08-04 — сохранения выполняются последовательно

Асинхронные записи snapshot не могут обгонять друг друга. Последнее подтверждённое состояние всегда записывается последним.


## 2026-08-05 — разработка измеряется рабочими часами, а не ускоренным процентом

Прогресс продукта считается только в рабочие дни с 09:00 до 18:00. `ProductEstimator` возвращает полный объём часов, а `GameState.productDevelopmentCapacity` — эффективные FTE назначенной команды с учётом фазы, ролей, языков, недокомплекта и overstaffing. Старый коэффициент, превращавший тысячи часов в несколько игровых суток, отменён.

## 2026-08-05 — стек является ограничением, а не коллекцией бонусов

У каждого масштаба продукта есть допустимые frameworks, лимиты языков/технологий и обязательные языки framework. Выбор всего каталога запрещён. Несвязный стек увеличивает часы, burn и риски, а качество конфигурации ограничено; «все самые сильные технологии» не гарантируют рыночный успех.

## 2026-08-05 — функции оплачиваются временем команды

Функция больше не является прямой покупкой. В roadmap она создаёт `ProductFeatureDevelopment` с требуемыми рабочими часами. Cash меняется через payroll, инфраструктуру и другие реальные расходы. Одновременно на продукте выполняется одно крупное feature-update.

## 2026-08-05 — первый сайт открывает сервисный cashflow

Клиентские контракты заблокированы до публичного релиза `company_website`. Сайт является дешёвым стартовым проектом и доступен с монетизацией `free` или `advertising`. После релиза контракты доступны из карточки сайта и центра проектов.

## 2026-08-05 — финансовый кризис имеет управляемую цепочку

Первую неделю отрицательного cash игрок исправляет ситуацию самостоятельно. После семи дней появляется возможность запросить экстренный кредит; банк оценивает релизы, контракты, burn и security risk. Повторный минус при погашении менее 70% кредита завершает сессию. После погашения более 70% предоставляется одна последняя неделя.

## 2026-08-05 — реклама покупается через канал и агентство

Абстрактный monthly marketing budget отключён. Кампания задаёт продукт, агентство, канал и бюджет. Прогноз раскрывает CPM/CPC-логику, показы, клики, диапазон пользователей, комиссию агентства, brand awareness и trust. Новый неизвестный продукт не может купить массовое доверие одним большим бюджетом.
<!-- FOUNDER_OS_V9 -->
## v9 decisions
1. No new dependencies: glass uses Flutter `BackdropFilter`.
2. Rental hosting is the default v9 infrastructure; prepared physical servers are inactive until migration.
3. Dynamic technology limit is resolved from scope, framework, roadmap, team capacity and maintenance penalty.
4. Blocker ordering is explicitly sorted.
5. Contract milestone is 35% at 50% progress; upfront remains template-driven; final pays the balance.

<!-- V10_UAT_REWORK -->
## v10 decisions

- Product-facing labels use blueprint names; broad internal categories remain implementation details.
- Rented hosting and prepared owned hardware are separate capacity pools; only the selected mode is active.
- A remote-only company has zero effective office rent.
- Improvements consume team hours, not an upfront purchase price.
- Automatic project hiring requires HR and carries a 25% salary/signing premium.
- Employees may split their time across products; workload and morale represent the cost of parallel work.
- Currency conversion is display-only and offline; snapshots continue storing ruble-denominated values.
- Swift/Kotlin are not added without profiling evidence of a platform bottleneck.

<!-- V10_OPTIMIZATION -->
## v10_optimization decisions

- GameEngine and seeded RNG remain single-source deterministic Dart.
- Swift/Kotlin are limited to atomic snapshot I/O and platform diagnostics.
- Derived indexes are GC-safe and excluded from snapshots.
- Historic presentation strings pass through one localization adapter until fully extracted into generated resources.

<!-- V11_STABILIZATION -->
## v11 stabilization decisions

- RU localization is explicit: unknown Latin text is preserved, never transliterated into pseudo-Cyrillic.
- Technical roles, units, provider/product names and promo codes may remain English in RU UI.
- Fresh games own no physical servers. Hardware appears only after a paid player action.
- HR remains a dedicated `isHr` capability for snapshot compatibility, but receives a separate visible hiring/filter path and cannot be assigned as a product specialist.
- Auto-hire is validated in UI and again in `GameEngine`.

## v12 — Founder is a real worker, company starts remote-first
- CEO contribution is deterministic and participates in product development without becoming a fake Employee record.
- Founder work is divided across active development products to prevent free parallel full-time work.
- Office rent is charged when an office is rented; `remote_first` is the only zero-rent zero-seat start.
- HR automation fills exact minimum role requirements and never hires spare headcount.
- Development content is deterministic from seed/product/day so reloads do not reshuffle the visible work.
- Critical persistence/timing remain in existing Swift/Kotlin native bridges; simulation rules stay shared in Dart to preserve iOS/Android determinism.

## v12.1 — Physical UAT overrides automated assumptions
- A green widget suite is not sufficient when reset keeps the same dashboard State alive; company setup must be re-triggered by state transition, not only initState.
- Product creation review prioritizes player decisions and budget estimates over internal resolver explanations.
- Development stages must be discoverable from primary product/project surfaces, not only a deep detail screen.
- Russian mode translates user-facing business/product metrics while preserving explicit technical identifiers such as Frontend, Backend, FTE, CU, framework/provider/language names where useful.

## v12.2 pre-TestFlight
- A new company is a full simulation reset; display preferences remain outside the snapshot.
- CEO is an automatic non-payroll project participant and is never duplicated as an Employee.
- Parallel assignment limit is four active works per employee; per-work efficiency is 100%, 70%, 55%, 40% for 1..4 works.
- Client contracts auto-assign matching least-loaded employees, while manual reassignment remains available.
- Technical mini-game appears at most once per product; correct answer grants +30% of the current stage span.
