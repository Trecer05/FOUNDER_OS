# TEST_PLAN

## Automated

### Engine

- same seed + actions → identical snapshot;
- office capacity blocks extra hire;
- one product connects to multiple products;
- reverse ecosystem duplicate is rejected;
- investor request above capital produces a smaller counteroffer;
- accepting dilution below 50% loses control immediately;
- compute allocation cannot exceed 100%;
- server installation respects rack/power/cooling;
- product migration is blocked without spare compute and succeeds after expansion;
- crypto-wallet breach kills the product;
- product roadmap adds a feature, charges exact cost and increases expected coverage;
- stronger feature coverage improves activation/retention despite competitor advertising.

### Persistence

- v3 round trip preserves products, people and links;
- v2 legacy snapshot migrates to v3;
- future unsupported version throws controlled `FormatException`.

### Widget

- user opens product list, configures and creates a product;
- team screen exposes filters and numeric candidate metrics.

## Manual iOS smoke test

1. Open Products and create AI product with chosen stack/features.
2. Verify all product metrics are absent from Overview and present in product detail.
3. Add a roadmap feature and verify cash, coverage, technical effects and post-release 25% markup.
4. Hire three employees; fourth is blocked in Garage.
5. Rent Coworking and hire another employee.
6. Open Infrastructure and verify office/server-room/hardware are separate tabs.
7. Install hardware; observe exact rack/power/cooling usage.
8. Create Cloud and SaaS; connect AI to both; reverse duplicate must be unavailable.
9. Set compute percentages and verify total cannot exceed 100%.
10. Request 1,000,000 ₽ from Aurora; expected maximum counteroffer is 500,000 ₽.
11. Accept an offer; verify founder ownership and monthly investor payout.
12. Buy an external 5% stake.
13. Attempt product migration without capacity; expand infrastructure and repeat.
14. Trigger red-team incident on ordinary product and crypto wallet.
15. Close and reopen app; verify snapshot restoration.

## Build gates

```bash
flutter analyze
flutter test --reporter expanded
flutter build ios --simulator --debug
flutter build apk --debug
```

## Operations/security v4

### Unit

- назначение сотрудника эксклюзивно и переносит его между продуктами;
- product development capacity меняется только от назначенной команды;
- обучение меняет строго заданные показатели и списывает точную сумму;
- повышение зарплаты меняет payroll и morale/loyalty;
- security controls не дублируются и снижают incident multiplier;
- security audit сохраняет risk/findings;
- snapshot v4 сохраняет assignments/controls/audits;
- v3 snapshot мигрирует без удаления старого состояния.

### Widget

- открытие конструктора продукта и создание продукта;
- фильтр рынка кандидатов;
- назначение сотрудника из Operations screen;
- отсутствие RenderFlex overflow на размере 430×932.

### Manual

- создать два продукта и убедиться, что один сотрудник не числится в обоих;
- сравнить скорость прогресса с командой и без команды;
- внедрить два security control и проверить OPEX/P&L;
- провести аудит до/после контролей;
- force quit и восстановить назначения и аудиты;
- выдержать 30 игровых дней и проверить атаки, cashflow и стабильность.

## Guidance/AI/product evolution v5

### Domain

- role requirements are deterministic for each category;
- role coverage changes only from employees assigned to that product;
- founder-only development remains above zero;
- corporate AI raises target development capacity and quality;
- corporate AI adds monthly OPEX and provider compute demand;
- switching AI to corporate resets public marketing budget;
- switching AI back to public removes internal integrations;
- one target cannot keep two AI integrations;
- freshness falls after the grace period;
- staleness reduces market outcome and raises churn;
- repeatable improvement restores freshness and increases next cost;
- improvement effects and OPEX use catalog values.

### Persistence

- v5 round trip preserves deployments, integrations, improvements, updates and onboarding;
- v4 migration preserves products and marks them fresh at migration time;
- v3 migration adds v5 defaults;
- future version remains a controlled error.

### Widget

- tutorial is displayed on first launch and can be skipped/completed;
- team screen exposes average metrics;
- product builder/detail shows role requirements;
- info buttons open dialogs without triggering parent card actions;
- no overflow at 430×932 with default text scale;
- product detail exposes AI mode and continuous improvements.

### Manual physical iPhone

1. Start from v4 save and confirm tutorial appears once.
2. Force quit/reopen; tutorial must not repeat after completion.
3. Open Team and verify average metrics and scrolling.
4. Create two product categories and compare role requirements.
5. Build/release AI, set marketing, switch corporate; marketing must become 0.
6. Connect AI to two products; verify OPEX and provider compute load.
7. Switch AI public; integrations must disappear.
8. Advance 50+ days without updates and observe freshness/user decline.
9. Apply performance/algorithm updates and verify freshness returns to 100.
10. Repeat an update and verify rising price.
11. Run 10–15 minutes at 4x in profile mode; note frame drops, heat and battery.
12. Force quit and verify AI links/improvements/freshness restore.

## Business loop and UX fixes v6

### Domain

- новый продукт имеет `developmentProgress == 0`;
- полный onsite-офис блокирует только onsite-кандидата;
- remote-кандидат нанимается при заполненном офисе;
- меньший офис сравнивается с onsite count;
- continuous improvement до релиза не меняет cash или level;
- после релиза improvement применяется;
- price до релиза не меняется;
- live subscription price меняется и clamp-ится в допустимый диапазон;
- контракт платит точный аванс;
- контракт завершается и платит остаток при достаточной мощности;
- контракт проваливается после deadline при недостаточной мощности;
- duplicate active template и четвёртый active contract отклоняются;
- параллельные контракты делят capacity.

### Persistence

- snapshot v6 round-trip сохраняет client contracts;
- snapshot v5 без `clientContracts` мигрирует с пустой коллекцией;
- v3/v4 migrations сохраняют продукты, AI, operations и freshness;
- future version остаётся controlled error.

### Widget

- выбор первого сотрудника не закрывает assignment sheet;
- можно отметить нескольких сотрудников;
- до «Сохранить команду» `GameState` не меняется;
- после сохранения весь состав назначен;
- Team search использует стабильный key и прокрутку;
- Contracts screen принимает заказ;
- subscription slider присутствует только у live subscription-продукта;
- Overview показывает project summary;
- карточка без реального hint не показывает `i`.

### Manual physical iPhone

1. Создать продукт и подтвердить старт `0%`.
2. Заполнить onsite-офис, затем нанять remote-кандидата.
3. Отметить 2–3 сотрудников в sheet и сохранить одним действием.
4. Убедиться, что improvement недоступен до launch и доступен после.
5. Принять простой контракт, увидеть аванс и прогресс.
6. Назначить/снять сотрудников с продукта и сравнить contract speed.
7. Взять два контракта и проверить разделение мощности.
8. Изменить subscription price и сравнить revenue/market response.
9. Проверить project cards на Overview.
10. Открыть все видимые `i`: ни одна не должна содержать общий placeholder.
11. Force quit и проверить восстановление contracts/price/team.
12. Запустить profile mode на 10–15 минут и проверить scroll, heat и cold start.
