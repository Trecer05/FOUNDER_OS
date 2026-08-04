# IMPLEMENTATION_STATUS

Дата: 4 августа 2026.

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
