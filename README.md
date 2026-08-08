# FOUNDER.OS

FOUNDER.OS is an offline-first mobile management simulator about building and operating a technology company.

The player creates a company, configures a founder profile, launches products, hires and assigns teams, manages infrastructure, accepts client contracts, controls monetization and marketing, and grows the business through a deterministic simulation.

## Current baseline

**v12.2 — pre-TestFlight**

The current baseline is verified with the full Flutter test suite and debug builds for iOS Simulator and Android.

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

- deterministic simulation rules are shared across platforms in Dart;
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

Run the current verification gate:

```bash
bash tools/verify_v12_2_pre_testflight.sh
```

The gate covers static checks, formatting, analysis, focused regression tests, the full Flutter test suite, snapshot migrations and mobile debug builds.

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

The automated v12.2 gate is green. Physical-device UAT is the final validation step before external distribution.
