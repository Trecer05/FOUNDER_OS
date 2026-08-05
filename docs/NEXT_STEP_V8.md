# NEXT_STEP_V8

## Локальный gate

1. `dart format lib test`
2. `flutter analyze`
3. `flutter test test/domain/product_economy_v8_test.dart --reporter expanded`
4. остальные domain/snapshot/widget tests
5. полный `flutter test --reporter expanded`
6. `git diff --check`
7. `flutter build ios --simulator --debug`
8. ручной smoke на физическом iPhone

## Обязательный smoke flow

1. Начать новую компанию и проверить 450 000 ₽.
2. Пройти семь шагов создания сайта, сравнить static/Laravel и выпустить сайт.
3. Убедиться, что контракты до релиза закрыты, а после доступны в карточке сайта.
4. Создать большой проект, назначить слишком мало, оптимум и слишком много сотрудников.
5. Проверить стадии и списки critical/movable staff.
6. Прокрутить двое игровых суток: большой проект не должен завершиться.
7. Поставить post-release функцию: cash не списывается разово, появляется очередь часов.
8. Изменить subscription price и сравнить forecast с фактическим результатом через 45 дней.
9. Запустить рекламу разными агентствами и каналами, сравнить CPM/CPC и диапазон.
10. Ввести `FOUNDER-BROKE`, прожить неделю, проверить банк, отказ/одобрение и game over rules.
11. Ввести `FOUNDER-RICH` для длинного тестового сценария.
12. Force quit / reopen: стадии, feature work, кампании, цена, loan и liquidity state сохранены.

## Не проверено в среде сборки пакета

- Flutter analyze/tests;
- iOS Simulator build;
- физический iPhone;
- Android build;
- balance-run 90+ игровых дней.
