# FOUNDER.OS

FOUNDER.OS — offline-first Flutter tycoon о создании технологической компании: продукты, команда, контракты, инфраструктура, безопасность, маркетинг, финансы, инвесторы, M&A, R&D, экосистема и глобальные world projects.

## Current source of truth

- Full game specification: `docs/MASTER_GAME_SPEC.md`
- Test strategy: `docs/TEST_STRATEGY.md`
- Current snapshot schema: `16`
- Current reference checkpoint for the spec/test reset: `b453ed8fc3c95a3044bfde3f7bfb66954647dc2d`

Historical version documents remain useful as changelog/history, but current behavior is defined by production code + MASTER_GAME_SPEC + canonical tests.

## Verification

```bash
bash tools/verify_current_release.sh
```

The gate runs:
- current structural audit;
- formatter;
- analyzer;
- domain/application/presentation tests;
- full English locale audit;
- complete Flutter test suite;
- `git diff --check`;
- iOS Simulator build;
- Android build when SDK is available.

Manual Simulator UAT is still required for changed user flows before release.
