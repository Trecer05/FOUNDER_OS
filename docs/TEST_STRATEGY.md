# FOUNDER.OS — CURRENT TEST STRATEGY

## Цель

Заменить исторический набор тестов, организованный вокруг номеров патчей, на один version-neutral suite, который описывает текущие бизнес-контракты игры.

## Принцип

Имя теста отвечает на вопрос **«какое правило игры мы защищаем?»**, а не «в какой версии его добавили?».

Запрещённые паттерны для новых test filenames:
- `v8`, `v10`, `v11`, ...;
- `hotfix`;
- `stabilization`;
- `optimization`;
- `release_candidate`.

## Структура

```text
test/
  support/
    fixtures.dart
    fakes.dart
    widget_harness.dart

  domain/
    simulation_contract_test.dart
    company_people_test.dart
    product_lifecycle_test.dart
    product_market_test.dart
    infrastructure_security_test.dart
    finance_ownership_test.dart
    contracts_ecosystem_test.dart
    research_endgame_test.dart
    geography_content_test.dart
    persistence_schema_test.dart

  application/
    controller_persistence_test.dart
    snapshot_storage_test.dart
    settings_native_test.dart

  presentation/
    app_shell_test.dart
    product_team_flow_test.dart
    business_surfaces_test.dart
    responsive_localization_test.dart
```

## Coverage contract

Domain tests обязаны защищать:
- детерминизм;
- time/pause;
- product lifecycle;
- research gates;
- causal funnel;
- monetization trade-offs;
- team capacity/training/relocation;
- infra resources;
- security;
- finance/loans/ownership;
- contracts/ecosystem;
- world projects/endgame;
- snapshot migrations.

Application tests:
- save ordering/coalescing;
- manual slots;
- fallback repair;
- bankruptcy checkpoints;
- display settings;
- native bridge degradation.

Widget tests:
- основная навигация;
- product wizard;
- R&D;
- monetization;
- credit dialog;
- contracts;
- team;
- responsive/narrow layouts;
- no lifecycle exceptions.

## Release gate

```bash
bash tools/verify_current_release.sh
```

Порядок:
1. current audit;
2. format;
3. analyzer;
4. domain;
5. application;
6. presentation;
7. English locale audit;
8. full suite;
9. diff check;
10. iOS build;
11. Android build when SDK exists.

## Migration policy

Удаление legacy test suite допустимо только вместе с:
- backup;
- новым current suite;
- current audit;
- master spec.

Если новый тест выявляет несовпадение production и спецификации:
- не ослаблять ожидание автоматически;
- определить, устарел ли spec/test или production;
- исправить источник проблемы;
- повторить весь release gate.


## Текущий размер canonical suite

- Domain: **99** test declarations.
- Application: **17**.
- Presentation: **15**.
- Итого: **131**.

Это не целевой максимум. При добавлении новой системы тест добавляется в соответствующий системный файл либо создаётся новый system-oriented файл без номера версии.
