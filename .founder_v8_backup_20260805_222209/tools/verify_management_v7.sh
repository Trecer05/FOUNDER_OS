#!/usr/bin/env bash
set -euo pipefail

flutter pub get
dart format lib test
flutter analyze
flutter test test/domain/game_engine_test.dart --reporter expanded
flutter test test/domain/game_state_snapshot_test.dart --reporter expanded
flutter test test/domain/management_refactor_test.dart --reporter expanded
flutter test test/widget_test.dart --reporter expanded
flutter test test/presentation/management_refactor_widget_test.dart --reporter expanded
flutter test --reporter expanded
git diff --check
flutter build ios --simulator --debug

echo "✅ MANAGEMENT_REFACTOR_V7_VERIFIED"
git status --short
