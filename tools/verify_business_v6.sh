#!/usr/bin/env bash
set -euo pipefail

dart format lib test
flutter analyze
flutter test test/domain/game_engine_test.dart --reporter expanded
flutter test test/domain/game_state_snapshot_test.dart --reporter expanded
flutter test test/widget_test.dart --reporter expanded
flutter test --reporter expanded
git diff --check
flutter build ios --simulator --debug

echo "✅ BUSINESS_V6_VERIFIED"
