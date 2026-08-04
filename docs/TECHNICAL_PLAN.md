# TECHNICAL_PLAN

## Архитектура

`View → GameAction → GameEngine.reduce → GameState → View`

- UI не меняет экономику напрямую.
- `GameEngine` — чистый детерминированный reducer.
- RNG хранит seed и counter.
- Симуляция использует дискретные game-minutes; 2x/4x увеличивают объём времени за тик.
- Каталоги вынесены в `GameCatalog`.
- Формулы конфигурации и последующих feature-upgrade продукта общие для UI и engine через `ProductEstimator`.
- Состояние сохраняется как JSON snapshot schema v3.

## Модули

- `domain/entities/models.dart` — сущности и метрики.
- `domain/entities/game_state.dart` — агрегированное состояние и вычисляемые показатели.
- `domain/catalog/game_catalog.dart` — контентные каталоги.
- `domain/simulation/product_estimator.dart` — прогноз стека.
- `domain/simulation/engine/game_engine.dart` — экономика, рынок, события и сделки.
- `application/controllers/game_controller.dart` — timer, dispatch, autosave.
- `persistence/storage` — snapshot v3 и legacy migration.
- `presentation/features` — независимые list/detail экраны.

## Рыночная формула

Для каждого пользовательского сегмента считаются weighted scores продукта и конкурента:

- speed;
- design;
- security;
- expected feature coverage;
- price.

Разница преобразуется логистической функцией в preference. Preference влияет на organic acquisition, CAC, paid conversion, activation, retention и churn. Marketing budget добавляет трафик, но не повышает product score.

## Инфраструктура

- физическое ограничение железа: rack, cooling, power;
- доступная сеть ограничена меньшим из room network и суммарной сети железа;
- compute распределяется процентами между продуктами;
- сумма распределения не может превышать 100%;
- load = product compute demand / allocated compute;
- critical overload ставит симуляцию на паузу;
- physical security серверной уменьшает ежедневную вероятность атаки.

## Следующие технические этапы

1. Прогнать analyze/tests/build на машине Сергея.
2. Исправить только подтверждённые ошибки компилятора или UI.
3. Проверить полный smoke flow в iOS Simulator.
4. Проверить Android debug build.
5. После стабилизации заменить alpha snapshot backend на атомарное файловое хранилище с recovery-копией.
6. Добавить data-driven баланс вместо расширения условий в engine.


## Входящие предложения инвесторов

Раз в семь игровых дней детерминированная проверка может создать входящее предложение. Вероятность зависит от quality, feature coverage, users и числа успешных продуктов. Thesis, readiness и risk tolerance остаются обязательными фильтрами.
