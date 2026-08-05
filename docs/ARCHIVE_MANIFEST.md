# ARCHIVE_MANIFEST — product development economy v8

Overlay-пакет для существующего Flutter-проекта `founder_os`, применяемый поверх локальной management-refactor v7.

## Заменяет или добавляет

- `lib/` — домен, движок, persistence и UI;
- `test/` — domain, snapshot и widget tests;
- `docs/` — актуальная проектная документация;
- `tools/verify_product_economy_v8.sh`;
- `README.md`.

## Не изменяет

- `ios/` и `android/`;
- Bundle ID и applicationId;
- signing и provisioning;
- deployment targets;
- Xcode scheme/configuration;
- зависимости `pubspec.yaml`.

## Главные новые файлы

- `lib/domain/entities/product_strategy_models.dart`;
- `lib/domain/catalog/product_strategy_catalog.dart`;
- `test/domain/product_economy_v8_test.dart`;
- `docs/NEXT_STEP_V8.md`;
- `tools/verify_product_economy_v8.sh`.

## Ключевые изменения

- семишаговый мастер создания продукта;
- восемь масштабов, двенадцать языков и девять frameworks;
- language skills сотрудников и расширенный рынок из 24 кандидатов;
- рабочий календарь, стадии, under/overstaffing и кадровый баланс;
- функции через часы команды, без прямой покупки;
- стартовые 450 000 ₽, кредитная цепочка и контролируемое банкротство;
- сайт компании как gate клиентских контрактов;
- price/churn/revenue forecast и затухающий sentiment;
- агентства, каналы, CPM/CPC, trust и brand awareness;
- промокоды `FOUNDER-RICH` и `FOUNDER-BROKE`.

## Snapshot

- целевая версия: v8;
- отсутствующие v7/v6 поля получают безопасные defaults;
- ключ хранения переносится на `founder_os.snapshot.v8` с чтением legacy-ключей;
- неизвестная будущая версия завершается контролируемой ошибкой.

## Проверка

В среде подготовки пакета выполнены структурные проверки файлов, импортов, ID и синтаксического баланса скобок. Flutter SDK здесь отсутствует, поэтому `flutter analyze`, тесты и iOS build должны быть выполнены локальным verifier-скриптом до commit или merge.
