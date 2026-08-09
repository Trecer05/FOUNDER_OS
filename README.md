# FOUNDER.OS

FOUNDER.OS is an offline-first mobile management simulator about building and operating a technology company.

The player creates a company, configures a founder profile, launches products, hires and assigns teams, manages infrastructure, accepts client contracts, controls monetization and marketing, and grows the business through a deterministic simulation.

## Current baseline

**v13 — release candidate**

The release candidate adds a procedural four-grade labour market, a deeper product roadmap, rebalanced acquisition channels and market scale, rival strategy events, Founder Legacy progression, and a production main menu with manual save slots.

## Core systems

- company and founder setup;
- staged product development;
- employee hiring, workload and multi-project assignments;
- client contracts and automatic team matching;
- product monetization and marketing;
- infrastructure capacity and operating costs;
- finance, cash flow, credit and company valuation;
- ecosystem integrations and product evolution;
- deterministic events and project challenges;
- RU/EN interface;
- versioned local saves and snapshot migration.

## Architecture

The simulation uses a one-way state flow:

```text
View → GameAction → GameEngine.reduce → GameState → View
```

Key principles:

- simulation rules are deterministic within each saved game seed and shared across platforms in Dart;
- `GameState` is the source of truth for simulation state;
- `GameController` owns lifecycle, clock and persistence coordination;
- iOS and Android native bridges are limited to platform-specific persistence and diagnostics;
- the application is designed to work offline.

## Technology

- Flutter / Dart
- iOS / Android
- native Swift and Kotlin bridges for platform-specific operations
- local versioned persistence
- automated domain, widget, migration and regression tests

## Verification

Run the current release gate on a machine with Flutter installed:

```bash
bash tools/verify_v13_release_candidate.sh
```

The gate covers static release checks, analysis, focused regressions, the full Flutter suite, snapshot persistence, an iOS Simulator build and an Android release APK.

## Build

Android APK:

```bash
flutter build apk --release
```

Android App Bundle:

```bash
flutter build appbundle --release
```

iOS device build:

```bash
flutter build ios --release
```

## Project structure

```text
lib/
  application/     controllers, settings, localization
  domain/          simulation, entities, catalogs, commands
  presentation/    screens and shared widgets

test/              domain, presentation and regression tests
tools/             verification and repository utilities
docs/              product and engineering documentation
```

## Status

Source is prepared as a release candidate. The v13 gate and physical-device UAT must pass before external distribution.
