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
