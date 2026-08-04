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
