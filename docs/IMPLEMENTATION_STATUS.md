# IMPLEMENTATION STATUS

## v15 package status — long-term competition and recovery

Implemented:

- snapshot schema v13 with product release time and weighted bug persistence;
- rotating weekly bankruptcy recovery;
- lower player attack frequency and rival cyber incidents;
- 20 competitors per category and a unified ranking;
- post-release features, stack expansion, bug fixing and product renaming;
- model-specific monetization surface;
- CPU/RAM/storage infrastructure economics and compact responsive summary;
- employee filters, courses, promotions and dismissal;
- grade-based Product Manager bonus;
- on-site-only office productivity tiers and a visible crunch/recovery cycle;
- paid-acquisition rebalance and irreversible product aging;
- Dart/HSM compatibility;
- deterministic second-product release capacity reservation;
- focused v15 domain and recovery tests plus full English-locale coverage.

Archive-environment checks completed:

- release-content audit — passed;
- full English-locale audit — passed;
- Dart delimiter scan — passed.

The atomic macOS installer runs formatting, focused v15 regressions, `flutter analyze`, the complete Flutter test suite, iOS Simulator and Android debug builds, and `git diff --check`. It restores every touched file if any gate fails.

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

## v14 publisher-UAT polish

Implemented from physical-device publisher UAT:

- closed remaining English-locale leaks from data-driven fragments and locale-aware compact-number suffixes;
- moved owned-server migration to the compute-allocation tab;
- made HR grade constrain automatic hires, reused existing staff first and added deterministic sourcing for the final missing role;
- stopped inactive product assignments from reducing parallel efficiency;
- added visible employee productivity percentages with concrete positive and negative factors;
- made every credit tap show an immediate approval/refusal result;
- restored monetization and subscription-price editing in the product workspace;
- removed the duplicate advertising-channel dropdown;
- added three high-density late-game server tiers with better cost per CU.

Archive verification must run formatting, the full English audit, focused v14 tests, static analysis, the complete Flutter suite, an iOS Simulator build and an Android debug build before the patch is accepted.


## v15 R3 verification hotfix

- V15 domain regressions: passed in user Mac verifier before this hotfix (15/15).
- Bankruptcy recovery regression: passed.
- Snapshot migration regressions: passed (26 tests).
- V14 workspace regressions: passed (4/4).
- Remaining blocker from that run was one `flutter analyze` lint in `founder_dashboard.dart`; R3 fixes it with explicit mounted guards and adds a static-audit invariant.
- Full analyzer, complete Flutter suite, iOS Simulator build, Android build and final diff check must still pass on the user Mac before V15 is considered verified.


## v15 R4 full-suite compatibility hotfix

After R3 reached the complete Flutter suite, four legacy regressions were isolated and fixed without removing V15 mechanics:

- failed manual-slot load now restarts the simulation ticker from `finally`;
- a basic `company_website` uses a lightweight RAM baseline so `shared_launch` does not trigger an unrelated critical overload at the default first-product allocation;
- market overload contribution to activation/retention/churn is capped at the same 135% critical-load boundary that stops the simulation, preserving product-quality ordering before the stop;
- the global date/weekday/time pill is rendered as one rich text block, preserving the larger V15 typography while satisfying the existing undecorated-text UX contract.

A focused `v15_full_suite_compatibility_test.dart` now runs before snapshot/workspace/full-suite gates and reproduces all four regressions. R4 still requires the local Mac verifier to complete the full Flutter suite, iOS Simulator build, Android build and final diff check before V15 is marked verified.
