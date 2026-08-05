#!/usr/bin/env bash
set -euo pipefail

printf '%s\n' '=== DEPENDENCIES ==='
flutter pub get

printf '%s\n' '=== FORMAT ==='
dart format lib test

printf '%s\n' '=== ANALYZE ==='
flutter analyze

printf '%s\n' '=== V8 ECONOMY TESTS ==='
flutter test test/domain/product_economy_v8_test.dart --reporter expanded

printf '%s\n' '=== ENGINE TESTS ==='
flutter test test/domain/game_engine_test.dart --reporter expanded

printf '%s\n' '=== SNAPSHOT TESTS ==='
flutter test test/domain/game_state_snapshot_test.dart --reporter expanded

printf '%s\n' '=== MANAGEMENT TESTS ==='
flutter test test/domain/management_refactor_test.dart --reporter expanded

printf '%s\n' '=== LEGACY WIDGET TESTS ==='
flutter test test/widget_test.dart --reporter expanded

printf '%s\n' '=== MANAGEMENT WIDGET TESTS ==='
flutter test test/presentation/management_refactor_widget_test.dart --reporter expanded

printf '%s\n' '=== FULL TEST SUITE ==='
flutter test --reporter expanded

printf '%s\n' '=== DIFF CHECK ==='
git diff --check

printf '%s\n' '=== IOS SIMULATOR BUILD ==='
flutter build ios --simulator --debug

printf '%s\n' '✅ PRODUCT_ECONOMY_V8_VERIFIED'
git status --short
