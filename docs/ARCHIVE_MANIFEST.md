# ARCHIVE_MANIFEST — guidance/AI/product evolution v5

Overlay-пакет для корня существующего Flutter-проекта `founder_os`, применяемый поверх operations/security v4.

## Заменяет/добавляет

- `lib/` — домен, движок, persistence и UI;
- `test/` — domain/snapshot/widget tests;
- `docs/` — проектная документация;
- `tools/verify_product_evolution_v5.sh`;
- `README.md`;
- `pubspec.yaml`.

## Не изменяет

- `ios/`;
- `android/`;
- Bundle ID;
- applicationId;
- signing;
- deployment targets;
- Xcode scheme/configuration.

## Главные новые файлы

- `lib/domain/entities/product_evolution_models.dart`;
- `lib/domain/catalog/product_evolution_catalog.dart`;
- `lib/presentation/features/tutorial/founder_tutorial_dialog.dart`;
- `lib/presentation/shared/widgets/info_hint_button.dart`;
- `docs/NEXT_STEP_V5.md`.

## Snapshot

- целевая версия: v5;
- v3/v4 читаются контролируемо;
- существующие продукты при миграции получают update marker на текущее игровое время, чтобы не стартовать сразу устаревшими.
