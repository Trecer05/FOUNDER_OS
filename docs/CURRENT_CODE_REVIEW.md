# CURRENT CODE REVIEW / TEST RESET REPORT

## Reviewed reference

Repository: `Trecer05/FOUNDER_OS`
Checkpoint: `b453ed8fc3c95a3044bfde3f7bfb66954647dc2d`

The review covered the current runtime architecture, reducer/actions, GameState persistence schema, product/team/market/finance/infrastructure/security/endgame models, catalogs, app shell, R&D, persistence/controller and the historical test structure.

## Main finding

Production code has evolved into one large current simulation, while tests and docs remained historically segmented by patch names (`v8...v17`, hotfixes, optimization/stabilization files). That makes old wording and old implementation constants look like current requirements.

## Reset

This package:
- introduces `MASTER_GAME_SPEC.md` as current product contract;
- replaces the append-only PRODUCT_SPEC with a pointer to the master;
- rewrites README baseline;
- backs up then removes the old Dart test tree;
- installs a version-neutral canonical suite;
- installs `audit_current_release.py`;
- installs `verify_current_release.sh`.

The old version-specific audit scripts are retained as historical engineering artifacts but are no longer release gates because several of them explicitly require deleted legacy test paths and pre-R16 strings.

## New suite

The canonical suite is organized by system, not version:
- simulation;
- company/people;
- product lifecycle;
- product market/monetization;
- infrastructure/security;
- finance/ownership;
- contracts/ecosystem;
- research/endgame;
- geography/content;
- persistence schema;
- controller;
- snapshot storage;
- settings/native bridge;
- app shell;
- product/team flows;
- business surfaces;
- responsive/localization.

The generated canonical suite currently contains **131** test declarations (99 domain / 17 application / 15 presentation). The current audit enforces a minimum of 125 test declarations and rejects version-named test files.
