# IMPLEMENTATION_STATUS

Дата: 4 августа 2026.

## База v3 — проверено

- [x] `flutter analyze` без ошибок;
- [x] полный `flutter test`;
- [x] iOS Simulator debug build;
- [x] ветка `feat/mvp-vertical-slice` отправлена на GitHub, commit `2d70d2d`.

## Operations/security v4 — проверено до подготовки v5

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

## Guidance/AI/product evolution v5 — реализовано в пакете

- [x] onboarding из пяти шагов и повторный запуск;
- [x] поясняющие `i`-кнопки на карточках и метриках;
- [x] средние показатели команды;
- [x] category-specific product role requirements;
- [x] role coverage и причины нехватки специалистов;
- [x] public/corporate AI deployment modes;
- [x] подключение корпоративной AI к продуктам;
- [x] AI development/quality boost, compute demand и OPEX;
- [x] product freshness/staleness;
- [x] повторяемые continuous improvements с растущей стоимостью;
- [x] snapshot schema v5;
- [x] controlled migration v3/v4;
- [x] domain/widget tests подготовлены;
- [x] документация обновлена.

## Требует проверки после применения v5

- [ ] `dart format lib test`;
- [ ] `flutter analyze`;
- [ ] точечные evolution/AI/migration tests;
- [ ] полный `flutter test`;
- [ ] iOS Simulator build;
- [ ] profile-сборка на физическом iPhone;
- [ ] force quit / restore после миграции v4 → v5;
- [ ] визуальная проверка подсказок и карточек на 430×932;
- [ ] Android debug build;
- [ ] длительная симуляция устаревания и обновлений.

V5 нельзя считать проверенной до прохождения этих пунктов на локальной машине проекта.
