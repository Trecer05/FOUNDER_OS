## V17 R14

- R12/R13 functional gates on the developer Mac were green through V17, V16, V15, migrations and V14; R12 reached `flutter analyze`.
- R13 analyzer cleanup was blocked before tests by a mutation-helper bug that falsely treated empty replacements as already applied.
- R14 fixes that transactional deletion bug and awaits the full verifier from the static gate onward.

## V17 R13

- Implemented analyzer-only cleanup after R12 passed V17/V16/V15, snapshot migrations and V14 regressions on the user Mac.
- Fixed 2 control-flow lints and removed 1 dead-code M&A branch.
- Awaiting full R13 verifier from `flutter analyze` onward, then full suite and platform builds.

## V17 R12

- Fixed the V15 compatibility regression found after all V17/V16 suites passed: the first basic website on `shared_launch` had load 2.0 because V17 raised zero-user RAM/storage baselines too far.
- New bootstrap baselines: website RAM 0.75 GB, storage 8 GB. Expected initial load is about 1.33 (contract <=1.35).
- Scaled website pressure remains material (>5 GB RAM and >100 GB storage at 100k users).
- Added an early V17 domain regression so this starter-hosting contract fails before the later V15 compatibility stage.
- Awaiting full R12 verifier on the user Mac.

## V17 R11
- R10 reached the final Product Pressure widget suite; Endgame domain 18/18, Endgame widgets 7/7, Product Pressure domain 16/16 and rapid workspace switching are green.
- Remaining R10 blocker was a `No Material widget found` crash in the new narrow Infrastructure ChoiceChip selector. R11 fixes the production component with a local transparent Material ancestor.
- Full verifier on Mac still required.

## V17 R10
- Narrow Infrastructure navigation: implemented; pending full verifier on Mac.
- Product Workspace rapid section switching: stable keyed targets implemented; pending full verifier on Mac.

## v17 R9 UI stability
R8 дошёл до Product Pressure widget suite. Endgame domain 18/18, Endgame widgets 7/7 и Product Pressure domain 16/16 уже зелёные. R9 исправляет два production UI-дефекта: legacy-safe monetization dropdown и narrow hosting-plan layout. Полный verifier на Mac ещё требуется.


## v17 R8 Product Pressure widget compile hotfix
R7 прошёл Endgame domain 18/18, Endgame widgets 7/7 и Product Pressure domain 16/16. Следующий blocker — отсутствующий import extension `Employee.managedCopyWith` только в widget-test. R8 исправляет import без изменений production-механик. Полный verifier ещё требуется на Mac разработчика.
# IMPLEMENTATION STATUS

## v16 package status — Global Company

Implemented in the V16 package:

- timed 2–3 day courses, bulk training, work-earned skill and automatic grade progression;
- simple target-grade employee upgrade plans;
- 12-city HQ selection with strategic economic factors;
- multiple owned offices and data centers with quality/size choices;
- city-specific office capacity, hiring economics and on-site productivity;
- site-specific physical server installation;
- annual corporate-profit and payroll taxes with visible reserve plus city-dependent HQ/regulatory recurring OPEX;
- bulk bug-fix queue;
- expanded monetization/tutorial education;
- snapshot v14 migration defaults;
- GameStateIndex caches for training/grade/server/ranking and city capacity/occupancy/comfort hot-path lookups.

Package-environment validation: static V16 audit, localization inventory, Python/shell syntax, Dart delimiter scan, manifest and archive integrity. Full Flutter tests/analyze/platform builds are executed transactionally by the installer on the developer Mac.

## v15 package status — long-term competition and recovery

Implemented:

- snapshot schema v13 with product release time and weighted bug persistence;
- rotating weekly bankruptcy recovery;
- lower player attack frequency and rival cyber incidents;
- 20 competitors per category and a unified ranking;
- post-release features, stack expansion, bug fixing and product renaming;
- model-specific monetization surface;
- CPU/RAM/storage infrastructure economics and compact responsive summary;
- employee filters, courses, promotions and dismissal;
- grade-based Product Manager bonus;
- on-site-only office productivity tiers and a visible crunch/recovery cycle;
- paid-acquisition rebalance and irreversible product aging;
- Dart/HSM compatibility;
- deterministic second-product release capacity reservation;
- focused v15 domain and recovery tests plus full English-locale coverage.

Archive-environment checks completed:

- release-content audit — passed;
- full English-locale audit — passed;
- Dart delimiter scan — passed.

The atomic macOS installer runs formatting, focused v15 regressions, `flutter analyze`, the complete Flutter test suite, iOS Simulator and Android debug builds, and `git diff --check`. It restores every touched file if any gate fails.

## Current baseline before V16

**FOUNDER.OS V15 — commit `6a4fc6d` on `main`**

V15 is the verified base for this transactional V16 package: 207/207 Flutter tests, clean analyzer, iOS Simulator Debug build, Android Debug APK and release audits passed before V16 work started.

### Verified

- `flutter analyze` — clean;
- focused v12.2 domain tests — passed;
- focused v12.2 widget tests — passed;
- v12 and v12.1 regression suites — passed;
- snapshot and migration regressions — passed;
- all domain tests — passed;
- all application and presentation tests — passed;
- full Flutter test suite — passed;
- `git diff --check` — passed;
- iOS Simulator debug build — passed;
- Android debug build — passed;
- Android release APK — built;
- Android release AAB — built;
- unsigned iOS release package for device-side signing — built.

## Main systems

### Company and founder

- company setup with name, budget and logo;
- configurable founder background and skills;
- founder contribution to product development;
- remote-first company start;
- clean new-company reset.

### Product development

- multi-step product configuration;
- four player-facing development stages;
- framework, language and technology constraints;
- deterministic development content;
- project-wide technical challenge;
- post-release product improvements;
- released-product stage cleanup.

### Team

- hiring and role requirements;
- HR-assisted automatic hiring;
- founder shown as a non-payroll project participant;
- multi-project employee assignments;
- deterministic workload efficiency for parallel work;
- product and contract staffing coverage.

### Contracts

- client contract acceptance and deadlines;
- team sufficiency indicators;
- automatic assignment of suitable low-load employees;
- progress, payouts and failure conditions;
- parallel contract capacity sharing.

### Business simulation

- monetization and pricing;
- advertising campaigns;
- finance ledger and history;
- office and infrastructure management;
- hosting and server capacity;
- credit and negative-cash recovery;
- ecosystem integrations;
- product freshness and continuous improvements;
- company ownership and investment mechanics.

### Platform and persistence

- offline-first operation;
- versioned local snapshots;
- controlled migration of older saves;
- serialized persistence writes;
- iOS and Android platform bridges for critical local persistence operations;
- RU/EN interface.

## Remaining validation

Before external distribution, complete physical-device UAT on representative iPhone and Android devices, with focus on:

- clean install and onboarding;
- product creation and release;
- project challenges;
- hiring and parallel staffing;
- contracts;
- infrastructure and finance;
- save/restore after force quit and reboot;
- RU/EN switching;
- long-session performance and thermal behavior;
- narrow-screen layout and safe-area behavior.

## Verification command

```bash
bash tools/verify_v12_2_pre_testflight.sh
```

## v13 release-candidate hotfix

Implemented after the full v13 regression log:

- removed the duplicate finance-ledger entry for a client-contract advance;
- made generated candidate cards addressable by stable widget keys;
- collapsed the long post-release feature roadmap so monetization, pricing and advertising remain reachable without scrolling through every feature card;
- hardened the hiring and subscription-price widget scenarios against lazy list construction;
- changed the v13 verifier to run every gate and write a short stage-by-stage summary instead of stopping at the first failure.

Verified in the archive environment:

- v13 static release audit — passed;
- v12.3 compatibility audit — passed;
- verifier shell syntax — passed;
- archive integrity and overlay structure — pending final package check.

Requires the local Mac gate because this archive environment has no Flutter SDK:

```bash
bash tools/verify_v13_release_candidate.sh
```

## v14 publisher-UAT polish

Implemented from physical-device publisher UAT:

- closed remaining English-locale leaks from data-driven fragments and locale-aware compact-number suffixes;
- moved owned-server migration to the compute-allocation tab;
- made HR grade constrain automatic hires, reused existing staff first and added deterministic sourcing for the final missing role;
- stopped inactive product assignments from reducing parallel efficiency;
- added visible employee productivity percentages with concrete positive and negative factors;
- made every credit tap show an immediate approval/refusal result;
- restored monetization and subscription-price editing in the product workspace;
- removed the duplicate advertising-channel dropdown;
- added three high-density late-game server tiers with better cost per CU.

Archive verification must run formatting, the full English audit, focused v14 tests, static analysis, the complete Flutter suite, an iOS Simulator build and an Android debug build before the patch is accepted.


## v15 R3 verification hotfix

- V15 domain regressions: passed in user Mac verifier before this hotfix (15/15).
- Bankruptcy recovery regression: passed.
- Snapshot migration regressions: passed (26 tests).
- V14 workspace regressions: passed (4/4).
- Remaining blocker from that run was one `flutter analyze` lint in `founder_dashboard.dart`; R3 fixes it with explicit mounted guards and adds a static-audit invariant.
- Full analyzer, complete Flutter suite, iOS Simulator build, Android build and final diff check must still pass on the user Mac before V15 is considered verified.


## v15 R4 full-suite compatibility hotfix

After R3 reached the complete Flutter suite, four legacy regressions were isolated and fixed without removing V15 mechanics:

- failed manual-slot load now restarts the simulation ticker from `finally`;
- a basic `company_website` uses a lightweight RAM baseline so `shared_launch` does not trigger an unrelated critical overload at the default first-product allocation;
- market overload contribution to activation/retention/churn is capped at the same 135% critical-load boundary that stops the simulation, preserving product-quality ordering before the stop;
- the global date/weekday/time pill is rendered as one rich text block, preserving the larger V15 typography while satisfying the existing undecorated-text UX contract.

A focused `v15_full_suite_compatibility_test.dart` now runs before snapshot/workspace/full-suite gates and reproduces all four regressions. R4 still requires the local Mac verifier to complete the full Flutter suite, iOS Simulator build, Android build and final diff check before V15 is marked verified.

## V16 — Global Company & Economy
Статус пакета: реализовано, ожидает полного verifier на машине с Flutter/Xcode/Android SDK.

Реализовано:
- timed employee courses, passive skill growth and grade progression;
- bulk employee selection/training and target-grade upgrade;
- 12 world cities with strategic economic parameters;
- HQ selection during company setup;
- multiple owned offices and data centers with configurable size/quality;
- site-specific server placement/removal and aggregate owned capacity;
- annual corporate/payroll taxation with finance reserve UI;
- bulk product bug fixing;
- expanded monetization tutorial and in-workspace guide;
- snapshot v14 fields/migration defaults;
- additional GameState indexes for hot UI lookups.

Проверка перед применением:
- V16 static audit;
- full EN localization audit;
- V16 focused domain/widget regressions;
- V15 regressions and snapshot migrations;
- flutter analyze;
- complete flutter test suite;
- iOS Simulator debug build;
- Android debug APK;
- git diff --check.


## v16 R2 widget compile hotfix

Исправлены два compile-блокера первого R1-прогона: тип серверного железа теперь импортирован на Infrastructure screen, а Team screen подключает extension с founder salary multiplier. Domain V16 R1 до этого уже прошёл 14/14; полный verifier R2 всё ещё обязан пройти на Mac до статуса verified.


## v16 R3 Team widget fixture hotfix

R2 на пользовательском Mac подтвердил:
- V16 static audit — PASS (67 invariants);
- full English localization audit — PASS, 2760 targets, zero Cyrillic;
- V16 domain regressions — PASS (14/14);
- 3 из 4 V16 widget regressions — PASS.

Единственный blocker был в новом Team widget fixture: `TeamScreen` тестировался без родительского `Scaffold`, хотя production использует его как tab-body внутри Material hierarchy. R3 исправляет только fixture и lazy-scroll до bulk controls; production mechanics не изменялись. Полный verifier R3 всё ещё обязан пройти до статуса verified.


## v16 R4 verification hotfix

- V16 domain regressions passed on the user Mac: 14/14.
- V16 widget regressions passed: 4/4.
- V15 domain/compatibility regressions and snapshot migration regressions passed.
- Remaining R3 blocker was the legacy V14 workspace test expecting `workspace-monetization-controls` before the lazy ListView had built it; V16 intentionally inserted a large monetization education guide before those controls.
- R4 updates only the legacy regression to scroll to the controls. Production monetization, advertising, engine and economy logic are unchanged. Full analyzer, complete Flutter suite and platform builds still must pass on the user Mac before V16 is verified.


## v16 R5 analyzer hotfix

R4 user-Mac verification reached `flutter analyze` after all focused gates passed: V16 domain 14/14, V16 widgets 4/4, V15 compatibility, snapshot migrations and V14 workspace regressions. Analyzer reported 12 non-behavioral issues. R5 clears those issues by removing one dead index helper, replacing deprecated Infrastructure form-field `value` parameters with `initialValue`, bracing callbacks, and removing one unused test import. Full analyzer, complete Flutter suite and platform builds still must pass before V16 is verified.

## V17 — Product Pressure & Segmented Infrastructure

Статус пакета: **реализовано в R1, ожидает полного verifier на пользовательском Mac**.

Реализовано:
- collapsed monetization guide and model-specific controls;
- activation/retention/churn/trust response to monetization and price pressure;
- recurring monthly advertising with daily cash pressure, gradual users and stop action;
- ~3x slower organic acquisition plus weekly deterministic churn events;
- faster MVP development but stronger readiness/portfolio/scale pressure after release;
- variable MAU/category scale-operations OPEX;
- extensible product supported lifetime from features/stack/improvements;
- Senior-only grade progression path, longer/costlier Senior promotion and multi-skill gains;
- paid timed employee relocation to owned offices;
- per-product API/data/AI routing plus service-dedicated new server pools;
- higher RAM/storage pressure and network bottlenecking;
- performance/algorithm resource-demand reduction;
- numbered office/DC presentation and narrow-screen infrastructure reflow;
- feature/technology/bug progress bars;
- finance chart finger scrubbing and expanded categorized ledger;
- dashboard lifecycle simplification for the observed `_dependents.isEmpty` assertion;
- snapshot v15 migration including safe handling of legacy finite ad campaigns;
- focused V17 domain and widget/runtime regressions.

Проверка до выдачи архива в текущей среде:
- Python/shell syntax: PASS;
- V17 static invariant audit on simulated installed state: 96 invariants PASS;
- full English localization audit on simulated installed state: 2853 targets, 0 Cyrillic;
- localization-key duplicate audit: 2313 literal keys, 2313 unique, 0 duplicates;
- V17 focused coverage authored: 16 domain + 7 widget/runtime regressions;
- Dart structural delimiter scan: PASS;
- transactional mutation-anchor simulation: PASS;
- package manifest and ZIP integrity: checked before handoff.

Не может считаться `проверено` до выполнения на Mac:
- V17 focused Flutter tests;
- V16/V15/V14 regression gates;
- snapshot migration suite;
- `flutter analyze`;
- full `flutter test`;
- iOS Simulator Debug build;
- Android Debug build;
- manual iPhone/Simulator UAT for monetization, churn, recurring ads, service routing, finance scrub, relocation and rapid navigation.

## V16 R5 — VERIFIED on user Mac (2026-08-10)

- V16 static audit: PASS (76 invariants).
- Full English audit: PASS, 2760 targets, zero Cyrillic.
- V16 domain: 14/14 PASS.
- V16 widgets: 4/4 PASS.
- V15 compatibility and snapshot migrations: PASS.
- V14 workspace: 4/4 PASS.
- `flutter analyze`: No issues.
- Complete Flutter suite: 225/225 PASS.
- iOS Simulator Debug: PASS.
- Android Debug APK: PASS.
- `git diff --check`: PASS.

## V17 R2 — Endgame Ecosystem & Company Culture

Статус пакета: **реализовано в едином R2 поверх V16 R5; ожидает полного verifier и ручного UAT на Mac/iPhone**.

Реализовано:
- весь V17 R1 Product Pressure scope;
- paid/timed reusable R&D before feature/technology implementation;
- company perks and recurring employee-benefit OPEX;
- workload/office-condition/perk driven loyalty with voluntary departures and counter-offer;
- rare 100-stat market legends with requirements and product-specific boosts;
- company fans and brand reputation;
- rare paid industry events with max three separately paid product slots;
- dedicated company notifications/events tab;
- AURA OS, OpenMind AI and Planet Compute Grid world projects;
- deep per-project upgrade trees, including 12+ AURA OS capabilities;
- world-project billion-scale recurring OPEX;
- old 12-product/70%-catalog/last-rival victory gates removed;
- competitor comparison, company doctrine, philanthropy and Legacy Score;
- post-game path selection only after all three projects reach world status;
- snapshot v16 migration defaults;
- updated compatibility regressions for old feature implementation and V13 legacy victory rules.

Preflight in packaging environment:
- V17 R2 static audit on simulated installed V16 state: 121 invariants PASS;
- V17 R1 static audit: 96 invariants PASS;
- English localization: 3057 targets, 0 Cyrillic on simulated installed state;
- localization maps: 2414 exact/override keys, 2414 unique, 0 duplicates;
- V17 R2 focused coverage authored: 18 domain + 7 widget/runtime regressions;
- Python/shell syntax: PASS;
- Dart structural delimiter scan: 22 files PASS;
- single-line flow-control lint preflight on installed simulation: PASS.

До статуса `verified` обязательны user-Mac Flutter tests/analyzer/platform builds and manual UAT for R&D, retention/counter-offer, legends, events, notifications and the three world projects.


## V17 R3 — audit-format hotfix
Status: **package rebuilt; requires full verifier on Mac**. R2 reached V17 static audit after applying successfully, but two valid event invariants failed only because `dart format` changed whitespace. R3 makes positive static checks whitespace-insensitive without changing production behavior.


## v17 R5 widget compile import hotfix

- R4 domain regressions passed 18/18 before the widget compile gate.
- Fixed missing FacilityQuality and FounderCompanyProfile import visibility.
- Full verifier still required on the development Mac before V17 is considered verified.


## v17 R6 product-pressure fixture compile hotfix

R5 reached and passed V17 endgame domain 18/18 and widget 7/7 gates. The next R1 product-pressure test failed to compile because its fixture attempted to set computed getter `usingOwnedInfrastructure` through `copyWith`. R6 uses the actual `selectedHostingPlanId: 'owned'` state contract and adds static guards. Full verifier still required.


## v17 R7 product-pressure formula hotfix

R6 passed the complete new Endgame domain suite (18/18) and Endgame widget suite (7/7), then exposed two Product Pressure production mismatches: compute optimization did not reach CPU demand and the 38% churn cap flattened aggressive monetization. R7 fixes both formulas without weakening regressions. Full verifier still required on the developer Mac.

- V17 R9: legacy-safe monetization dropdown и narrow hosting-plan layout; UI regression gate усилен.

- V17 R11: narrow Infrastructure `ChoiceChip` selector is self-contained with a local transparent Material ancestor; R10 had a widget crash when rendered without an inherited Material.

## V17 R15 compatibility status — 2026-08-10
- Full suite R14 дошёл до 271+ тестов и выявил 4 legacy regressions: 2 Team visibility, investor counter-offer и 800×600 EN navigation.
- R15 исправляет их в production и переносит проверки в ранние V17 suites.
- Статус окончательной готовности: ожидает полного verifier R15 и ручного UAT.

## V17 R16 compatibility status — 2026-08-10
- R15: static/EN/V17/V16/V15/migrations/V14/analyze прошли; полный suite дошёл до 277 тестов и оставил один V12 EN navigation failure.
- R16 исправляет геометрию/видимость bottom-navigation labels и усиливает ранний regression.
- Статус окончательной готовности: ожидает полного verifier R16 и ручного UAT.

## V17 R17 verifier status — 2026-08-10
- R16 фактически прошёл 278/278 Flutter tests, `flutter analyze`, iOS Simulator Debug build и Android Debug APK; единственный blocker — trailing blank line в трёх markdown-доках на `git diff --check`.
- R17 меняет только EOF hygiene документации и verifier/audit labels; production gameplay R16 не изменён.
- Статус окончательной готовности: ожидает полного verifier R17 и ручного UAT.

## V17 R15 — UAT: perks, R&D, world projects and product UX

- Employee perks are company-wide toggles with activation and monthly cost multiplied by current employee count; recurring cost changes automatically after hires/departures.
- Fans and brand reputation are compact icon metrics in the app header; the company name owns only remaining width and truncates with ellipsis.
- Completed world OS and global compute projects generate monthly revenue; custom world-project names persist in snapshots. Free AI remains intentionally non-commercial.
- Advertising monetization uses Russian metric labels and `%` display; controls are named `Количество рекламы` and `Навязчивость рекламы`.
- Company R&D is a dedicated screen with cost/duration visible before start. New products can select only researched technologies; GameEngine enforces the same rule.
- Product rename dialog no longer owns a manually disposed controller, preventing back-navigation crashes.
- Product workspace exposes `Удовлетворённость пользователей` 0–100 with an explainable composite of rating, retention, trust, activation and churn.

Verification: `tools/audit_v17_r15_uat_fixes.py`, focused R15 regression tests, V17 audits, localization audit, full Flutter tests/analyze and platform builds via the supplied verifier.

## R16 — Business Simulation / R&D Tree

Статус: **частично — реализовано кодом, ожидает полный verifier и ручной Simulator UAT**.

Реализованы сниженные per-head perks, дерево R&D, причинная продуктовая воронка, реклама как acquisition interest, монетизация через paying conversion/ARPU, кредит с пользовательской суммой и вероятностью, стоимость локализации атаки в уведомлении, runway alert ≤2 мес.

## UAT Fix Pack R1 — 2026-08-11

Статус: реализуется и проверяется пакетом `CURRENT_UAT_FIXPACK_R1`; ручной UAT после автоматического verifier обязателен.

- R&D на узких iPhone использует вертикальную адаптивную карточку без trailing-overflow; технологии и функции открыты отдельными явно видимыми группами.
- Любой PopupRoute блокирует глобальную панель времени; технический вызов не позволяет нажимать элементы за модальным барьером.
- Стек и функции показывают `++`, `+`, `-` до релиза и в карточке продукта после релиза.
- Русские женские имена получают женскую форму склоняемой фамилии.
- Курсы сотрудников удалены из игрового цикла; новая прокачка запускается только через повышение грейда. Старые snapshot-поля обучения сохраняются для совместимости.
- Клиентский рынок генерирует детерминированные предложения на каждую игровую неделю; сложность и награда растут по числу завершённых контрактов.
- Бизнес-кредит можно закрыть досрочно с исключением ещё не заработанных процентов.
- Исследованные функции реально входят в roadmap; продуктовый fit определяет влияние функции на приток, retention и quality. Неподходящая функция не создаёт спрос сама по себе.
- Окно ручных сохранений адаптивно, скроллится и не должно переполняться на узком iPhone.

## UAT Fix Pack R1 Hotfix 4 — 2026-08-11

- Manual save dialog moved from intrinsic `AlertDialog` layout to bounded responsive `Dialog`; narrow iPhone save UI no longer uses `LayoutBuilder` under intrinsic measurement.
- Narrow R&D regression now traverses the lazy research list before asserting the feature group.
- Contract assignment regression now uses a two-role contract and verifies unrelated employees are filtered out.
- Full release verifier remains the release gate; manual Simulator UAT is still required.

## R2 — Background Operations & Product Depth (2026-08-12)

Статус: автоматическая проверка выполняется пакетом R2; ручной Simulator UAT обязателен перед release-ready/commit.

1. Функции первого релиза больше не выдаются бесплатно: выбранная функция должна быть завершена в R&D. Продукт может стартовать без функций.
2. R&D разделён на lazy tabs «Технологии» / «Функции продукта» с ListView.builder и RepaintBoundary.
3. Холодный старт сразу рисует FOUNDER.OS splash с логотипом, реальным progress state и советом; настройки и snapshot грузятся параллельно.
4. При background приложение сохраняет wall-clock. При возврате GameEngine детерминированно догоняет время до elapsed или critical event. Нативный слой прогнозирует ближайший critical event и ставит локальное уведомление.
5. Контракты — primary navigation. Уведомления — top bell; contract=blue, development/product=green.
6. Отказ по business-loan создаёт 7-дневный retry cooldown.
7. Сотрудник без языка проекта работает с 50% language contribution и детерминированно осваивает язык на реальной назначенной работе. Development UI выделяет frontend/backend/server setup/QA phases.
8. Notification center помечает прочитанными только реально построенные видимые карточки, поддерживает clear-all и swipe-left delete.
9. Development technical summary вынесен вверх. Завершение core development — одно notification при launch.
10. Staffing penalty смягчён: один недостающий специалист создаёт bottleneck, но не обрушает всю скорость.
11. Live product показывает acquisition/retention/quality impact текущих функций и improvements.
12. Industry events показывают конкретные игровые даты вместо «через N дней».
13. Overview показывает signed drivers репутации: trust, rating, team loyalty, ecosystem doctrine.
14. Новые уведомления 5 секунд показываются сверху, кликабельны и затем genie-like анимируются в центр уведомлений.
15. Campaign budget масштабируется до 100 млн ₽ и текущего cash, с крупными presets.
16. HR снижает departure probability, постепенно поддерживает loyalty/morale и может автоматически удержать сотрудника небольшим raise.
17. «Жёсткость paywall» → «Жёсткость платного доступа».
18. Free tier теперь положительно влияет на satisfaction/retention и снижает churn pressure.
19. Infrastructure routes разделены по API/storage/AI compute. Dedicated hosting задаётся на product+service, одновременно можно использовать несколько hosting plans и owned DC.
20. Продажа продукта не меняет identity/name остальных продуктов; добавлен regression.
21. Investor-gated продукт можно создать до инвестиций; capacity=0 до нужного количества agreements именно на этот product.

Snapshot schema остаётся 16: новые долговечные правила используют уже сохраняемые Employee.languageIds, FinanceTransaction и ProductServiceRoute.

## Final stabilization before publisher freeze — 2026-08-12

Status: реализовано в fixpack; перед commit требуется автоматический verifier и ручной UAT на устройстве.

- Notification tap/layout regression: исправлено.
- Toast backlog/rounded corners/swipe-up/research spam: исправлено.
- Events/Legacy/World Projects strategic section: восстановлено и переработано без переноса.
- Mandatory product investors: удалены; инвесторы остаются добровольным финансированием.
- Owned DC capacity + hyperscale server tiers: расширены.
- Spacing between Competitive Intelligence and Events: исправлено.
