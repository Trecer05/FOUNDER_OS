# ARCHIVE_MANIFEST — business loop and UX fixes v6

Overlay-пакет для корня существующего Flutter-проекта `founder_os`, применяемый поверх ветки `feat/guidance-ai-evolution-v5`.

## Заменяет или добавляет

- `lib/` — домен, движок, persistence и UI;
- `test/` — domain, snapshot и widget tests;
- `docs/` — актуальная проектная документация;
- `tools/verify_business_v6.sh`;
- `README.md`;
- `pubspec.yaml`.

## Не изменяет

- `ios/`;
- `android/`;
- Bundle ID и applicationId;
- signing и provisioning;
- deployment targets;
- Xcode scheme/configuration.

## Главные новые файлы

- `lib/domain/entities/business_models.dart`;
- `lib/domain/catalog/contract_catalog.dart`;
- `lib/presentation/features/contracts/contracts_screen.dart`;
- `docs/NEXT_STEP_V6.md`;
- `tools/verify_business_v6.sh`.

## Ключевые изменения

- новый продукт начинает разработку с `0%`;
- выбор проектной команды применяется одной кнопкой после множественного выбора;
- remote-сотрудники не занимают офисные места;
- continuous improvements доступны только live-продукту;
- добавлены клиентские контракты, управление ценой подписки и проектная сводка;
- общие placeholder-подсказки удалены: `i` появляется только при наличии конкретного объяснения.

## Snapshot

- целевая версия: v6;
- v5 читается с пустым списком контрактов;
- v3/v4 продолжают проходить существующую controlled migration;
- неизвестная будущая версия завершается контролируемой ошибкой.
