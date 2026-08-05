# FOUNDER.OS

Портретный offline-first симулятор технологической компании на Flutter.

## Текущий вертикальный срез

List-first company simulation с продуктами, сотрудниками, офисами, серверными, инфраструктурой, рынком, экосистемой, инвесторами, M&A, атаками и новостями.

Operations/security v4 добавил проектные команды, управление сотрудниками, security controls, аудиты, конкурентную разведку и P&L.

Guidance/AI/product evolution v5 добавил:

- первое обучение из пяти шагов и повторный запуск из меню;
- конкретные `i`-подсказки;
- средние показатели команды;
- обязательные специальности и покрытие ролей продукта;
- публичный и корпоративный режим собственной AI;
- AI development/quality boost, compute-нагрузку и OPEX;
- product freshness и постепенное устаревание;
- повторяемые улучшения скорости, алгоритмов, дизайна, безопасности и надёжности.

Business loop and UX fixes v6 добавляет:

- старт разработки нового продукта с `0%`;
- пакетное назначение всей проектной команды;
- корректный учёт office/remote сотрудников;
- блокировку continuous improvements до релиза;
- клиентские контракты с авансом, сроком, ролями, прогрессом, выплатой и штрафом;
- регулировку цены подписки у live-продукта с влиянием на рынок и выручку;
- краткую сводку по проектам на главном экране;
- только реальные контекстные подсказки без универсальных заглушек;
- snapshot schema v6 и миграцию v5 → v6.

## Локальная проверка

```bash
flutter pub get
dart format lib test
flutter analyze
flutter test --reporter expanded
git diff --check
flutter build ios --simulator --debug
flutter build apk --debug
```

## Проверка на физическом iPhone

```bash
flutter devices
flutter run --profile -d <DEVICE_ID>
```

## Документация

- `docs/PRODUCT_SPEC.md`
- `docs/TECHNICAL_PLAN.md`
- `docs/IMPLEMENTATION_STATUS.md`
- `docs/NEXT_STEP_V6.md`
- `docs/TEST_PLAN.md`
