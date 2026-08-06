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

## Snapshot v4

Новые сериализуемые поля:

- `employeeAssignments`;
- `securityControls`;
- `securityAudits`.

Сохранения v3 читаются тем же decoder и получают пустые новые коллекции. Версии ниже v3 проходят через контролируемую legacy migration.

## Operations flow

`OperationsScreen → GameAction → GameEngine.reduce → GameState → UI`

Новые действия:

- `AssignEmployeeToProduct`;
- `FireEmployee`;
- `GiveEmployeeRaise`;
- `TrainEmployee`;
- `PurchaseSecurityControl`;
- `RunSecurityAudit`.

Производительность разработки рассчитывается `GameState.productDevelopmentCapacity(productId)` только по назначенным сотрудникам. Security risk и OPEX также вычисляются из state/catalog без UI-логики.

## Product evolution v5

### New domain data

- `ProductRoleRequirement` — role/minimum/reason;
- `ProductAiDeployment` — product/mode;
- `ProductAiIntegration` — AI provider/target/time;
- `ProductImprovementOption` — catalog effect/cost/OPEX;
- `ProductImprovementRecord` — product/type/level/time;
- `ProductUpdateRecord` — product/update time/reason.

### Flow

`View → GameAction → GameEngine.reduce → GameState → View`

New actions:

- `CompleteOnboarding`;
- `RestartOnboarding`;
- `SetAiDeploymentMode`;
- `ConnectCorporateAi`;
- `DisconnectCorporateAi`;
- `ApplyProductImprovement`.

Role coverage, AI boost, compute demand, freshness and improvement costs are selectors/getters on `GameState`; Views do not mutate gameplay fields directly.

### Determinism

Freshness is derived from `simulationMinutes` and persisted update records. AI and improvements contain no wall-clock dependency. The same snapshot, seed and action sequence produces the same state.

### Persistence

В рамках v5 целевой версией была `5`. Missing evolution collections decode as empty. Для v3/v4 decoder создаёт migration update records на сохранённом `simulationMinutes`. Unsupported future versions throw controlled `FormatException`.

### Performance

The new calculations are linear in product/employee/integration count and run inside the existing simulation tick. No network calls or dependencies are added. Profile-run on physical iPhone remains a release gate.

## Business loop and UX fixes v6

### Domain additions

- `ContractTemplate` — неизменяемые параметры заказа из каталога;
- `ClientContract` — versioned runtime state контракта;
- `ContractStatus` — `active`, `completed`, `failed`;
- `clientContracts` в `GameState`;
- selectors для active/completed contracts, role coverage и contract capacity.

### Actions

- `AcceptClientContract(templateId)`;
- `SetProductPrice(productId, price)`.

Все действия проходят через `GameEngine.reduce`. View не меняет cash, price, progress, assignment или contract status напрямую.

### Contract tick

`_simulateMinutes` обновляет simulation time и затем вызывает `_advanceClientContracts`.

- рабочее время ограничивается оставшимися минутами до deadline;
- role coverage и reserve team формируют effective capacity;
- effective capacity делится на число active contracts;
- completion и failure дают детерминированные cash operations и feed messages;
- wall-clock time не используется.

### Hiring and assignment

- `onSiteEmployeeCount` является единственным источником проверки office capacity;
- remote не входит в этот selector;
- assignment sheet хранит временный `Set<String>` и отправляет actions только после подтверждения.

### Pricing

`SetProductPrice` проверяет live stage и subscription model, затем clamp-ит значение относительно `basePrice`. Market scoring и revenue уже читают `Product.price`, поэтому отдельной UI-формулы нет.

### Persistence

`currentSnapshotVersion = 6`. Поле `clientContracts` отсутствует в v5 и декодируется как пустая коллекция. v3/v4 продолжают существующую migration цепочку. Unsupported future version завершается контролируемой ошибкой.

### Verification order

1. `dart format lib test`;
2. `flutter analyze`;
3. domain tests;
4. snapshot tests;
5. widget tests;
6. полный `flutter test`;
7. `git diff --check`;
8. iOS Simulator build;
9. profile-run и force quit/restore на iPhone;
10. Android debug build.

## Product development economy v8

### Data model

- `ProductStrategyProfile` — scope, hours, setup, team range, investor gate, stack limits and monetization;
- `LanguageStrategyProfile` / `FrameworkStrategyProfile` — explanation and complexity modifiers;
- `DevelopmentPhaseDefinition` / `DevelopmentStaffingSnapshot` — current phase and explainable staffing;
- `ProductFeatureDevelopment` — persisted feature work queue;
- `AdvertisingAgency`, `AdvertisingChannel`, `AdvertisingCampaign` — campaign economics;
- `ProductPriceChange` — persisted sentiment shock;
- `CompanyLoan` — principal, remaining debt and weekly schedule.

### Deterministic work calendar

`_workingHoursBetween(startMinutes, deltaMinutes)` is the shared resolver for product and contract work. It counts only Monday–Friday, 09:00–18:00. Progress is `productiveHours × effectiveFte / requiredHours`. No wall-clock dependency is used.

### Stack validation

UI and engine read the same `ProductStrategyCatalog`. The reducer revalidates framework allow-list, required languages, stack limits, investor count, features and monetization. `ProductEstimator` computes the same setup, hours, coherence and warnings shown before confirmation.

### Liquidity reducer

`_advanceLoanAndLiquidity(previous, next)` runs after cash accrual. It tracks `negativeCashSinceMinutes`, credit availability, repayment fraction, grace use and `CriticalEventType.insolvency`. Bank approval is derived from released economics, contracts, monthly burn and product security risk.

### Persistence

`currentSnapshotVersion = 8`. New lists and nullable fields decode with controlled defaults when reading v3–v7 snapshots. Snapshot tests cover campaigns, price changes, feature work, loan/liquidity state and existing v7 entities.
<!-- FOUNDER_OS_V9 -->
## v9 architecture
`View → GameAction → GameEngine.reduce → GameState → View` remains unchanged. `ProductConfigurationResolver` and `StaffingDeficitResolver` are pure deterministic explainability services. Snapshot version is 9; missing `selectedHostingPlanId` migrates to `shared_launch`. Expanded data lives in `assets/data/content_catalog_v9.json` and is validated by the verifier.
