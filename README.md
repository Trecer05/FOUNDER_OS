# FOUNDER.OS

Портретный offline-first симулятор технологической компании на Flutter.

## Product development economy v8

V8 перестраивает основной цикл вокруг реальной разработки, команды и ликвидности:

- семишаговый мастер проекта: масштаб → framework → языки → технологии → функции → монетизация → итоговая проверка;
- восемь типов продукта — от сайта компании до цифровой системы города;
- двенадцать языков, девять frameworks и кандидаты с конкретными технологическими навыками;
- обязательные языки framework, ограничения сложности стека и штрафы за бессмысленную комбинацию всего сразу;
- разработка по рабочему календарю с шестью подписанными стадиями;
- under/overstaffing, покрытие ролей и языков, critical/movable сотрудники;
- функции добавляют рабочие часы, а не списывают абстрактную стоимость;
- стартовый капитал 450 000 ₽ и управляемая цепочка отрицательного баланса, кредита и банкротства;
- контракты открываются после релиза сайта компании;
- прогноз влияния цены на пользователей, churn и выручку, ценовой sentiment затухает за 45 игровых дней;
- рекламные агентства и каналы с CPM/CPC, диапазоном результата, brand awareness и trust;
- snapshot schema v8 с миграционными defaults для старых сохранений;
- тестовые промокоды:
  - `FOUNDER-RICH` — добавить 5 000 000 ₽;
  - `FOUNDER-BROKE` — установить баланс −500 000 ₽ и запустить кризисный сценарий.

## Архитектура

Поток изменений остаётся однонаправленным:

```text
View → GameAction → GameEngine.reduce → GameState → View
```

- `GameEngine` рассчитывает время, разработку, рынок, рекламу, кредиты и события;
- `GameState` хранит полное детерминированное состояние и сериализуется в versioned snapshot;
- `GameController` управляет clock, lifecycle и последовательным autosave;
- интерфейс не меняет игровые показатели напрямую.

## Полный локальный gate

```bash
bash tools/verify_product_economy_v8.sh
```

Скрипт выполняет:

```bash
flutter pub get
dart format lib test
flutter analyze
flutter test test/domain/product_economy_v8_test.dart --reporter expanded
flutter test --reporter expanded
git diff --check
flutter build ios --simulator --debug
```

## Проверка на физическом iPhone

```bash
flutter devices
flutter run --profile -d <DEVICE_ID>
```

Обязательный сценарий описан в `docs/NEXT_STEP_V8.md`.

## Документация

- `docs/PRODUCT_SPEC.md`
- `docs/TECHNICAL_PLAN.md`
- `docs/DECISIONS.md`
- `docs/IMPLEMENTATION_STATUS.md`
- `docs/NEXT_STEP_V8.md`
- `docs/TEST_PLAN.md`
<!-- FOUNDER_OS_V9 -->
## FOUNDER.OS v9 — UI, Infrastructure, Explainability & Content Expansion

Version 9 moves global time controls into a safe-area-aware floating glass overlay, introduces rented hosting and v8→v9 snapshots, dynamic technology limits, deterministic staffing deficits, staged contract payments, payroll ledger entries, a permanent glossary, compact team metrics, redesigned ecosystem integrations and a validated **8.53×** data catalog.

Verification: `bash tools/verify_ui_content_v9.sh`.

<!-- V10_UAT_REWORK -->
## v10 UAT rework

Product workspaces, explainable language/stack limits, multi-project staffing, HR auto-hire, visible finance/time, investor negotiations, discoverable credit, time-based improvements, contract grace periods, display currency, and v10 snapshot migration are documented in `docs/V10_UAT_REWORK.md`. Run `bash tools/verify_ux_economy_v10.sh` before commit.

<!-- V10_OPTIMIZATION -->
## v10_optimization

Native atomic snapshot I/O, coalesced saves, projection/index caches, localized rebuilds, RU/EN presentation audit and dual-platform verification are documented in `docs/V10_OPTIMIZATION.md`. Run `bash tools/verify_v10_optimization.sh`.
