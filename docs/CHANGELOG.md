# CHANGELOG

## v15 — Long-term competition and recovery

- Reduced player cyberattack probability to one third and added deterministic cyber incidents for rival companies.
- Added rotating weekly bankruptcy checkpoints and a one-click rollback to the newest save at least seven game days old.
- Enlarged the global date/time control and added the weekday.
- Made VPS usable without DevOps at 82% effective capacity; managed hosting remains fully operated.
- Reworked infrastructure summaries into a compact two-column grid and added CPU, RAM and storage constraints to server configurations and product load.
- Added 20 deterministic competitors per product category, varied feature sets, a 100-point leader and a unified ranking table the player can overtake.
- Increased paid acquisition and exposed post-release feature work, stack expansion, weighted bugs and bug fixing.
- Added product renaming after release and persisted release time, bug backlog and fixed-bug count in snapshot schema v13.
- Moved monetization into its own product workspace section with model-specific price, intensity and free-tier controls.
- Added filters for hired employees plus training, grade promotion and confirmed dismissal actions. Product Manager bonus now scales from intern to senior.
- Added an on-site-only productivity bonus that increases with office tier.
- Clarified active work and added a one-week crunch mode: +28% for seven days, followed by a seven-day −22% recovery period.
- Added irreversible technical aging after 180 days so mature products eventually require replacement, sale or a new generation.
- Enabled HSM for Dart mobile products.
- Fixed the second-product release button: a ready product with zero allocation now receives a visible release error when no infrastructure exists, or atomically reserves 10% capacity when infrastructure is available.

## v14 — Publisher UAT polish

- R7: старый тест параллельной работы теперь создаёт реальную активную доработку
  live-продукта перед сравнением нагрузки продукта и контракта. Пассивное
  назначение на выпущенный продукт по-прежнему не считается текущей работой.

- Fixed remaining data-driven English localization leaks visible in device screenshots.
- Moved owned-server migration beside compute allocation.
- Added HR-grade hiring limits, existing-staff reuse and deterministic sourcing of missing roles.
- Counted only genuine active work when applying parallel-work efficiency.
- Added visible employee productivity and factor explanations.
- Added immediate credit-action feedback.
- Restored workspace monetization and subscription pricing controls.
- Removed the duplicate advertising channel selector.
- Added three high-density AI/enterprise server options with stronger compute economics.

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

## Unreleased — v13 release-candidate regression hotfix

### Fixed

- client-contract advances are recorded once in the finance ledger instead of being duplicated by the generic action recorder;
- generated candidate widget tests now wait for the actual candidate card, not the matching text inside the search field;
- subscription pricing remains reachable on products with a large feature roadmap.

### Changed

- the available-feature roadmap is collapsed by default and can be expanded on demand;
- the v13 verifier runs all gates and writes `v13_verification_summary.txt` with a concise pass/fail result for every stage.


## Unreleased — v15 R3 verification hotfix

### Fixed

- bankruptcy rollback dialog now checks both `State.mounted` and `dialogContext.mounted` after the async restore call before using either context, clearing `use_build_context_synchronously` under `flutter analyze`;
- v15 static audit now locks this async-context safety invariant so the analyzer regression cannot silently return.


## Unreleased — v15 R4 full-suite compatibility hotfix

### Fixed

- failed save-slot loading always restarts the simulation clock through `try/finally`;
- the first lightweight company website no longer trips a RAM overload on Shared Launch before finance/loan logic can run;
- severe infrastructure load still triggers the 135% critical event, but the market-quality penalty is capped at that boundary so product quality is not inverted by an already-fatal overload value;
- the larger weekday/date/time display is rendered as one rich undecorated text block and no longer breaks the v10 global-bar UX regression;
- added a focused compatibility suite covering the four failures that first appeared when R3 reached the complete Flutter test suite.
