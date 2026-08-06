# CHANGELOG

## Unreleased — company simulation rework

### Added

- product catalog, detailed product builder and post-creation feature roadmap;
- six product categories, frameworks, languages, technologies and features;
- numeric candidate market and employee roster;
- office, server-room and server-hardware catalogs;
- per-product compute allocation;
- weighted market segments and competitor benchmarks;
- many-to-many ecosystem;
- investor requests, refusals, counteroffers, inbound interest, cap table, revenue share and buyback;
- external portfolio, product/company acquisitions and migration readiness;
- security attacks, crypto-wallet failure and focused news;
- snapshot schema v3 and migration tests;
- new Overview, Products, Team, Infrastructure, Ecosystem, Investors, Market, News and More screens.

### Changed

- dashboard now contains company aggregates only;
- old action-card vertical slice removed;
- product success is calculated from measurable market differences;
- office and server infrastructure are no longer combined;
- office comfort/communication affect development and hiring;
- server-room physical security reduces attack probability.

### Verification

Prepared but not yet compiled in the archive-generation environment. Local Flutter analyze, tests, builds and simulator smoke test are required.

## Unreleased — operations and security depth v4

### Added

- отдельные проектные команды и назначения сотрудников;
- управление сотрудниками: резерв, повышение, обучение и увольнение;
- расчёт development capacity для каждого продукта;
- центр безопасности с шестью конкретными контролями;
- security audit history и snapshot v4;
- конкурентная разведка с точными benchmark и segment weights;
- отдельный P&L / cap table / portfolio экран;
- новые unit и widget tests для operations/security.

### Changed

- сотрудники больше не влияют на все продукты одновременно;
- risk атаки учитывает внедрённые контроли;
- стоимость локализации security incident зависит от incident response maturity;
- экран продукта показывает назначенную команду и security operations.

## Unreleased — guidance, corporate AI and product evolution v5

### Added

- пятишаговое обучение и повторный запуск из меню;
- круглые `i`-подсказки на карточках и расшифровки метрик;
- средние показатели всей команды;
- обязательные специальности по категориям продуктов и role coverage;
- публичный и корпоративный режим собственного AI-продукта;
- AI-интеграции с development/quality boost, OPEX и compute demand;
- product freshness и постепенное устаревание;
- пять повторяемых continuous improvements;
- snapshot v5 и миграция v3/v4;
- tests для ролей, AI, freshness, improvements и migration freshness.

### Changed

- корпоративная AI не конкурирует на публичном рынке и автоматически отключает рекламный бюджет;
- founder-only разработка остаётся возможной, но нехватка ролей снижает capacity;
- старые продукты после миграции не получают мгновенный штраф устаревания;
- roadmap больше не заканчивает развитие продукта: технические улучшения доступны всегда.

## Unreleased — business loop and UX fixes v6

### Added

- пять шаблонов клиентских контрактов с авансом, сроком, ролями, прогрессом, финальной выплатой и штрафом;
- отдельный экран контрактов и переход из раздела «Ещё»;
- изменение цены подписки у live-продукта;
- проектная сводка на Overview;
- snapshot schema v6 с сериализацией контрактов;
- domain, migration и widget tests для новых правил.

### Fixed

- новый продукт начинает разработку с `0%`, а не с `68%`;
- checkbox назначения сотрудника больше не закрывает sheet;
- remote-сотрудники не занимают офисные места;
- continuous improvements нельзя выпустить до релиза;
- карточки без конкретного объяснения больше не показывают placeholder `i`.

### Changed

- проектная команда сохраняется одним подтверждённым действием пользователя;
- параллельные контракты делят доступную контрактную мощность;
- deadline учитывается точно даже при большом скачке игрового времени;
- цена подписки влияет и на выручку, и на ценовую конкурентоспособность.

## Unreleased — product development economy v8

### Added

- семишаговый мастер проекта: масштаб, framework, языки, технологии, функции, монетизация и итоговый аудит;
- восемь масштабов продукта от сайта компании до цифровой системы города;
- двенадцать языков и девять frameworks с явными плюсами, минусами и обязательным стеком;
- языковые компетенции кандидатов и сотрудников;
- шесть фаз разработки с критическими ролями, movable/critical staff и staffing status;
- investor gates для крупных проектов, включая пять инвесторов для city system;
- post-release feature work queue в рабочих часах;
- price impact forecast, churn delta и 45-дневное затухание ценового шока;
- рекламные агентства, каналы, CPM/CPC, показы, клики, доверие и диапазон acquisition;
- недельная liquidity chain, bank decision, emergency loan и insolvency game over;
- тестовые промокоды `FOUNDER-RICH` и `FOUNDER-BROKE`;
- snapshot schema v8 и focused `product_economy_v8_test.dart`.

### Changed

- стартовый капитал снижен до 450 000 ₽;
- разработка идёт только по будням 09:00–18:00 и измеряется эффективными FTE;
- выбор лишних языков/технологий блокируется либо ухудшает coherence вместо суммирования бонусов;
- функции больше не списывают прямую стоимость: расходы возникают через payroll и инфраструктуру;
- контракты открываются только после релиза сайта компании;
- общий рекламный бюджет заменён конкретными кампаниями;
- сложность зависит от управляемых решений: staffing, stack, security, trust, burn и конкурентоспособность.

### Verification

Пакет требует локального `flutter analyze`, полного `flutter test`, iOS Simulator build и ручного сценария. Среда сборки архива не содержит Flutter SDK.
<!-- FOUNDER_OS_V9 -->
## v9 — UI, Infrastructure, Explainability & Content Expansion
Added floating time controls, hosting plans, owned migration, dynamic stack selection, concrete staffing deficits, staged contract payments, detailed payroll transactions, glossary, compact team metrics, ecosystem integration timing/risks, snapshot v9 migration, >7× content asset, validator and tests.

<!-- V10_UAT_REWORK -->
## v10 UAT rework

- Added six-section product workspaces, metric ranges, explainable coherence/capacity, project hiring, and infrastructure separation.
- Added HR auto-hire, multi-product assignments, workload/morale recovery, investor negotiation status, business credit, emergency negative-cash save, time-based improvements, contract grace and partial payouts.
- Added snapshot v10, prepared starter servers, remote-first office economics, RUB/USD/EUR display, partial RU/EN preference support, tests, and verifier.

<!-- V10_OPTIMIZATION -->
## v10_optimization

- Optimized simulation projection lookup, immutable state queries, ticker drift handling, save coalescing, background snapshot encoding and UI rebuild scope.
- Added atomic native snapshot backends in Swift/Kotlin with safe Dart fallback.
- Added strict RU/EN presentation normalization and localization audit.
