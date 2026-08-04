# FOUNDER.OS

Портретный offline-first симулятор технологической компании на Flutter.

## Текущий вертикальный срез

List-first company simulation с продуктами, сотрудниками, офисами, серверными, инфраструктурой, рынком, экосистемой, инвесторами, M&A, атаками и новостями.

Operations/security v4 добавил проектные команды, управление сотрудниками, security controls, аудиты, конкурентную разведку и P&L.

Guidance/AI/product evolution v5 добавляет:

- первое обучение из пяти шагов и повторный запуск из меню;
- круглую кнопку `i` на карточках и пояснения к метрикам;
- средние показатели всей команды во вкладке сотрудников;
- обязательные специальности и покрытие ролей для каждого продукта;
- публичный и корпоративный режим собственного AI-продукта;
- подключение корпоративной AI к другим продуктам;
- ускорение разработки, бонус качества, compute-нагрузку и OPEX от AI;
- устаревание продукта без обновлений;
- всегда доступные повторяемые улучшения скорости, алгоритмов, дизайна, безопасности и надёжности;
- snapshot schema v5 и миграцию v3/v4 без мгновенного штрафа за устаревание.

## Локальная проверка

```bash
flutter pub get
dart format lib test
flutter analyze
flutter test --reporter expanded
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
- `docs/NEXT_STEP_V5.md`
- `docs/TEST_PLAN.md`
