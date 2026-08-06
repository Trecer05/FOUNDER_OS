# IMPLEMENTATION_STATUS

Дата: 5 августа 2026.

## База v3 — проверено

- [x] `flutter analyze` без ошибок;
- [x] полный `flutter test`;
- [x] iOS Simulator debug build;
- [x] ветка `feat/mvp-vertical-slice` отправлена на GitHub, commit `2d70d2d`.

## Operations/security v4 — проверено

- [x] 15 domain tests;
- [x] 4 snapshot/migration tests;
- [x] 3 widget tests;
- [x] полный набор: 22 tests passed;
- [x] `git diff --check`;
- [x] iOS Simulator debug build;
- [x] ручной запуск на физическом iPhone;
- [x] базовая оценка плавности и нагрева: критических проблем не обнаружено;
- [ ] Android debug build;
- [ ] длительная симуляция 30+ игровых дней.

## Guidance/AI/product evolution v5 — проверено пользователем на iPhone

- [x] onboarding и повторный запуск;
- [x] средние показатели команды;
- [x] role requirements и role coverage;
- [x] public/corporate AI и внутренние интеграции;
- [x] product freshness/staleness;
- [x] повторяемые continuous improvements;
- [x] snapshot schema v5 и controlled migrations;
- [x] полный локальный набор тестов проходил перед установкой;
- [x] физический iPhone: игра запускается и в целом работает плавно;
- [x] собран фактический UX/logic feedback для v6;
- [ ] Android debug build;
- [ ] длительный balance/performance run.

## Business loop and UX fixes v6 — реализовано в пакете

- [x] старт разработки с `0%`;
- [x] пакетное сохранение проектной команды;
- [x] отдельный учёт onsite/remote при найме и аренде офиса;
- [x] запрет continuous improvements до релиза;
- [x] пять клиентских контрактов;
- [x] аванс, финальная выплата, deadline и штраф;
- [x] required roles и разделение мощности параллельных контрактов;
- [x] регулировка subscription price;
- [x] проектная сводка на Overview;
- [x] удаление placeholder-подсказок;
- [x] snapshot schema v6 и миграция v5 → v6;
- [x] новые domain/snapshot/widget tests подготовлены;
- [x] документация обновлена.

## Требует проверки после применения v6

- [ ] `dart format lib test`;
- [ ] `flutter analyze`;
- [ ] точечные domain/snapshot/widget tests;
- [ ] полный `flutter test`;
- [ ] `git diff --check`;
- [ ] iOS Simulator debug build;
- [ ] profile-run на физическом iPhone;
- [ ] force quit / restore snapshot v6;
- [ ] ручная проверка контрактного дедлайна и нескольких контрактов;
- [ ] Android debug build.

V6 нельзя считать проверенной или готовой к merge до прохождения этих пунктов на локальной машине проекта.

## V7 — management refactor (ожидает локальной проверки)

- [x] Сериализованная очередь сохранений и lifecycle flush.
- [x] Глобальная панель времени на всех маршрутах.
- [x] Контракты с отдельными командами и детальной карточкой.
- [x] Единая сводка продуктов и контрактов.
- [x] Ограничение смены монетизации раз в 30 игровых дней.
- [x] Диапазонный прогноз дохода с явными допущениями.
- [x] Финансовая история, график, категории и ledger.
- [x] Role-specific подсказки и исправление overflow статистики команды.
- [ ] flutter analyze.
- [ ] полный flutter test.
- [ ] iOS Simulator build.
- [ ] ручная проверка на физическом iPhone.


## V8 — product development economy (реализовано в пакете, ожидает локального gate)

- [x] семишаговый мастер создания проекта;
- [x] 8 масштабов, включая сайт и city system;
- [x] 12 языков, 9 frameworks, 24 кандидата и кадровые language skills;
- [x] stack limits, required languages и investor gates;
- [x] рабочий календарь и реалистичные часы разработки;
- [x] фазы, critical/movable staff, under/overstaffing;
- [x] сайт с монетизацией только рекламой и contract gate;
- [x] feature work без прямой покупки;
- [x] стартовый cash 450 000 ₽;
- [x] liquidity/credit/game-over chain;
- [x] price/churn/revenue forecast и затухание sentiment;
- [x] агентства, каналы, CPM/CPC и trust-aware acquisition;
- [x] промокоды `FOUNDER-RICH` / `FOUNDER-BROKE`;
- [x] snapshot schema v8 и migration defaults;
- [x] focused v8 domain tests и обновлённые widget fixtures;
- [ ] `dart format lib test`;
- [ ] `flutter analyze`;
- [ ] точечные v8/domain/snapshot/widget tests;
- [ ] полный `flutter test`;
- [ ] `git diff --check`;
- [ ] iOS Simulator debug build;
- [ ] ручной smoke на iPhone;
- [ ] 90+ игровых дней balance-run;
- [ ] Android debug build.
<!-- FOUNDER_OS_V9 -->
## v9 status
Implemented in the v9 overlay package: floating time UI, dynamic stack resolver, staffing deficits, rental hosting and owned migration, payroll ledger, staged contracts, ecosystem rework, glossary, compact team metrics, snapshot migration, content catalog/validator, tests and verification gate. Local Flutter/Xcode results are recorded only after running `tools/verify_ui_content_v9.sh` on the target Mac.

<!-- V10_UAT_REWORK -->
## v10 UAT rework

Status: **implemented, verification pending**.

Automated verification command: `bash tools/verify_ux_economy_v10.sh`. Physical-iPhone UAT remains required before marking the iteration verified. Full historic RU/EN localization and a complete regional price audit remain partial.
