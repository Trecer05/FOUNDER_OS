## V17 R14 — transactional M&A cleanup hotfix

- Added explicit idempotent `delete_once()` and fixed `replace_once()` so empty replacements can never falsely report `already applied`.
- This makes the R13 analyzer cleanup actually remove obsolete `finalAcquisitionLocked` state and its unreachable warning from Market UI.
- No gameplay/economy changes versus R13.

## V17 R13 — analyzer cleanup

- Fixed two `curly_braces_in_flow_control_structures` findings in legend requirement/hiring logic without changing behavior.
- Removed obsolete `finalAcquisitionLocked` state and unreachable warning from Market UI; M&A remains independent from campaign victory.
- R12 user-Mac verification reached `flutter analyze` after all focused regressions, migrations and V14 compatibility passed.

## V17 R12 — bootstrap hosting compatibility

- Restored the first `company_website` bootstrap footprint to 0.75 GB RAM and 8 GB storage baseline so `shared_launch` remains a viable first host.
- Kept V17 scale pressure intact: a 100k-user website still consumes >5 GB RAM and >100 GB storage.
- Added a focused regression for `productServerLoad <= 1.35` on the first basic website.
- This also prevents server-overload critical events from masking the existing mostly-repaid-loan grace flow.

## V17 R11 — self-contained narrow infrastructure selector
- Narrow Infrastructure `ChoiceChip` navigation now owns a transparent `Material` ancestor, so it renders safely even when `InfrastructureScreen` is embedded without its own Scaffold/Material.
- This closes the R10 widget crash `No Material widget found` for all five `infra-tab-*` controls.
- Desktop navigation and all V17 gameplay/economy behavior are unchanged.

## V17 R10 — navigation stability on narrow iPhone
- Infrastructure tab selector is fully visible below 620px using wrapping ChoiceChips; `Серверные`, `Серверы` and `Мощности` no longer sit outside the viewport.
- Product Workspace section controls now expose stable keys; rapid-switch regression targets actual controls instead of a mismatched text label.
- Existing V17 gameplay/economy contracts are unchanged.

## V17 R9 — UI stability: legacy monetization + narrow hosting
- Dropdown монетизации в Workspace и Product Detail устойчив к legacy/аномальному save, где текущая модель больше не входит в стратегию: текущая + разрешённые модели дедуплицируются через Set.
- Hosting plan cards больше не используют конфликтующие горизонтальные Rows на узком iPhone; provider/cost/action уложены вертикально.
- Добавлен Product Detail regression; старые narrow/runtime regressions не ослаблены.


## V17 R8 — Product Pressure widget compile hotfix
- Добавлен отсутствующий import `operations_models.dart` в V17 Product Pressure widget regression, чтобы extension `Employee.managedCopyWith` был доступен. Production-код не менялся.
# CHANGELOG

## v16 — Global company, people development and tax economy

- Added 12 strategic HQ locations with visible salary, tax, construction, utilities, talent, investor, market and network trade-offs; these are gameplay balance values, not legal or tax reference data.
- Added multiple owned offices with size, fit-out and equipment quality; office capacity and productivity are city-specific.
- Added multiple owned data centers with size, facility/equipment quality and site-specific rack, power, cooling and network limits.
- Servers now belong to a concrete rented room or owned data-center site.
- Added 365-day corporate-profit and payroll-tax settlement with a visible accrued reserve; HQ rent/utilities and regulatory OPEX now follow the selected gameplay location.
- Reworked employee development: 2–3 day courses, bulk selection/training, work-earned skill and automatic grade progression.
- Simplified explicit employee upgrades to one target-grade choice with calculated duration/cost.
- Added one-click bulk bug fixing as real queued technical work.
- Expanded onboarding/tutorial and product monetization guidance.
- Added immutable indexes for training, grade plans, server sites, competitor rankings and city capacity/occupancy/comfort to reduce repeated UI/simulation work.
- Snapshot schema advanced to v14 with controlled V15/v13 defaults.

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

## V16 — Global company, people development, taxes and performance
- Курсы сотрудников теперь занимают 2–3 игровых дня; сотрудник временно выпадает из активной разработки.
- Skill растёт от реальной работы над продуктами, а грейд автоматически следует за накопленным навыком.
- Добавлены массовый выбор сотрудников, «выбрать всех», групповые курсы и простой план повышения до выбранного грейда.
- Добавлена география компании: HQ выбирается при старте, а собственные офисы и ЦОД можно строить в нескольких городах мира.
- Город влияет на налоги, зарплаты, строительство, содержание, talent pool, инвесторов, market access, regulation и network.
- Добавлены собственные офисы/ЦОД с размером, качеством помещения/ремонта и оборудования; серверы устанавливаются на конкретную площадку.
- Добавлены ежегодный profit tax и payroll tax с отдельным накоплением и видимым резервом в финансах.
- Добавлено пакетное исправление всех открытых багов продукта одной технической задачей.
- Расширено обучение по монетизации: Free, Subscription, Usage based, Advertising и Transaction fee объясняются через бизнес-модель и риски.
- Добавлены immutable-state индексы для обучения, грейдов, серверных площадок и таблиц конкурентов, чтобы снизить повторные вычисления на UI rebuild.
- Snapshot schema поднята до v14 с обратной миграцией старых сохранений.

## V16 R2 — widget compile hotfix

- Добавлен явный import `models.dart` в Infrastructure для `ServerHardwareOption`.
- Добавлен import `v12_game_state_extensions.dart` в Team для `founderSalaryMultiplier`.
- V16 static audit закрепляет оба compile-контракта.


## V16 R3 — Team widget fixture hotfix

- Новый V16 Team widget regression теперь поднимает `TeamScreen` внутри `Scaffold`, как в реальном приложении, чтобы `TextField` имел Material ancestor.
- Проверка bulk development controls прокручивает `team-screen-list` до lazy-child вместо зависимости от искусственной высоты test viewport.
- Production Team/engine/economy из-за этого hotfix не изменялись.


## Unreleased — v16 R4 monetization regression hotfix

### Fixed

- legacy V14 workspace regression now scrolls the Monetization ListView until the V16 monetization controls are actually built;
- the large V16 monetization education guide remains before the controls in production UI and is no longer mistaken for a missing monetization surface by the legacy widget test.


## Unreleased — v16 R5 analyzer hotfix

### Fixed

- removed the unused `_firstValueBy` helper left behind after V16 server aggregation moved to `_sumValueBy`;
- migrated eight new Infrastructure `DropdownButtonFormField` instances from deprecated `value` to `initialValue`;
- added braces around V16 Infrastructure form callbacks required by the project lint set;
- removed an unused `models.dart` import from the V16 widget regression.

No gameplay, economy, persistence or UI behavior was changed by this verifier hotfix.

## Unreleased — V17 Product Pressure & Segmented Infrastructure

### Added
- Monetization now affects activation, retention, churn and brand trust; excessive pricing, ad load, paywall pressure and transaction fees create visible user-side trade-offs.
- Advertising channels are always-on monthly campaigns with proportional daily spend, monthly acquisition forecasts, a three-channel cap and explicit stop controls.
- Weekly deterministic churn shocks can remove users when bugs, staleness or aggressive monetization raise pressure.
- Product lifespan is extensible: features, technologies and post-release improvements increase the supported freshness window.
- Employee relocation from remote work to owned offices costs money, takes game days and reserves an office seat.
- Senior employees no longer use ordinary courses; target-grade promotion is longer, materially more expensive and raises several competencies on completion.
- Owned infrastructure supports explicit product service routing for API/app, data/storage and AI/compute.
- Newly purchased server pools are dedicated to a service; V16 hardware migrates as legacy/shared so old saves remain usable.
- Successful products now incur variable scale-operations costs based on MAU and category, making late-game growth profitable but not free.
- Finance history supports finger scrubbing and the ledger retains more one-time and daily recurring expense explanations.
- Offices and data centers use stable numbered labels throughout infrastructure and assignment UI.

### Changed
- Organic product growth is approximately three times slower; sustained market success depends more heavily on product readiness, retention, marketing and portfolio depth.
- Initial product development is about 14% faster to reduce launch friction while long-term success is harder to maintain.
- Performance and algorithm improvements reduce compute, RAM and storage demand as well as improving product metrics.
- AI, cloud and high-usage products consume materially more RAM/storage; network is part of the bottleneck model.
- The monetization guide is collapsed by default and the old player-facing “Интенсивность монетизации” label is replaced with model-specific terms.
- Feature, technology and bug work now expose progress bars and remaining team-hours like other product improvements.
- Owned-office/DC cards were reflowed into stable metric rows for narrow iPhones instead of oversized wrapping chip clouds.

### Fixed
- Removed the dashboard's disposable `ActiveTabScope`/forced-key wrapper that could tear down an inherited scope while descendants were still dependent, covering the observed `_dependents.isEmpty` runtime assertion with a rapid-navigation regression.
- Detailed finance ledger entries now explain recurring infrastructure, advertising, scale operations and other operating cash movement instead of leaving large cash changes unexplained.
- Internally recorded hosting/migration/server/integration transactions are not duplicated by the generic action ledger recorder.

### Persistence
- Snapshot schema is v15. V16/v14 saves migrate with empty relocation/service-route state. Finite legacy week-long advertising campaigns are stopped on migration so they are not accidentally converted into recurring monthly spend.

## Unreleased — V17 R2 Endgame Ecosystem & Company Culture

### Added
- Paid, timed company R&D is required before post-release feature/technology implementation and is reusable across products.
- Six recurring employee-benefit programs create new cash sinks while improving loyalty, morale and productivity.
- Employee retention now reacts to overload, boredom, poor on-site conditions and benefits; low-loyalty employees can resign after a three-day counter-offer window.
- Five rare market legends have 100 work stats, exceptional compensation, strategic eligibility requirements and a random product-specific bonus.
- Company fans and brand reputation now grow from products, events and open-ecosystem choices and can fall after organizational failures.
- Rare paid industry events support up to three separately paid showcase slots and create product users plus company fans.
- A dedicated Events tab centralizes employee, legend, investor, tax, research, event and legacy notifications.
- Three massive world projects — AURA OS, OpenMind AI and Planet Compute Grid — replace the old released-product victory condition.
- AURA OS has a deep dedicated upgrade tree; OpenMind AI and Planet Compute have separate non-aging capability trees and massive persistent OPEX.
- Company doctrine, philanthropy, competitor comparison, Legacy Score and post-game paths extend late-game decisions beyond cash accumulation.

### Changed
- Campaign completion no longer depends on 12 releases, 70% of the product catalog or buying the last rival.
- M&A remains a strategic system in free play but cannot complete the campaign by itself.
- Finance cost structure includes employee perks and world-project OPEX.
- Snapshot schema is v16.


## Unreleased — V17 R3 audit-format hotfix
- Fixed false-negative V17 static audit after `dart format`: positive invariants now accept whitespace-only formatting changes.
- No production gameplay logic changed; event showcase still caps at three products and event completion still grants base fans plus user-derived fans.


## V17 R5 — widget compile import hotfix

- TeamScreen imports v16_models.dart so FacilityQuality resolves in the perks/relocation UI.
- V17 endgame widget regression imports v12_models.dart so FounderCompanyProfile.legacy() resolves.
- V17 audit locks both import contracts to prevent the same compile regression.


## V17 R6 — product-pressure fixture compile hotfix

- Replaced invalid `copyWith(usingOwnedInfrastructure: true)` in the V17 R1 service-routing regression with `selectedHostingPlanId: 'owned'`, matching the real computed `usingOwnedInfrastructure` contract.
- No production gameplay, balance, persistence or UI logic changed.


## V17 R7 — product pressure formula hotfix

- Fixed compute resource economics: performance/algorithm optimization now reduces product CPU/compute demand as well as RAM/storage.
- Raised the severe live churn ceiling from 38% to 65% so extreme price/paywall/advertising pressure remains distinguishable in simulation instead of flattening at the old cap.
- Kept the failing Product Pressure regressions intact; production formulas were corrected rather than weakening tests.

- V17 R9: legacy-safe monetization dropdown и narrow hosting-plan layout; UI regression gate усилен.

- V17 R11: narrow Infrastructure `ChoiceChip` selector is self-contained with a local transparent Material ancestor; R10 had a widget crash when rendered without an inherited Material.

## V17 R15 full-suite compatibility polish — 2026-08-10
- Вернул блок «Средние показатели» сразу под заголовок Team, чтобы ключевая сводка снова была видна без прокрутки и старые narrow-screen контракты сохранялись.
- Предрелизные продукты больше не получают live scale/server-overload часть security risk; инвесторы оценивают архитектурный риск до релиза, а runtime overload — только после выхода в live.
- Нижняя NavigationBar зафиксирована на 68 pt, чтобы все шесть пунктов оставались hit-testable на высоте 600 px.
- Добавлены ранние V17 regressions для investor counter-offer, Team averages и 800×600 dashboard navigation.

## V17 R16 full-suite navigation compatibility — 2026-08-10
- Исправлена последняя регрессия полного suite из R15: скрытая подпись невыбранной bottom-navigation вкладки больше не находится за hit-test viewport.
- Все шесть `NavigationDestination` теперь всегда показывают labels; существующая компактная высота 68 pt сохранена.
- Ранний V17 regression теперь нажимает сам текст вкладки, а не только иконку.

## V17 R17 verifier EOF cleanup — 2026-08-10
- R16 прошёл все static/EN/focused/legacy проверки, `flutter analyze`, полный `flutter test` 278/278, iOS Simulator Debug build и Android Debug APK.
- Финальный verifier остановился только на `git diff --check`: три markdown-файла имели лишнюю пустую строку в EOF.
- R17 нормализует EOF документации и добавляет static guard; production-код, gameplay и тестовые контракты R16 не меняются.

## V17 R15 — UAT: perks, R&D, world projects and product UX

- Employee perks are company-wide toggles with activation and monthly cost multiplied by current employee count; recurring cost changes automatically after hires/departures.
- Fans and brand reputation are compact icon metrics in the app header; the company name owns only remaining width and truncates with ellipsis.
- Completed world OS and global compute projects generate monthly revenue; custom world-project names persist in snapshots. Free AI remains intentionally non-commercial.
- Advertising monetization uses Russian metric labels and `%` display; controls are named `Количество рекламы` and `Навязчивость рекламы`.
- Company R&D is a dedicated screen with cost/duration visible before start. New products can select only researched technologies; GameEngine enforces the same rule.
- Product rename dialog no longer owns a manually disposed controller, preventing back-navigation crashes.
- Product workspace exposes `Удовлетворённость пользователей` 0–100 with an explainable composite of rating, retention, trust, activation and churn.

Verification: `tools/audit_v17_r15_uat_fixes.py`, focused R15 regression tests, V17 audits, localization audit, full Flutter tests/analyze and platform builds via the supplied verifier.

## R16 — Business simulation

- rebalance: существенно снижены цены employee perks после перехода на per-head модель;
- feat: R&D превращён в дерево зависимостей с растущими стоимостью и сроком;
- refactor: marketing → interest → start using → satisfaction/trust → retention/churn → monetization/referrals;
- fix: advertising campaigns больше не добавляют users/MAU/DAU напрямую;
- feat: кредит на запрашиваемую сумму с chance/rate от valuation и рисков;
- feat: стоимость локализации security incident показывается сразу;
- feat: финансовое уведомление при runway ≤2 месяцев.

## Unreleased — R2 Background Operations

- Added visible cold-start progress/tips and deterministic background catch-up.
- Added native critical-event notifications for iOS/Android.
- Reworked R&D feature gating and lazy rendering.
- Added top notification center/toasts, contract/development colors, read/delete/clear behavior.
- Rebalanced development staffing, language learning, HR retention, investor waiting, free-tier satisfaction and loan retry cooldown.
- Added service-level product hosting routes and expanded campaign budgets.
- Added reputation breakdown, concrete event dates and live roadmap impact.

## 2026-08-12 — Final stabilization before publisher freeze

- Notification tap now routes through the dedicated notification center instead of raw feature ListViews.
- Top notification backlog is no longer replayed sequentially; swipe-up dismisses a visible toast.
- R&D start actions no longer create redundant company notifications.
- Company Events/Legacy/World Projects are again presented together as a strategic section.
- Mandatory investors were removed from product development; funding remains an optional equity/cash tool.
- Owned DC capacity and hyperscale hardware were expanded for late game.
