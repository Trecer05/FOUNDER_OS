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
