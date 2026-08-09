# IMPLEMENTATION STATUS

## Current baseline

**FOUNDER.OS v12.2 — pre-TestFlight**

The current build is feature-complete for the planned external UAT pass.

### Verified

- `flutter analyze` — clean;
- focused v12.2 domain tests — passed;
- focused v12.2 widget tests — passed;
- v12 and v12.1 regression suites — passed;
- snapshot and migration regressions — passed;
- all domain tests — passed;
- all application and presentation tests — passed;
- full Flutter test suite — passed;
- `git diff --check` — passed;
- iOS Simulator debug build — passed;
- Android debug build — passed;
- Android release APK — built;
- Android release AAB — built;
- unsigned iOS release package for device-side signing — built.

## Main systems

### Company and founder

- company setup with name, budget and logo;
- configurable founder background and skills;
- founder contribution to product development;
- remote-first company start;
- clean new-company reset.

### Product development

- multi-step product configuration;
- four player-facing development stages;
- framework, language and technology constraints;
- deterministic development content;
- project-wide technical challenge;
- post-release product improvements;
- released-product stage cleanup.

### Team

- hiring and role requirements;
- HR-assisted automatic hiring;
- founder shown as a non-payroll project participant;
- multi-project employee assignments;
- deterministic workload efficiency for parallel work;
- product and contract staffing coverage.

### Contracts

- client contract acceptance and deadlines;
- team sufficiency indicators;
- automatic assignment of suitable low-load employees;
- progress, payouts and failure conditions;
- parallel contract capacity sharing.

### Business simulation

- monetization and pricing;
- advertising campaigns;
- finance ledger and history;
- office and infrastructure management;
- hosting and server capacity;
- credit and negative-cash recovery;
- ecosystem integrations;
- product freshness and continuous improvements;
- company ownership and investment mechanics.

### Platform and persistence

- offline-first operation;
- versioned local snapshots;
- controlled migration of older saves;
- serialized persistence writes;
- iOS and Android platform bridges for critical local persistence operations;
- RU/EN interface.

## Remaining validation

Before external distribution, complete physical-device UAT on representative iPhone and Android devices, with focus on:

- clean install and onboarding;
- product creation and release;
- project challenges;
- hiring and parallel staffing;
- contracts;
- infrastructure and finance;
- save/restore after force quit and reboot;
- RU/EN switching;
- long-session performance and thermal behavior;
- narrow-screen layout and safe-area behavior.

## Verification command

```bash
bash tools/verify_v12_2_pre_testflight.sh
```

## v13 release-candidate hotfix

Implemented after the full v13 regression log:

- removed the duplicate finance-ledger entry for a client-contract advance;
- made generated candidate cards addressable by stable widget keys;
- collapsed the long post-release feature roadmap so monetization, pricing and advertising remain reachable without scrolling through every feature card;
- hardened the hiring and subscription-price widget scenarios against lazy list construction;
- changed the v13 verifier to run every gate and write a short stage-by-stage summary instead of stopping at the first failure.

Verified in the archive environment:

- v13 static release audit — passed;
- v12.3 compatibility audit — passed;
- verifier shell syntax — passed;
- archive integrity and overlay structure — pending final package check.

Requires the local Mac gate because this archive environment has no Flutter SDK:

```bash
bash tools/verify_v13_release_candidate.sh
```
